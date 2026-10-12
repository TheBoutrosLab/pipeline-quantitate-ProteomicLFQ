include { getOpenMSArgs } from "${moduleDir}/common"

PARAMETERS = [

]

FLAGS = [

]

PARAMETER_MAPPER = [
    'normalize_consensusXMl_algorithm_type': '-algorithm_type',
    'normalize_consensusXMl_ratio_threshold': '-ratio_threshold',
]

FLAG_MAPPER = [
    'normalize_consensusXMl_accession_filter': '-accession_filter',
    'normalize_consensusXMl_description_filter': '-description_filter'
]

process normalize_ConsensusXML {
    container params.docker_image_openms

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':', '/')}/",
        mode: 'copy',
        enabled: params.save_intermediate_files,
        pattern: "*.consensusXML"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        file input_consensusXML

    output:
        file "*.consensusXML"
        file ".command.*"

    script:
    output_consensusXML = "${params.project_name}_normalized.consensusXML"
    extra_args = getOpenMSArgs(PARAMETERS, FLAGS, PARAMETER_MAPPER, FLAG_MAPPER)
    """
    ConsensusMapNormalizer \\
        -in ${input_consensusXML} \\
        -out ${output_consensusXML} \\
        -threads ${task.cpus} \\
        ${extra_args}
    """
}
