*************
Config Params
*************

FeatureFinderIdentification (process: find_features_FFId)
#######################################################

See `here <https://openms.de/doxygen/release/3.6.0/html/TOPP_FeatureFinderIdentification.html>`_ for OpenMS's documentation of FeatureFinderIdentification.


+-----------------------------------------------+---------+----------------------------------------------+
| Parameter                                     | Type    | Description                                  |
+===============================================+=========+==============================================+
|| find_features_ident_quantify_decoys                || bool   ||                    Whether decoy peptides   |
|| (-quantify_decoys)                           ||        || should be quantified (true) or skipped      |
||                                              ||        || (false).                                    |
+-----------------------------------------------+---------+----------------------------------------------+
|| find_features_ident_extract_batch_size             || number || Nr of peptides used in each batch of        |
|| (-extract:batch_size)                        ||        || chromatogram extraction. Smaller values     |
||                                              ||        || decrease memory usage but increase runtime. |
||                                              ||        || (default: '5000' min: '1')                  |
+-----------------------------------------------+---------+----------------------------------------------+
|| find_features_ident_extract_mz_window              || value  || M/z window size for chromatogram extraction |
|| (-extract:mz_window)                         ||        || (unit: ppm if 1 or greater, else Da/Th)     |
||                                              ||        || (default: '10.0' min: '0.0')                |
+-----------------------------------------------+---------+----------------------------------------------+
|| find_features_ident_extract_n_isotopes             || number || Number of isotopes to include in each       |
|| (-extract:n_isotopes)                        ||        || peptide assay. (default: '2' min: '2')      |
||                                              ||        ||                                             |
+-----------------------------------------------+---------+----------------------------------------------+
|| find_features_ident_detect_peak_width              || value  || Expected elution peak width in seconds, for |
|| (-detect:peak_width)                         ||        || smoothing (Gauss filter). Also determines   |
||                                              ||        || the RT extration window, unless set         |
||                                              ||        || explicitly via 'extract:rt_window'.         |
||                                              ||        || (default: '60.0' min: '0.0')                |
+-----------------------------------------------+---------+----------------------------------------------+
|| find_features_ident_detect_mapping_tolerance       || value  || RT tolerance (plus/minus) for mapping       |
|| (-detect:mapping_tolerance)                  ||        || peptide IDs to features. Absolute value in  |
||                                              ||        || seconds if 1 or greater, else relative to   |
||                                              ||        || the RT span of the feature. (default: '0.0' |
||                                              ||        || min: '0.0')                                 |
+-----------------------------------------------+---------+----------------------------------------------+
|| find_features_ident_model_type                     || choice || Type of elution model to fit to features    |
|| (-model:type)                                ||        || (default: 'symmetric' valid: 'symmetric',   |
||                                              ||        || 'asymmetric', 'none')                       |
+-----------------------------------------------+---------+----------------------------------------------+
|| find_features_ident_EMGScoring_max_iteration       || number || Maximum number of iterations for EMG        |
|| (-EMGScoring:max_iteration)                  ||        || fitting. (default: '100' min: '1')          |
||                                              ||        ||                                             |
+-----------------------------------------------+---------+----------------------------------------------+



MapAlignerIdentification (process: align_featureXML_id)
#######################################################

See `here <https://openms.de/doxygen/release/3.6.0/html/TOPP_MapAlignerIdentification.html>`_ for OpenMS's documentation of MapAlignerIdentification.


