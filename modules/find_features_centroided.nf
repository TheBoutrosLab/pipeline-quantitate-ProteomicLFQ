include { getOpenMSArgs } from "${moduleDir}/common"

PARAMETERS = [

]

FLAGS = [

]

PARAMETER_MAPPER = [
    'find_features_centroided_algorithm_intensity_bins': '-algorithm:intensity:bins',
    'find_features_centroided_algorithm_mass_trace_mz_tolerance': '-algorithm:mass_trace:mz_tolerance',
    'find_features_centroided_algorithm_mass_trace_min_spectra': '-algorithm:mass_trace:min_spectra',
    'find_features_centroided_algorithm_mass_trace_max_missing': '-algorithm:mass_trace:max_missing',
    'find_features_centroided_algorithm_mass_trace_slope_bound': '-algorithm:mass_trace:slope_bound',
    'find_features_centroided_algorithm_isotopic_pattern_charge_low': '-algorithm:isotopic_pattern:charge_low',
    'find_features_centroided_algorithm_isotopic_pattern_charge_high': '-algorithm:isotopic_pattern:charge_high',
    'find_features_centroided_algorithm_isotopic_pattern_mz_tolerance': '-algorithm:isotopic_pattern:mz_tolerance',
    'find_features_centroided_algorithm_isotopic_pattern_intensity_percentage': '-algorithm:isotopic_pattern:intensity_percentage',
    'find_features_centroided_algorithm_isotopic_pattern_intensity_percentage_optional': '-algorithm:isotopic_pattern:intensity_percentage_optional',
    'find_features_centroided_algorithm_isotopic_pattern_optional_fit_improvement': '-algorithm:isotopic_pattern:optional_fit_improvement',
    'find_features_centroided_algorithm_isotopic_pattern_mass_window_width': '-algorithm:isotopic_pattern:mass_window_width',
    'find_features_centroided_algorithm_isotopic_pattern_abundance_12C': '-algorithm:isotopic_pattern:abundance_12C',
    'find_features_centroided_algorithm_isotopic_pattern_abundance_14N': '-algorithm:isotopic_pattern:abundance_14N',
    'find_features_centroided_algorithm_seed_min_score': '-algorithm:seed:min_score',
    'find_features_centroided_algorithm_fit_max_iterations': '-algorithm:fit:max_iterations',
    'find_features_centroided_algorithm_feature_min_score': '-algorithm:feature:min_score',
    'find_features_centroided_algorithm_feature_min_isotope_fit': '-algorithm:feature:min_isotope_fit',
    'find_features_centroided_algorithm_feature_min_trace_score': '-algorithm:feature:min_trace_score',
    'find_features_centroided_algorithm_feature_min_rt_span': '-algorithm:feature:min_rt_span',
    'find_features_centroided_algorithm_feature_max_rt_span': '-algorithm:feature:max_rt_span',
    'find_features_centroided_algorithm_feature_rt_shape': '-algorithm:feature:rt_shape',
    'find_features_centroided_algorithm_feature_max_intersection': '-algorithm:feature:max_intersection',
    'find_features_centroided_algorithm_feature_reported_mz': '-algorithm:feature:reported_mz',
    'find_features_centroided_algorithm_user_seed_rt_tolerance': '-algorithm:user-seed:rt_tolerance',
    'find_features_centroided_algorithm_user_seed_mz_tolerance': '-algorithm:user-seed:mz_tolerance',
    'find_features_centroided_algorithm_user_seed_min_score': '-algorithm:user-seed:min_score'
]

FLAG_MAPPER = [:]

process find_features_centroided {
    container params.docker_image_openms_processing

    publishDir "${params.final_output_dir}",
        mode: 'copy',
        pattern: "*.featureXML"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple(
            val(sample_name),
            val(fraction),
            file(mzML)
        )

    output:
        tuple(
            val(sample_name),
            val(fraction),
            file(featureXML)
        )
        file ".command.*"

    script:
    featureXML = "${mzML.baseName}_FeatureFinder.featureXML"
    extra_args = getOpenMSArgs(PARAMETERS, FLAGS, PARAMETER_MAPPER, FLAG_MAPPER)
    """
    FeatureFinderCentroided \\
        -in ${mzML} \\
        -out ${featureXML} \\
        -threads ${task.cpus} \\
        ${extra_args}
    """
}
