include { getOpenMSArgs } from "${moduleDir}/common"

PARAMETERS = [

]

FLAGS = [

]

PARAMETER_MAPPER = [
    'align_idXML_reference_file': '-reference:file',
    'align_idXML_reference_index': '-reference:index',
    'align_idXML_design': '-design',
    'align_idXML_algorithm_score_cutoff': '-algorithm:score_cutoff',
    'align_idXML_algorithm_min_score': '-algorithm:min_score',
    'align_idXML_algorithm_min_run_occur': '-algorithm:min_run_occur'
]

FLAG_MAPPER = [:]

process align_idXML {
    container params.docker_image_openms

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files,
        mode: 'copy',
        pattern: "*_aligned.idXML"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple(
            val(fraction_id),
            val(sample_name),
            file(input_idXML)
        )

    output:
        tuple(
            val(fraction_id),
            file("*_aligned.idXML")
        )
        file ".command.*"

    script:
    output_idXML = ""
    sample_name.each {itt->
        output_idXML += " ${itt}_aligned.idXML"
    }
    extra_args = getOpenMSArgs(PARAMETERS, FLAGS, PARAMETER_MAPPER, FLAG_MAPPER)
    """
    MapAlignerIdentification \\
        -in ${input_idXML} \\
        -out ${output_idXML} \\
        -threads ${task.cpus} \\
        ${extra_args}
    """
}
