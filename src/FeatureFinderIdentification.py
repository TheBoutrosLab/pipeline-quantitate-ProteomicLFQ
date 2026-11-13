"""Run OpenMS 3.6 FeatureFinderIdentification with an external seed feature map."""

import argparse
import os

# pyOpenMS exports these classes from its compiled extension.
# pylint: disable=no-name-in-module
from pyopenms import (
    FeatureFinderIdentificationAlgorithm,
    FeatureMap,
    FeatureXMLFile,
    IdXMLFile,
    MSExperiment,
    OpenMSBuildInfo,
    MzMLFile,
    PeakPickerHiRes,
    PeptideIdentificationList,
    SpectrumSettings,
)


PARAMETER_TYPES = {
    "min_psm_cutoff": str,
    "add_mass_offset_peptides": float,
    "seed_apex_rt_tolerance": float,
    "extract:batch_size": int,
    "extract:mz_window": float,
    "extract:n_isotopes": int,
    "extract:isotope_pmin": float,
    "extract:rt_window": float,
    "detect:min_peak_width": float,
    "detect:signal_to_noise": float,
    "detect:peak_width": float,
    "detect:mapping_tolerance": float,
    "model:type": str,
    "EMGScoring:max_iteration": int,
}


def parse_bool(value: str) -> bool:
    """Parse a TOPP-style boolean parameter value."""
    if value.lower() in ("true", "1"):
        return True
    if value.lower() in ("false", "0"):
        return False
    raise argparse.ArgumentTypeError("Expected true or false")


def parse_args() -> argparse.Namespace:
    """Use TOPP names for shared options and -seeds for the wrapper extension."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-in", dest="input_mzml", required=True)
    parser.add_argument("-id", dest="input_idxml", required=True)
    parser.add_argument("-out", dest="output_features", required=True)
    parser.add_argument("-threads", type=int, default=1)
    parser.add_argument("-seeds", dest="input_seeds", required=True,
                        help="External featureXML seeds (pyOpenMS wrapper extension)")
    parser.add_argument("-quantify_decoys", action="store_true")
    parser.add_argument("-EMGScoring:init_mom", dest="EMGScoring:init_mom",
                        type=parse_bool, default=None)
    for name, value_type in PARAMETER_TYPES.items():
        parser.add_argument(f"-{name}", dest=name, type=value_type, default=None)
    args = parser.parse_args()
    if args.threads < 0:
        parser.error("-threads must be nonnegative")
    return args


def load_ms1(path: str) -> MSExperiment:
    """Load and centroid MS1 spectra as needed by the seeded LFQ path."""
    reader = MzMLFile()
    options = reader.getOptions()
    options.addMSLevel(1)
    reader.setOptions(options)
    experiment = MSExperiment()
    reader.load(path, experiment)
    if not experiment.getSpectra():
        raise ValueError("Input mzML contains no MS1 spectra")
    if any(spectrum.containsIMData() for spectrum in experiment):
        raise ValueError("IM_PEAK/PASEF MBR requires Biosaur2, which is not implemented")
    if any(spectrum.getType(True) == SpectrumSettings.SpectrumType.PROFILE
           for spectrum in experiment):
        experiment = PeakPickerHiRes().pickExperiment(experiment, True)
    experiment.updateRanges()
    return experiment


def main() -> None:
    """Quantify each run's IDs together with its external MS1 seeds."""
    args = parse_args()
    OpenMSBuildInfo.setOpenMPNumThreads(args.threads or os.cpu_count() or 1)
    experiment = load_ms1(args.input_mzml)

    proteins = []
    peptides = PeptideIdentificationList()
    IdXMLFile().load(args.input_idxml, proteins, peptides)

    seeds = FeatureMap()
    FeatureXMLFile().load(args.input_seeds, seeds)

    if not seeds.metaValueExists("median_fwhm"):
        raise ValueError("Seed featureXML lacks median_fwhm metadata")

    algorithm = FeatureFinderIdentificationAlgorithm()
    parameters = algorithm.getParameters()
    parameters.setValue("detect:peak_width", 5.0 * float(seeds.getMetaValue("median_fwhm")))
    options = vars(args)

    for name in (*PARAMETER_TYPES, "EMGScoring:init_mom"):
        if options[name] is not None:
            parameters.setValue(name, options[name])

    if args.quantify_decoys:
        parameters.setValue("quantify_decoys", True)

    algorithm.setParameters(parameters)
    algorithm.setMSData(experiment)

    features = FeatureMap()
    features.setPrimaryMSRunPath([args.input_mzml], experiment)
    algorithm.run(peptides, proteins, features, seeds, args.input_mzml)
    FeatureXMLFile().store(args.output_features, features)
    print(f"Quantified {len(features)} features from {len(seeds)} untargeted seeds")


if __name__ == "__main__":
    main()
