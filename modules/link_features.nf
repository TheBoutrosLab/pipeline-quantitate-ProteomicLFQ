include { getOpenMSArgs } from "${moduleDir}/common"

PARAMETERS = [

]

FLAGS = [

]

PARAMETER_MAPPER = [
    'link_features_algorithm_use_identifications': '-algorithm:use_identifications',
    'link_features_algorithm_nr_partitions': '-algorithm:nr_partitions',
    'link_features_algorithm_min_nr_diffs_per_bin': '-algorithm:min_nr_diffs_per_bin',
    'link_features_algorithm_min_IDscore_forTolCalc': '-algorithm:min_IDscore_forTolCalc',
    'link_features_algorithm_noID_penalty': '-algorithm:noID_penalty',
    'link_features_algorithm_noID_penalty': '-algorithm:noID_penalty',
    'link_features_algorithm_ignore_adduct': '-algorithm:ignore_adduct',
    'link_features_distance_RT_max_difference': '-algorithm:distance_RT:max_difference',
    'link_features_distance_RT_exponent': '-algorithm:distance_RT:exponent',
    'link_features_distance_RT_weight': '-algorithm:distance_RT:weight',
    'link_features_distance_MZ_max_difference': '-algorithm:distance_MZ:max_difference',
    'link_features_distance_MZ_unit': '-algorithm:distance_MZ:unit',
    'link_features_distance_MZ_exponent': '-algorithm:distance_MZ:exponent',
    'link_features_distance_MZ_weight': '-algorithm:distance_MZ:weight',
    'link_features_distance_intensity_exponent': '-algorithm:distance_intensity:exponent',
    'link_features_distance_intensity_weight': '-algorithm:distance_intensity:weight',
    'link_features_distance_intensity_log_transform': '-algorithm:distance_intensity:log_transform'
]

FLAG_MAPPER = [:]

process link_features {
    container params.docker_image_openms_processing

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files,
        mode: 'copy',
        pattern: "*.consensusXML"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple(
            val(fraction),
            val(sample_ids),
            file(featureXMLs)
        )

    output:
        tuple(
            val(fraction),
            val(sample_ids),
            file(consensusXML)
        )
        file ".command.*"

    script:
    consensusXML = "${params.project_name}_${fraction}_FeatureLinkerUnlabeledQT.consensusXML"
    extra_args = getOpenMSArgs(PARAMETERS, FLAGS, PARAMETER_MAPPER, FLAG_MAPPER)
    """
    FeatureLinkerUnlabeledQT \\
        -in ${featureXMLs} \\
        -out ${consensusXML} \\
        -threads ${task.cpus} \\
        ${extra_args}
    """
}
