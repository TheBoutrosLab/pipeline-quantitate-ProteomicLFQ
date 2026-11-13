"""Detect untargeted LFQ seeds with the OpenMS 3.6 DDA workflow settings."""

import argparse
import os
import statistics
import time

# pyOpenMS exports these classes from its compiled extension.
# pylint: disable=no-name-in-module
from pyopenms import (
    FeatureFinderMultiplexAlgorithm,
    FeatureXMLFile,
    MassTraceDetection,
    MSExperiment,
    OpenMSBuildInfo,
    MzMLFile,
    PeakPickerHiRes,
    SpectrumSettings,
    ThresholdMower,
)


def main() -> None:
    """Write seed features and their measured chromatographic peak width."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-in", dest="input_mzml", required=True)
    parser.add_argument("-out", dest="output_seeds", required=True)
    parser.add_argument("-threads", type=int, default=1)
    parser.add_argument("-algorithm:charge", dest="charge", default="2:5")
    parser.add_argument("-threshold_mower:threshold", dest="intensity_threshold",
                        type=float, default=10000.0,
                        help="Preprocessing threshold (wrapper extension)")
    args = parser.parse_args()
    try:
        min_charge, max_charge = (int(value) for value in args.charge.split(":"))
    except ValueError:
        parser.error("-algorithm:charge must be a range such as 2:5")
    if args.threads < 0:
        parser.error("-threads must be nonnegative")
    if args.intensity_threshold < 0 or min_charge < 1 or max_charge < min_charge:
        parser.error("Expected a nonnegative threshold and a valid positive charge range")

    OpenMSBuildInfo.setOpenMPNumThreads(args.threads or os.cpu_count() or 1)
    start_time = time.perf_counter()
    reader = MzMLFile()
    options = reader.getOptions()
    options.addMSLevel(1)
    reader.setOptions(options)
    experiment = MSExperiment()
    reader.load(args.input_mzml, experiment)
    if not experiment.getSpectra():
        raise ValueError("Input mzML contains no MS1 spectra")
    if any(spectrum.containsIMData() for spectrum in experiment):
        raise ValueError("IM_PEAK/PASEF MBR requires Biosaur2, which is not implemented")

    # ProteomicsLFQ peak-picks its MS1 input before estimating widths and seeding.
    # An already centroided mzML needs no second peak-picking pass.
    profile = SpectrumSettings.SpectrumType.PROFILE
    if any(spectrum.getType(True) == profile for spectrum in experiment):
        experiment = PeakPickerHiRes().pickExperiment(experiment, True)
    experiment.updateRanges()
    load_time = time.perf_counter()

    traces = MassTraceDetection().run(experiment, 1000)
    widths = []
    for trace in traces:
        if trace.getSize():
            trace.updateMeanMZ()
            trace.updateWeightedMZsd()
            width = trace.estimateFWHM(False)
            if width > 0:
                widths.append(width)
    if not widths:
        raise ValueError("Could not estimate chromatographic FWHM from MS1 mass traces")
    median_fwhm = statistics.median(widths)

    threshold = ThresholdMower()
    settings = threshold.getParameters()
    settings.setValue("threshold", args.intensity_threshold)
    threshold.setParameters(settings)
    threshold.filterPeakMap(experiment)
    prepare_time = time.perf_counter()

    finder = FeatureFinderMultiplexAlgorithm()
    settings = finder.getParameters()
    settings.setValue("algorithm:labels", "")
    settings.setValue("algorithm:charge", args.charge)
    settings.setValue("algorithm:rt_typical", median_fwhm * 3.0)
    settings.setValue("algorithm:rt_band", 3.0)
    settings.setValue("algorithm:rt_min", median_fwhm * 0.5)
    settings.setValue("algorithm:spectrum_type", "centroid")
    finder.setParameters(settings)
    finder.run(experiment, True)
    detect_time = time.perf_counter()
    seeds = finder.getFeatureMap()
    seeds.setPrimaryMSRunPath([args.input_mzml])
    seeds.setMetaValue("median_fwhm", median_fwhm)
    FeatureXMLFile().store(args.output_seeds, seeds)
    store_time = time.perf_counter()
    print(f"Detected {len(seeds)} seeds; median FWHM {median_fwhm:.3f} s")
    print(f"Timing (s): load/centroid {load_time - start_time:.1f}, "
          f"prepare {prepare_time - load_time:.1f}, "
          f"detect {detect_time - prepare_time:.1f}, "
          f"write {store_time - detect_time:.1f}; "
          f"OpenMS threads {OpenMSBuildInfo.getOpenMPMaxNumThreads()}")


if __name__ == "__main__":
    main()
