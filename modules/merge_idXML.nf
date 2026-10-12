
process merge_idXML {
    container params.docker_image_openms

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files,
        mode: 'copy',
        pattern: "*.idXML"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple(
            val(fraction),
            val(sample_name),
            file(input_idxmls)
        )

    output:
        tuple(
            val(fraction),
            val(sample_name),
            file(output_idxml)
        )
        file ".command.*"

    script:
    output_idxml = params.ffid_strategy == 'merged' ? "${sample_name}_${fraction}_merged.idXML" : "${sample_name}_external.idXML"
    """
    IDMerger \\
        -in ${input_idxmls} \\
        -out ${output_idxml} \\
        -threads ${task.cpus}
    """
}
