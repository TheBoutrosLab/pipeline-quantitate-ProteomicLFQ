
process set_consensusXMLColumnHeaders {
    container params.docker_image_pyopenms_processing
    containerOptions "-v ${projectDir}/src/:${projectDir}/src/"

    publishDir "${params.final_output_dir}",
        enabled: !(params.merge_featureXML && params.number_of_samples > 1 && params.fractionated),
        mode: 'copy',
        pattern: "*.consensusXML"

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files && params.merge_featureXML &&
            params.number_of_samples > 1 && params.fractionated,
        mode: 'copy',
        pattern: "*.consensusXML"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple(
            val(sample_name),
            val(fraction_number),
            val(column_headers),
            file(input_consensusXML)
        )

    output:
        tuple(val(sample_name), file(output_consensusXML))
        file ".command.*"

    script:
    output_consensusXML = "${sample_name}_setColumnHeaders.consensusXML"
    sample_names = column_headers instanceof List ? column_headers : [column_headers]
    all_samples = params.unique_sample_names.toList().sort().join(' ')
    fraction_label_arg = "'" + sample_name.toString().replace("'", "'\"'\"'") + "'"
    fraction_args = fraction_number > 0 ?
        "--fraction-id ${fraction_label_arg} --fraction-number ${fraction_number} --all-samples ${all_samples}" : ''
    """
    python ${projectDir}/src/SetConsensusColumnHeaders.py \\
        --input-path ${input_consensusXML} \\
        --output-path ${output_consensusXML} \\
        --sample-names ${sample_names.join(' ')} \\
        ${fraction_args}
    """
}
