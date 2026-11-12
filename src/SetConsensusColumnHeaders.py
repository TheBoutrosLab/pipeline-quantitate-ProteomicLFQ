"""Set consensus map sample names and fraction metadata for OpenMS quantification."""

import argparse

from pyopenms import ConsensusMap, ConsensusXMLFile


def main() -> None:
    """Set sample names and fraction metadata on consensus map columns."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input-path", required=True)
    parser.add_argument("--output-path", required=True)
    parser.add_argument("--sample-names", nargs="+", required=True)
    parser.add_argument("--fraction-id")
    parser.add_argument("--fraction-number", type=int)
    parser.add_argument("--all-samples", nargs="+")
    args = parser.parse_args()

    consensus = ConsensusMap()
    reader = ConsensusXMLFile()
    reader.load(args.input_path, consensus)
    headers = consensus.getColumnHeaders()
    if len(headers) != len(args.sample_names):
        raise ValueError("Number of sample names does not match consensus map columns")
    if args.fraction_id is not None:
        if args.fraction_number is None or args.fraction_number < 1 or not args.all_samples:
            raise ValueError("A positive fraction number and all sample names are required")
        groups = {name: index + 1 for index, name in enumerate(sorted(set(args.all_samples)))}
        if any(name not in groups for name in args.sample_names):
            raise ValueError("Consensus map contains a sample absent from the cohort")

    for (index, header), sample_name in zip(sorted(headers.items()), args.sample_names):
        # OpenMS 3.6 requires a unique filename+label for every assay file.
        # Keep the biological sample identity in sample_name/fraction_group.
        header.filename = (f"{sample_name}_fraction_{args.fraction_id}.mzML"
                           if args.fraction_id is not None else sample_name)
        if args.fraction_id is not None:
            header.setMetaValue("fraction", args.fraction_number)
            header.setMetaValue("fraction_id", args.fraction_id)
            header.setMetaValue("fraction_group", groups[sample_name])
            header.setMetaValue("sample_name", sample_name)
        headers[index] = header
    consensus.setColumnHeaders(headers)
    reader.store(args.output_path, consensus)


if __name__ == "__main__":
    main()
