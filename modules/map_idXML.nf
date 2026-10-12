include { getOpenMSArgs } from "${moduleDir}/common"

PARAMETERS = [

]

FLAGS = [

]

PARAMETER_MAPPER = [
    'map_idXML_rt_tolerance': '-rt_tolerance',
    'map_idXML_mz_tolerance': '-mz_tolerance',
    'map_idXML_mz_measure': '-mz_measure',
    'map_idXML_mz_reference': '-mz_reference',
    'map_idXML_ignore_charge': '-ignore_charge',
    'map_idXML_feature_use_centroid_rt': '-feature:use_centroid_rt',
    'map_idXML_feature_use_centroid_mz': '-feature:use_centroid_mz',
    'map_idXML_consensus_use_subelements': '-consensus:use_subelements',
    'map_idXML_consensus_annotate_ids_with_subelements': '-consensus:annotate_ids_with_subelements',
    'map_idXML_spectra_in': '-spectra:in'
]

FLAG_MAPPER = [:]

process map_idXML {
    container params.docker_image_openms

    publishDir "${params.final_output_dir}/IDMapper",
        mode: 'copy',
        enabled: params.merge_featureXML == false,
        pattern: "*.featureXML"

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files && params.merge_featureXML,
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
            file(idXML),
            file(input_featureXML)
        )

    output:
        tuple(
            val(sample_name),
            val(fraction),
            file(output_featureXML)
        )
        file ".command.*"

    script:
    output_featureXML = "${sample_name}_${fraction}_IDMapper.featureXML"
    extra_args = getOpenMSArgs(PARAMETERS, FLAGS, PARAMETER_MAPPER, FLAG_MAPPER)
    """
    IDMapper \\
        -id ${idXML} \\
        -in ${input_featureXML} \\
        -out ${output_featureXML} \\
        -threads ${task.cpus} \\
        ${extra_args}
    """
}