+----------------------------------------------+---------+--------------------------------------------+
| Parameter                                    | Type    | Description                                |
+==============================================+=========+============================================+
|| align_featureXML_id_reference_file             || file   || File to use as reference (valid formats:  |
|| (-reference:file)                           ||        || 'featureXML', 'consensusXML', 'idXML')    |
||                                             ||        ||                                           |
+----------------------------------------------+---------+--------------------------------------------+
|| align_featureXML_id_reference_index            || number || Use one of the input files as reference   |
|| (-reference:index)                          ||        || ('1' for the first file, etc.).           |
||                                             ||        ||                                           |
+----------------------------------------------+---------+--------------------------------------------+
|| align_featureXML_id_design                     || file   || Input file containing the experimental    |
|| (-design)                                   ||        || design (valid formats: 'tsv')             |
||                                             ||        ||                                           |
+----------------------------------------------+---------+--------------------------------------------+
|| align_featureXML_id_algorithm_score_cutoff     || bool   ||                          If only IDs      |
|| (-algorithm:score_cutoff)                   ||        || above a score cutoff should be used. Used |
||                                             ||        || together with min_score.                  |
+----------------------------------------------+---------+--------------------------------------------+
|| align_featureXML_id_algorithm_min_score        || value  || Minimum score for an ID to be considered. |
|| (-algorithm:min_score)                      ||        || Applies to the last score calculated.     |
||                                             ||        ||                                           |
+----------------------------------------------+---------+--------------------------------------------+
|| align_featureXML_id_algorithm_min_run_occur    || number || Minimum number of runs (incl. reference,  |
|| (-algorithm:min_run_occur)                  ||        || if any) in which a peptide must occur to  |
||                                             ||        || be used for the alignment.                |
+----------------------------------------------+---------+--------------------------------------------+



MapRTTransformer (process: transform_rt)
########################################

See `here <https://openms.de/doxygen/release/3.6.0/html/TOPP_MapRTTransformer.html>`_ for OpenMS's documentation of MapRTTransformer.


