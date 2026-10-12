/**
* Split idXML file into separate fractions.
*/

process split_idXML {
    container params.docker_image_openms

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files,
        mode: 'copy',
        pattern: "${split_dir}/*.idXML"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple(
            val(sample_name),
            path(input_idxml)
        )

    output:
        tuple(
            val(sample_name),
            path("${split_dir}/*.idXML")
        )
        path ".command.*"

    script:
    split_dir = "split"
    """
    mkdir -p ${split_dir}
    IDRipper \\
        -in ${input_idxml} \\
        -out ${split_dir} \\
        -threads ${task.cpus}
    """
}

