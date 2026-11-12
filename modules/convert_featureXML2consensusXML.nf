
process convert_featureXML2consensusXML {
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
            val(sample_name),
            file(input_featureXMLs)
        )

    output:
        tuple(
            val(sample_name),
            file(output_featureXML)
        )
        file ".command.*"

    script:
    output_featureXML = "${sample_name}.consensusXML"
    """
    FileConverter \\
        -in ${input_featureXMLs} \\
        -out ${output_featureXML} \\
        -threads ${task.cpus}
    """
}
