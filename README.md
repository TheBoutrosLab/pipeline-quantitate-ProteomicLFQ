# quantitate-ProteomicLFQ

- [quantitate-ProteomicLFQ](#quantitate-proteomiclfq)
  - [Overview](#overview)
  - [How To Run](#how-to-run)
  - [Config Options](#config-options)
    - [Global Params](#global-params)
  - [Quantification with OpenMS 3.6](#quantification-with-openms-36)
  - [Outputs](#outputs)
  - [References](#references)
  - [License](#license)

## Overview

This pipeline takes the mass spectrometry data from label free data dependent acquisition (DDA) proteomic studies, map them with the library search results, and quantitate peptide abundance. The mass spectrometry data must be in the mzML format, and can be converted from raw files using [ucla-cds/pipeline-convert-MSData](https://github.com/uclahs-cds/pipeline-convert-MSData). The library search result must be in idXML file, which can be generated using the [ucla-cds/pipeline-search-ProteomicMSMS](https://github.com/uclahs-cds/pipeline-search-ProteomicMSMS) and [ucla-cds/pipeline-validate-ProteomicPSM](https://github.com/uclahs-cds/pipeline-validate-ProteomicPSM). The outputted consensusXML can be used downstream for protein inference and quantitation.

![workflow](img/flow-diagram.drawio.svg?raw=true)

In this pipeline we implemented the targeted feature detection algorithm published by [Weisser et al in 2017](https://pubs.acs.org/doi/abs/10.1021/acs.jproteome.7b00248). For each mzML file, the features were first extracted using FFId (FeatureFinderIdentification) with the identification results. The features are then aligned across all samples at the study/cohort level. The retention times are then transformed, and then samples are merged to into consensus features. FFId provides three strategies, as internal-only, int/ext-merged, and machine-learning. For internal-only, only peptide identification results from the corresponding mzML is used. For int/ext-merged, all idXMLs from the same cohort/experiment are first aligned then merged and used to find features. The machine-learning strategy first align all idXMLs but treat internal and external identifications separately. Read the FFId paper for more detail.

---

## How To Run

1. Create a mzML CSV file (see [this](input/mzML.csv)) or a featureXML CSV file (see [this](input/featureXML.csv)).

2. Create a idXML CSV file (see [this](input/idXML.csv))

3. Create a config file using [this template](config/template.config)

4. For UCLA-CDS cluster users, see the nextflow pipeline submission script [here](https://github.com/uclahs-cds/tool-submit-nf), to submit your pipeline. Otherwise, the pipeline can be launched using `nextflow run` from command line.

---

## Config Options

### Global Params

| Parameter | Type  | Description |
|:----------|:------|:------------|
| mzML_csv | str | Path to the mzML CSV File. Required when `featureXML_entrypoint` is false. See [this template](input/mzML.csv). |
| featureXML_csv | str | Path to the featureXML CSV file. Required when `featureXML_entrypoint` is true. See [this template](input/featureXML.csv) for example. Only used in the *de novo* workflow. |
| idXML_csv | str | Path to the idXML CSV file. See [this template](input/idXML.csv) for example. Note that the idXML files should one per sample for all fractions, not each fraction separated. |
| output_dir | str | Path to the output directory |
| project_name | str | Project name. Used as the prefix of the final output. |
| save_intermediate_files | bool | When true, intermediate files will be saved. |
| resource_allocation_profile_tag | str | Resource profile in `config/resources.json`. Defaults to `default`. |
| base_resource_update | map | Optional per-process CPU and memory adjustments using the shared resource handler. |
| ucla_cds | bool | When true, use the shared UCLA scratch work directory behavior. Resource allocation still uses `resources.json`. |
| featureXML_entrypoint | bool | When true, `featureXML_csv` is required instead of `mzML.csv`. |
| merge_featureXML | bool | When false, retention time won't be adjusted between samples and the PSM mapped featureXML will be used for peptide quantitation at the sample level. Applies to both FFId and de novo workflows. Defaults to true. |
| filter_mapped_features | bool | When true, the features mapped to any PSM are removed and the result featureXML files are saved to final output. This can be useful for tiered custom database searching. |
| fractionated | bool | Whether the samples have multiple fractions. When true, the input idXML will be split into individual fraction and then each featureXML file will be mapped to its corresponding idXML. |

In general, most parameters of each program used in the pipeline can be specified from the config files in the format of `<prefix>_<original_arg>`. For example, the value of `find_features_ident_extract_mz_window` is parsed to `FeatureFinderIdentification` as `-extract:mz_window`.

See [here](docs/params.rst) for the complete list of all supported config parameters.

---

## Quantification with OpenMS 3.6

OpenMS and pyOpenMS default to version 3.6.0. The merged and machine-learning
FFId strategies retain OpenMS and pyOpenMS 3.5.0 for processing before ProteinQuantifier;
OpenMS 3.6 removed the external-ID and SVM options those strategies require.
ProteinQuantifier runs with OpenMS 3.6.0 for every workflow.

For fractionated cohorts, the pipeline gives each consensusXML column a unique
sample-and-fraction filename and annotates its sample name, fraction number,
original `fraction_id`, and fraction group before merging fractions. This lets OpenMS 3.6 recognize one
assay per sample across all fractions. Fraction IDs in the input CSV can be
text labels; the original labels remain in output filenames while OpenMS
receives a positive integer fraction number assigned by each distinct label’s
first appearance in the input CSV. The top-level workflow attaches the number to each input file as it reads
the CSV. The linked consensusXML receives the matching number by fraction
label, regardless of channel arrival order.

`protein_quantifier_fractions_aggregate` defaults to `sum`: all fractions of a
sample contribute to its assay abundance. Set it to `best` only when one
fraction per peptide should represent the sample. The separate
`protein_quantifier_best_charge` flag (default `false`) selects one charge per
modified peptide for protein quantification and produces detailed peptide CSV
rows for each observed fraction and charge. Without it, the peptide CSV has
one row per peptide with `fraction` set to `all`. The published peptide CSV renames OpenMS assay columns to
`abundance|<sample_name>`. The detailed output from `-best_charge` instead
uses file and channel columns. Ratio columns are no longer produced by
ProteinQuantifier; calculate contrasts downstream if needed. See the
[OpenMS 3.6 ProteinQuantifier documentation](https://openms.de/doxygen/release/3.6.0/html/TOPP_ProteinQuantifier.html).

OpenMS 3.6 also changed the automatic reference used by MapAlignerIdentification.
This pipeline selects `consensus` by default to preserve its previous RT
alignment behavior. The `align_featureXML_id_algorithm_auto_reference` and
`align_idXML_algorithm_auto_reference` parameters can override that choice
for 3.6 workflows.

## Outputs

Final results are saved under `<output_dir>/quantitate-ProteomicLFQ-<version>/OpenMS-<version>/output/`. The `project_name` prefixes cohort-wide files; individual-sample files use their sample names.

| File name/pattern | Description |
|:----------------- |:----------- |
| `*_FileMerger.consensusXML` | Map immediately before conflict resolution for fractionated, linked cohorts. |
| `*_setColumnHeaders.consensusXML` | Map immediately before conflict resolution for routes that quantify samples independently. |
| `*_IDConflictResolver.consensusXML` | Final consensus map passed to ProteinQuantifier after resolving identification conflicts. |
| `*_ProteinQuantifier_peptide.csv` | Peptide quantification results from OpenMS 3.6. Linked cohorts produce a cohort CSV; independent sample processing produces one CSV per sample. |
| `*_FeatureFinder.featureXML` | The featureXML generated from each sample's mzML without PSMs mapped to it. |

---

## References

1. Rost HL, Sachsenberg T, Aiche S, Bielow C et al.. OpenMS: a flexible open-source software platform for mass spectrometry data analysis. *Nat Meth*. 2016; 13, 9: 741-748. doi:10.1038/nmeth.3959.
2. Weisser, Hendrik, and Jyoti S. Choudhary. Targeted feature detection for data-dependent shotgun proteomics. *Journal of proteome research* 16.8 (2017): 2964-2974.

---

## License

Author: Chenghao Zhu (ChenghaoZhu@mednet.ucla.edu)

[quantitate-ProteomicLFQ] is licensed under the GNU General Public License version 2. See the file LICENSE for the terms of the GNU GPL license.

Copyright (C) 2021 University of California Los Angeles ("Boutros Lab") All rights reserved.

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