+-----------------------------------------------+---------+----------------------------------------+
| Parameter                                     | Type    | Description                            |
+===============================================+=========+========================================+
|| transform_rt_invert                          || bool   ||                                       |
|| (-invert)                                    ||        ||    Invert transformation              |
||                                              ||        || (approximatively) before applying it  |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_store_original_rt               || bool   ||                               Store   |
|| (-store_original_rt)                         ||        || the original retention times (before  |
||                                              ||        || transformation) as meta data in the   |
||                                              ||        || output file                           |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_model_type                      || choice || Type of model (default: 'none' valid: |
|| (-model:type)                                ||        || 'none', 'linear', 'b_spline',         |
||                                              ||        || 'lowess', 'interpolated')             |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_linear_symmetric_regression     || bool   ||               Perform linear          |
|| (-model:linear:symmetric_regression)         ||        || regression on 'y - x' vs. 'y + x',    |
||                                              ||        || instead of on 'y' vs. 'x'.            |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_linear_x_weight                 || choice || Weight x values (valid: '1/x',        |
|| (-model:linear:x_weight)                     ||        || '1/x2', 'ln(x)', '')                  |
||                                              ||        ||                                       |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_linear_y_weight                 || choice || Weight y values (valid: '1/y',        |
|| (-model:linear:y_weight)                     ||        || '1/y2', 'ln(y)', '')                  |
||                                              ||        ||                                       |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_linear_x_datum_min              || value  || Minimum x value (default: '1.0e-15')  |
|| (-model:linear:x_datum_min)                  ||        ||                                       |
||                                              ||        ||                                       |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_linear_x_datum_max              || value  || Maximum x value (default: '1.0e15')   |
|| (-model:linear:x_datum_max)                  ||        ||                                       |
||                                              ||        ||                                       |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_linear_y_datum_min              || value  || Minimum y value (default: '1.0e-15')  |
|| (-model:linear:y_datum_min)                  ||        ||                                       |
||                                              ||        ||                                       |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_linear_y_datum_max              || value  || Maximum y value (default: '1.0e15')   |
|| (-model:linear:y_datum_max)                  ||        ||                                       |
||                                              ||        ||                                       |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_b_spline_wavelength             || value  || Determines the amount of smoothing by |
|| (-model:b_spline:wavelength)                 ||        || setting the number of nodes for the   |
||                                              ||        || B-spline. The number is chosen so     |
||                                              ||        || that the spline approximates a        |
||                                              ||        || low-pass filter with this cutoff      |
||                                              ||        || wavelength. The wavelength is given   |
||                                              ||        || in the same units as the data; a      |
||                                              ||        || higher value means more smoothing.    |
||                                              ||        || '0' sets the number of nodes to twice |
||                                              ||        || the number of input points. (default: |
||                                              ||        || '0.0' min: '0.0')                     |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_b_spline_num_nodes              || number || Number of nodes for B-spline fitting. |
|| (-model:b_spline:num_nodes)                  ||        || Overrides 'wavelength' if set (to two |
||                                              ||        || or greater). A lower value means more |
||                                              ||        || smoothing. (default: '5' min: '0')    |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_b_spline_extrapolate            || choice || Method to use for extrapolation       |
|| (-model:b_spline:extrapolate)                ||        || beyond the original data range.       |
||                                              ||        || 'linear': Linear extrapolation using  |
||                                              ||        || the slope of the B-spline at the      |
||                                              ||        || corresponding endpoint. 'b_spline':   |
||                                              ||        || Use the B-spline (as for              |
||                                              ||        || interpolation). 'constant': Use the   |
||                                              ||        || constant value of the B-spline at the |
||                                              ||        || corresponding endpoint.               |
||                                              ||        || 'global_linear': Use a linear fit     |
||                                              ||        || through the data (which will most     |
||                                              ||        || probably introduce discontinuities at |
||                                              ||        || the ends of the data range).          |
||                                              ||        || (default: 'linear' valid: 'linear',   |
||                                              ||        || 'b_spline', 'constant',               |
||                                              ||        || 'global_linear')                      |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_b_spline_boundary_condition     || number || Boundary condition at B-spline        |
|| (-model:b_spline:boundary_condition)         ||        || endpoints: 0 (value zero), 1 (first   |
||                                              ||        || derivative zero) or 2 (second         |
||                                              ||        || derivative zero) (default: '2' min:   |
||                                              ||        || '0' max: '2')                         |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_lowess_span                     || value  || Fraction of datapoints (f) to use for |
|| (-model:lowess:span)                         ||        || each local regression (determines the |
||                                              ||        || amount of smoothing). Choosing this   |
||                                              ||        || parameter in the range .2 to .8       |
||                                              ||        || usually results in a good fit.        |
||                                              ||        || (default: '0.666666666666667' min:    |
||                                              ||        || '0.0' max: '1.0')                     |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_lowess_num_iterations           || number || Number of robustifying iterations for |
|| (-model:lowess:num_iterations)               ||        || lowess fitting. (default: '3' min:    |
||                                              ||        || '0')                                  |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_lowess_delta                    || value  || Nonnegative parameter which may be    |
|| (-model:lowess:delta)                        ||        || used to save computations             |
||                                              ||        || (recommended value is 0.01 of the     |
||                                              ||        || range of the input, e.g. for data     |
||                                              ||        || ranging from 1000 seconds to 2000     |
||                                              ||        || seconds, it could be set to 10).      |
||                                              ||        || Setting a negative value will         |
||                                              ||        || automatically do this. (default:      |
||                                              ||        || '-1.0')                               |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_lowess_interpolation_type       || choice || Method to use for interpolation       |
|| (-model:lowess:interpolation_type)           ||        || between datapoints computed by        |
||                                              ||        || lowess. 'linear': Linear              |
||                                              ||        || interpolation. 'cspline': Use the     |
||                                              ||        || cubic spline for interpolation.       |
||                                              ||        || 'akima': Use an akima spline for      |
||                                              ||        || interpolation (default: 'cspline'     |
||                                              ||        || valid: 'linear', 'cspline', 'akima')  |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_lowess_extrapolation_type       || choice || Method to use for extrapolation       |
|| (-model:lowess:extrapolation_type)           ||        || outside the data range.               |
||                                              ||        || 'two-point-linear': Uses a line       |
||                                              ||        || through the first and last point to   |
||                                              ||        || extrapolate. 'four-point-linear':     |
||                                              ||        || Uses a line through the first and     |
||                                              ||        || second point to extrapolate in front  |
||                                              ||        || and and a line through the last and   |
||                                              ||        || second-to-last point in the end.      |
||                                              ||        || 'global-linear': Uses a linear        |
||                                              ||        || regression to fit a line through all  |
||                                              ||        || data points and use it for            |
||                                              ||        || interpolation. (default:              |
||                                              ||        || 'four-point-linear' valid:            |
||                                              ||        || 'two-point-linear',                   |
||                                              ||        || 'four-point-linear', 'global-linear') |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_interpolated_interpolation_type || choice || Type of interpolation to apply.       |
|| (-model:interpolated:interpolation_type)     ||        || (default: 'cspline' valid: 'linear',  |
||                                              ||        || 'cspline', 'akima')                   |
+-----------------------------------------------+---------+----------------------------------------+
|| transform_rt_interpolated_extrapolation_type || choice || Type of extrapolation to apply:       |
|| (-model:interpolated:extrapolation_type)     ||        || two-point-linear: use the first and   |
||                                              ||        || last data point to build a single     |
||                                              ||        || linear model, four-point-linear:      |
||                                              ||        || build two linear models on both ends  |
||                                              ||        || using the first two / last two        |
||                                              ||        || points, global-linear: use all points |
||                                              ||        || to build a single linear model. Note  |
||                                              ||        || that global-linear may not be         |
||                                              ||        || continuous at the border. (default:   |
||                                              ||        || 'two-point-linear' valid:             |
||                                              ||        || 'two-point-linear',                   |
||                                              ||        || 'four-point-linear', 'global-linear') |
+-----------------------------------------------+---------+----------------------------------------+



