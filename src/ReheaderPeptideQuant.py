"""Name OpenMS 3.6 peptide assay columns from the quantified consensusXML."""

import argparse
import csv
import re
import shutil
from collections import defaultdict, OrderedDict

from pyopenms import ConsensusMap, ConsensusXMLFile, ExperimentalDesign


ASSAY_COLUMN = re.compile(r'abundance_fgroup([1-9][0-9]*)_label([1-9][0-9]*)')
DETAILED_COLUMN = re.compile(r'abundance\|[^|\t\r\n]+\|ch[1-9][0-9]*')


def text(value):
    """Convert pyOpenMS string values to Python text."""
    return value.decode() if isinstance(value, bytes) else str(value)


class PeptideQuantCSVReheader:
    """Keep the OpenMS design and its assay-to-column mapping together."""

    def __init__(self, input_path: str, sample_name: str):
        """Record the quantified input and its sample name."""
        self.input_path = input_path
        self.sample_name = sample_name
        self.consensus: ConsensusMap = None
        self.assays = OrderedDict()

    def load_consensus(self):
        """Load the consensusXML when the caller is ready to process it."""
        if self.input_path.endswith('.consensusXML'):
            self.consensus = ConsensusMap()
            ConsensusXMLFile().load(self.input_path, self.consensus)
        self.assays.clear()

    def build_column_names(self):
        """Name each assay using OpenMS's fraction group and label identifiers."""
        if self.consensus is None:
            if not self.input_path.endswith('.featureXML'):
                raise ValueError(f'Unsupported quantification input {self.input_path!r}')
            grouped = OrderedDict([((1, 1), {self.sample_name})])
        else:
            design = ExperimentalDesign.fromConsensusMap(self.consensus)
            by_path_label = defaultdict(list)
            for header in self.consensus.getColumnHeaders().values():
                filename = text(header.filename)
                label = (int(header.getMetaValue('channel_id')) + 1
                         if header.metaValueExists('channel_id') else 1)
                by_path_label[(filename, label)].append(header)

            grouped = OrderedDict()
            for entry in design.getMSFileSection():
                assay = (int(entry.fraction_group), int(entry.label))
                source = text(entry.path)
                matching = [header for header in by_path_label.get((source, assay[1]), [])
                            if not header.metaValueExists('fraction_group')
                            or int(header.getMetaValue('fraction_group')) == assay[0]]
                if not matching:
                    raise ValueError(
                        f'No consensusXML map matches assay {assay} and file {source!r}')
                names = {text(header.getMetaValue('sample_name'))
                         if header.metaValueExists('sample_name') else text(entry.sample_name)
                         for header in matching}
                grouped.setdefault(assay, set()).update(names)

        if not grouped:
            raise ValueError('Quantification input contains no assays')

        self.assays.clear()
        for assay, names in grouped.items():
            if len(names) != 1:
                raise ValueError(f'Assay {assay} has conflicting sample names {names}')
            name = next(iter(names))
            if not name or any(char in name for char in '\t\r\n|'):
                raise ValueError(f'Assay {assay} has an unusable sample name {name!r}')
            self.assays[assay] = f'abundance|{name}'
        if len(set(self.assays.values())) != len(self.assays):
            raise ValueError('Multiple assays have the same sample name')
        return self.assays

    def replace_header(self, line: str):
        """Replace assay headers by identifier, without depending on column order."""
        if not self.assays:
            raise ValueError('Build peptide column names before rewriting the CSV')
        if '\t' not in line:
            raise ValueError('Expected tab-separated ProteinQuantifier output')

        header = next(csv.reader([line], delimiter='\t'))
        detailed = [name for name in header if DETAILED_COLUMN.fullmatch(name)]
        if detailed:
            if len(detailed) != len(set(detailed)):
                raise ValueError('Repeated detailed peptide abundance column')
            if any(name.startswith('abundance') and name not in detailed for name in header):
                raise ValueError('Mixed or unexpected peptide abundance columns')
            return header  # OpenMS already names detailed file/channel columns.

        seen = set()
        for index, name in enumerate(header):
            match = ASSAY_COLUMN.fullmatch(name)
            if match:
                assay = (int(match.group(1)), int(match.group(2)))
                if assay not in self.assays or assay in seen:
                    raise ValueError(f'Unexpected or repeated peptide abundance assay {assay}')
                header[index] = self.assays[assay]
                seen.add(assay)
            elif name.startswith('abundance'):
                raise ValueError(f'Unexpected peptide abundance header {name!r}')
        if seen != self.assays.keys():
            raise ValueError(f'ProteinQuantifier is missing assays {set(self.assays) - seen}')
        return header

    def write(self, input_path, output_path):
        """Rewrite only the header line; copy comments and peptide rows verbatim."""
        if not self.assays:
            raise ValueError('Build peptide column names before rewriting the CSV')
        with open(input_path, encoding='utf-8', newline='') as source, \
                open(output_path, 'w', encoding='utf-8', newline='') as target:
            for line in source:
                if line.startswith('#'):
                    target.write(line)
                    continue
                header = self.replace_header(line)
                writer = csv.writer(target, delimiter='\t', lineterminator='\n')
                writer.writerow(header)
                shutil.copyfileobj(source, target)
                return
        raise ValueError('ProteinQuantifier output has no table header')


def main():
    """Parse command-line inputs and write the renamed peptide table."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input-csv', required=True)
    parser.add_argument('--input-xml', required=True)
    parser.add_argument('--sample-name', required=True)
    parser.add_argument('--output-csv', required=True)
    args = parser.parse_args()
    reheader = PeptideQuantCSVReheader(args.input_xml, args.sample_name)
    reheader.load_consensus()
    reheader.build_column_names()
    reheader.write(args.input_csv, args.output_csv)


if __name__ == '__main__':
    main()
