
process merge_featureXML {
    container params.docker_image_openms

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files,
        mode: 'copy',
        pattern: "*.featureXML"

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
    output_featureXML = "${sample_name}_FileMerger.featureXML"
    """
    FileMerger \\
        -in ${input_featureXMLs} \\
        -out ${output_featureXML} \\
        -annotate_file_origin \\
        -append_method append_rows \\
        -threads ${task.cpus}
    """
}