FeatureLinkerUnlabeledQT (process: link_features)
#################################################

See `here <https://openms.de/doxygen/release/3.6.0/html/TOPP_FeatureLinkerUnlabeledQT.html>`_ for OpenMS's documentation of FeatureLinkerUnlabeledQT.


+-------------------------------------------------+---------+--------------------------------------+
| Parameter                                       | Type    | Description                          |
+=================================================+=========+======================================+
|| link_features_algorithm_use_identifications    || bool   ||                        Never link   |
|| (-algorithm:use_identifications)               ||        || features that are annotated with    |
||                                                ||        || different peptides (only the best   |
||                                                ||        || hit per peptide identification is   |
||                                                ||        || taken into account).                |
+-------------------------------------------------+---------+--------------------------------------+
|| link_features_algorithm_nr_partitions          || number || How many partitions in m/z space    |
|| (-algorithm:nr_partitions)                     ||        || should be used for the algorithm    |
||                                                ||        || (more partitions means faster       |
||                                                ||        || runtime and more memory efficient   |
||                                                ||        || execution). (default: '100' min:    |
||                                                ||        || '1')                                |
+-------------------------------------------------+---------+--------------------------------------+
|| link_features_algorithm_min_nr_diffs_per_bin   || number || If IDs are used: How many           |
|| (-algorithm:min_nr_diffs_per_bin)              ||        || differences from matching IDs       |
||                                                ||        || should be used to calculate a       |
||                                                ||        || linking tolerance for unIDed        |
||                                                ||        || features in an RT region. RT        |
||                                                ||        || regions will be extended until that |
||                                                ||        || number is reached. (default: '50'   |
||                                                ||        || min: '5')                           |
+-------------------------------------------------+---------+--------------------------------------+
|| link_features_algorithm_min_IDscore_forTolCalc || value  || If IDs are used: What is the        |
|| (-algorithm:min_IDscore_forTolCalc)            ||        || minimum score of an ID to assume a  |
||                                                ||        || reliable match for tolerance        |
||                                                ||        || calculation. Check your current     |
||                                                ||        || score type! (default: '1.0')        |
+-------------------------------------------------+---------+--------------------------------------+
|| link_features_algorithm_noID_penalty           || value  || If IDs are used: For the normalized |
|| (-algorithm:noID_penalty)                      ||        || distances, how high should the      |
||                                                ||        || penalty for missing IDs be? 0 = no  |
||                                                ||        || bias, 1 = IDs inside the max        |
||                                                ||        || tolerances always preferred (even   |
||                                                ||        || if much further away). (default:    |
||                                                ||        || '0.0' min: '0.0' max: '1.0')        |
+-------------------------------------------------+---------+--------------------------------------+
|| link_features_algorithm_ignore_adduct          || choice || True [default]: pairing requires    |
|| (-algorithm:ignore_adduct)                     ||        || equal adducts (or at least one      |
||                                                ||        || without adduct annotation); true:   |
||                                                ||        || Pairing irrespective of adducts     |
||                                                ||        || (default: 'true' valid: 'true',     |
||                                                ||        || 'false')                            |
+-------------------------------------------------+---------+--------------------------------------+



