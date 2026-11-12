"""Set the sample-level spectra path on a feature map."""

import argparse

from pyopenms import FeatureMap, FeatureXMLFile


def main() -> None:
    """Set the spectra path used by the feature map."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input-path", required=True)
    parser.add_argument("--output-path", required=True)
    parser.add_argument("--spectra-path", required=True)
    args = parser.parse_args()

    feature_map = FeatureMap()
    reader = FeatureXMLFile()
    reader.load(args.input_path, feature_map)
    feature_map.setPrimaryMSRunPath([args.spectra_path.encode("utf-8")])
    reader.store(args.output_path, feature_map)


if __name__ == "__main__":
    main()
