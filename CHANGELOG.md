# Changelog

All notable changes to `pipeline-quantitate-ProteomicLFQ` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added a de novo featureXML entrypoint NFTest case and a six-row, two-sample
  featureXML input CSV template.

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