IDConflictResolver (process: resolve_conflict)
##############################################

See `here <https://openms.de/doxygen/release/3.6.0/html/TOPP_IDConflictResolver.html>`_ for OpenMS's documentation of IDConflictResolver.


+---------------------------------------------+---------------------------+------------------------+
| Parameter                                   | Type                      | Description            |
+=============================================+===========================+========================+
|| conflict_resolver_resolve_between_features || resolve_between_features || A map may contain     |
|| (-resolve_between_features)                ||                          || multiple features     |
||                                            ||                          || with both identical   |
||                                            ||                          || (possibly modified    |
||                                            ||                          || i.e. not stripped)    |
||                                            ||                          || sequence and charge   |
||                                            ||                          || state. The feature    |
||                                            ||                          || with the 'highest     |
||                                            ||                          || intensity' is very    |
||                                            ||                          || likely the most       |
||                                            ||                          || reliable one. When    |
||                                            ||                          || switched on, the      |
||                                            ||                          || filter removes the    |
||                                            ||                          || sequence annotation   |
||                                            ||                          || from the lower        |
||                                            ||                          || intensity features,   |
||                                            ||                          || thereby resolving the |
||                                            ||                          || multiplicity. Only    |
||                                            ||                          || the most reliable     |
||                                            ||                          || features for each     |
||                                            ||                          || (possibly modified    |
||                                            ||                          || i.e. not stripped)    |
||                                            ||                          || sequence maintain     |
||                                            ||                          || annotated with this   |
||                                            ||                          || peptide sequence.     |
||                                            ||                          || (default: 'off'       |
||                                            ||                          || valid: 'off',         |
||                                            ||                          || 'highest_intensity')  |
+---------------------------------------------+---------------------------+------------------------+



ProteinQuantifier (process: quantify_peptides)
##############################################

See `here <https://openms.de/doxygen/release/3.6.0/html/TOPP_ProteinQuantifier.html>`_ for OpenMS's documentation of ProteinQuantifier.


+----------------------------------------------+---------+-----------------------------------------+
| Parameter                                    | Type    | Description                             |
+==============================================+=========+=========================================+
|| protein_quantifier_best_charge               || bool   || Report peptide rows by fraction and    |
|| (-best_charge)                               ||        || charge; select one charge per peptide  |
||                                              ||        || for protein quantification. Fraction  |
||                                              ||        || aggregation is separate.               |
+----------------------------------------------+---------+-----------------------------------------+
|| protein_quantifier_consensus_normalize      || bool   ||               Scale peptide abundances |
|| (-consensus:normalize)                      ||        || so that medians of all samples are     |
||                                             ||        || equal                                  |
+----------------------------------------------+---------+-----------------------------------------+
|| protein_quantifier_fractions_aggregate      || choice || Combine fractions by sum (default) or |
|| (-fractions:aggregate)                       ||        || best (one fraction per peptide).      |
+----------------------------------------------+---------+-----------------------------------------+
|| protein_quantifier_format_separator         || sep    || Character(s) used to separate fields;  |
|| (-format:separator)                         ||        || by default, the 'tab' character is     |
||                                             ||        || used                                   |
+----------------------------------------------+---------+-----------------------------------------+
|| protein_quantifier_format_quoting           || method || Method for quoting of strings: 'none'  |
|| (-format:quoting)                           ||        || for no quoting, 'double' for quoting   |
||                                             ||        || with doubling of embedded quotes,      |
+----------------------------------------------+---------+-----------------------------------------+
|| protein_quantifier_format_replacement       || x      || If 'quoting' is 'none', used to        |
|| (-format:replacement)                       ||        || replace occurrences of the separator   |
||                                             ||        || in strings before writing (default:    |
||                                             ||        || '_')                                   |
+----------------------------------------------+---------+-----------------------------------------+

