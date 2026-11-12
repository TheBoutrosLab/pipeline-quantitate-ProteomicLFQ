# Changelog

All notable changes to `pipeline-quantitate-ProteomicLFQ` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Aligned final output layout with TMT: files are published directly under
  `OpenMS-<version>/output/`, without project or tool subdirectories. The final
  IDConflictResolver consensusXML used for quantification and its immediate
  precursor are both published there.
- Upgraded OpenMS and pyOpenMS defaults to 3.6.0 while retaining OpenMS and pyOpenMS 3.5.0
  processing for merged and machine-learning FFId strategies.
- Migrated ProteinQuantifier to `-best_charge` and explicit `-fractions:aggregate sum`,
  removed the unsupported ratios option, and preserved consensus RT alignment.
- Annotated cohort consensusXML columns with sample and fraction metadata for
  OpenMS 3.6 assay aggregation.

### Fixed

- Kept fraction-specific reheadered consensusXML in intermediate outputs only
  when `save_intermediate_files` is enabled.
- Renamed peptide abundance CSV columns to `abundance|<sample_name>` using
  the consensusXML sample design.
- Restricted expected-empty peptide quantification handling to its exact error.
- Gave fractionated consensus columns unique filenames and ignored blank CSV
  lines when counting samples for OpenMS 3.6 quantification.

## [1.0.1] - 2026-10-15

### Added

- Added a de novo featureXML entrypoint NFTest case and a six-row, two-sample
  featureXML input CSV template.

### Fixed

- Ignored blank lines in mzML fraction validation and reported malformed rows with their
  line number and values.

## [1.0.0]

### Added

- Added a new Nextflow DSL2 implementation for label-free peptide quantification.
- Added FeatureFinderIdentification workflows with internal-only, merged identification,
  and machine-learning strategies, plus a de novo feature-detection workflow.
- Added sample- and fraction-aware input handling, retention-time alignment, feature
  linking, consensus map merging, conflict resolution, and peptide quantification.
- Added mzML and featureXML entry points, optional mapped-feature filtering, and
  direct publication of OpenMS peptide quantification CSV files.
- Added parameter validation, configurable container profiles, shared resource
  allocation, versioned output directories, process logs, and workflow reports.
- Added NFTest integration cases and environment-variable expansion for test CSV
  inputs, with a Slurm scratch-directory test runner.
- Added pipeline documentation, input templates, and metadata.

[1.0.0]: https://github.com/TheBoutrosLab/pipeline-quantitate-ProteomicLFQ/releases/tag/v1.0.0
[1.0.1]: https://github.com/TheBoutrosLab/pipeline-quantitate-ProteomicLFQ/compare/v1.0.0...v1.0.1
[unreleased]: https://github.com/TheBoutrosLab/pipeline-quantitate-ProteomicLFQ/compare/v1.0.1...HEAD
