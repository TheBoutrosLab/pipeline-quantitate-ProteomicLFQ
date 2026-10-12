
process set_consensusXMLColumnHeaders {
    container params.docker_image_msptools

    publishDir "${params.final_output_dir}/MSPtools_ConsensusXML_setColumnHeaders",
        mode: 'copy',
        pattern: "*.consensusXML"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple(
            val(sample_name),
            val(column_headers),
            file(input_consensusXML)
        )

    output:
        tuple(val(sample_name), file(output_consensusXML))
        file ".command.*"

    script:
    output_consensusXML = "${sample_name}_setColumnHeaders.consensusXML"
    column_headers = column_headers in List ? column_headers.join(' ') : column_headers
    """
    msptools ConsensusXML setColumnHeaders \\
        --input-path ${input_consensusXML} \\
        --output-path ${output_consensusXML} \\
        --column-headers ${column_headers}
    """
}
