include { getOpenMSArgs } from "${moduleDir}/common"

PARAMETERS = [

]

FLAGS = [

]

PARAMETER_MAPPER = [
    'align_featureXML_pc_reference_file': '-reference:file',
    'align_featureXML_pc_reference_index': '-reference:index',
    'align_featureXML_pc_algorithm_max_num_peaks_considered': '-algorithm:max_num_peaks_considered',
    'align_featureXML_pc_algorithm_superimposer_mz_pair_max_distance': '-algorithm:superimposer:mz_pair_max_distance',
    'align_featureXML_pc_algorithm_superimposer_rt_pair_distance_fraction': '-algorithm:superimposer:rt_pair_distance_fraction',
    'align_featureXML_pc_algorithm_superimposer_num_used_points': '-algorithm:superimposer:num_used_points',
    'align_featureXML_pc_algorithm_superimposer_scaling_bucket_size': '-algorithm:superimposer:scaling_bucket_size',
    'align_featureXML_pc_algorithm_superimposer_shift_bucket_size': '-algorithm:superimposer:shift_bucket_size',
    'align_featureXML_pc_algorithm_superimposer_max_shift': '-algorithm:superimposer:max_shift',
    'align_featureXML_pc_algorithm_superimposer_max_scaling': '-algorithm:superimposer:max_scaling',
    'align_featureXML_pc_algorithm_superimposer_dump_buckets': '-algorithm:superimposer:dump_buckets',
    'align_featureXML_pc_algorithm_superimposer_dump_pairs': '-algorithm:superimposer:dump_pairs',

    'align_featureXML_pc_algorithm_pairfinder_second_nearest_gap': '-algorithm:pairfinder:second_nearest_gap',
    'align_featureXML_pc_algorithm_pairfinder_use_identifications': '-algorithm:pairfinder:use_identifications',
    'align_featureXML_pc_algorithm_pairfinder_ignore_charge': '-algorithm:pairfinder:ignore_charge',
    'align_featureXML_pc_algorithm_pairfinder_ignore_adduct': '-algorithm:pairfinder:ignore_adduct',
    'align_featureXML_pc_algorithm_pairfinder_distance_RT_max_difference': '-algorithm:pairfinder:distance_RT:max_difference',
    'align_featureXML_pc_algorithm_pairfinder_distance_RT_exponent': '-algorithm:pairfinder:distance_RT:exponent',
    'align_featureXML_pc_algorithm_pairfinder_distance_RT_weight': '-algorithm:pairfinder:distance_RT:weight',
    'align_featureXML_pc_algorithm_pairfinder_distance_MZ_max_difference': '-algorithm:pairfinder:distance_MZ:max_difference',
    'align_featureXML_pc_algorithm_pairfinder_distance_MZ_unit': '-algorithm:pairfinder:distance_MZ:unit',
    'align_featureXML_pc_algorithm_pairfinder_distance_MZ_exponent': '-algorithm:pairfinder:distance_MZ:exponent',
    'align_featureXML_pc_algorithm_pairfinder_distance_MZ_weight': '-algorithm:pairfinder:distance_MZ:weight',
    'align_featureXML_pc_algorithm_pairfinder_distance_intensity_exponent': '-algorithm:pairfinder:distance_intensity:exponent',
    'align_featureXML_pc_algorithm_pairfinder_distance_intensity_weight': '-algorithm:pairfinder:distance_intensity:weight',
    'align_featureXML_pc_algorithm_pairfinder_distance_intensity_log_transform': '-algorithm:pairfinder:distance_intensity:log_transform'
]

FLAG_MAPPER = [:]

process align_featureXML_pc {
    container params.docker_image_openms

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':', '/')}/",
        mode: 'copy',
        enabled: params.save_intermediate_files,
        pattern: "*.featureXML"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        file input_featureXML

    output:
        file "*.featureXML"
        file "*.trafoXML"
        file ".command.*"

    script:
    output_featureXML = ""
    output_trafoXML = ""
    input_featureXML.each {itt->
        output_featureXML += " ${itt.baseName.replace('_FeatureFinder', '_MapAligner')}.featureXML"
        output_trafoXML += " ${itt.baseName.replace('_FeatureFinder', '_MapAligner')}.trafoXML"
    }
    extra_args = getOpenMSArgs(PARAMETERS, FLAGS, PARAMETER_MAPPER, FLAG_MAPPER)
    """
    MapAlignerPoseClustering \\
        -in ${input_featureXML} \\
        -out ${output_featureXML} \\
        -trafo_out ${output_trafoXML} \\
        -threads ${task.cpus} \\
        ${extra_args}
    """
}
