#!/usr/bin/env python3
"""Check the OpenMS 3.6 output contract for the E. coli NFTest cases."""

import argparse
import csv
from pathlib import Path
import re
import xml.etree.ElementTree as ET

SAMPLES = ("LFQ_Orbitrap_DDA_Ecoli_01", "LFQ_Orbitrap_DDA_Ecoli_02")
ABUNDANCE = re.compile(r"abundance\|[^|\t\r\n]+")


def peptide_table(path: Path, expected_abundance_columns: int) -> None:
    """Check assay headers and peptide rows in a published CSV."""
    with path.open(newline="") as handle:
        rows = csv.DictReader((line for line in handle if not line.startswith("#")), delimiter="\t")
        headers = rows.fieldnames or []
        abundances = [header for header in headers if header.startswith("abundance")]
        assert len(abundances) == expected_abundance_columns, (path, abundances)
        assert all(ABUNDANCE.fullmatch(header) for header in abundances), (path, abundances)
        expected = (list(SAMPLES) if expected_abundance_columns > 1 else
                    [path.name.removesuffix("_ProteinQuantifier_peptide.csv")])
        assert abundances == [f"abundance|{sample}" for sample in expected], (path, abundances)
        assert "fraction" in headers and "charge" in headers, (path, headers)
        records = list(rows)
        assert records, f"No quantified peptides in {path}"
        assert all(row["fraction"] == "all" and row["charge"] == "0" for row in records), path
        assert all(row[header] != "" for row in records for header in abundances), path


def main() -> None:
    """Check the published outputs for the requested NFTest mode."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output_root", type=Path)
    parser.add_argument("mode", choices=("fractionated-cohort", "unfractionated-samples"))
    args = parser.parse_args()

    tables = list(args.output_root.rglob("output/*_ProteinQuantifier_peptide.csv"))
    if args.mode == "fractionated-cohort":
        assert len(tables) == 1, tables
        assert tables[0].name == "ECOLI_LFQ_ProteinQuantifier_peptide.csv", tables
        peptide_table(tables[0], len(SAMPLES))
        final_maps = list(args.output_root.rglob(
            "output/ECOLI_LFQ_IDConflictResolver.consensusXML"))
        assert len(final_maps) == 1, final_maps
        maps = list(args.output_root.rglob("output/ECOLI_LFQ_FileMerger.consensusXML"))
        assert len(maps) == 1, maps
        tree = ET.parse(maps[0])
        map_list = tree.find(".//mapList")
        assert map_list is not None, maps[0]
        columns = map_list.findall("map")
        assert len(columns) == len(SAMPLES) * 3, maps[0]
        observed = set()
        for column in columns:
            metadata = {item.get("name"): item.get("value") for item in column.findall("UserParam")}
            sample = metadata.get("sample_name")
            fraction = int(metadata["fraction"])
            assert sample in SAMPLES, (maps[0], column.attrib)
            assert column.get("name") == f"{sample}_fraction_{fraction}.mzML", column.attrib
            observed.add((sample, fraction, int(metadata["fraction_group"])))
        assert observed == {(sample, fraction, index) for index, sample in enumerate(SAMPLES, 1)
                            for fraction in (1, 2, 3)}, observed
    else:
        assert {table.name for table in tables} == {
            f"{sample}_ProteinQuantifier_peptide.csv" for sample in SAMPLES
        }, tables
        pre_maps = list(args.output_root.rglob("output/*_setColumnHeaders.consensusXML"))
        assert {path.name for path in pre_maps} == {
            f"{sample}_setColumnHeaders.consensusXML" for sample in SAMPLES
        }, pre_maps
        final_maps = list(args.output_root.rglob("output/*_IDConflictResolver.consensusXML"))
        assert {path.name for path in final_maps} == {
            f"{sample}_IDConflictResolver.consensusXML" for sample in SAMPLES
        }, final_maps
        for table in tables:
            peptide_table(table, 1)

    print(f"OpenMS 3.6 {args.mode} output contract passed")


if __name__ == "__main__":
    main()
