process merge_consensusXML {
    container params.docker_image_openms_processing

    publishDir "${params.final_output_dir}",
        mode: 'copy',
        pattern: "*.consensusXML"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple(val(sample_name), file(consensusXMLs))

    output:
        tuple(val(sample_name), file(output_file))
        file ".command.*"

    script:
    output_file = "${sample_name}_FileMerger.consensusXML"
    """
    FileMerger \\
        -in ${consensusXMLs} \\
        -out ${output_file} \\
        -threads ${task.cpus} \\
        -annotate_file_origin \\
        -append_method append_cols
    """
}
