process filter_FeatureXMLMapped {
    container params.docker_image_pyopenms
    containerOptions "-v ${projectDir}/src/:${projectDir}/src/"

    publishDir "${params.final_output_dir}",
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
            file(input_featureXML)
        )

    output:
        file output_featureXML
        file ".command.*"

    script:
    output_prefix = input_featureXML.baseName
    if (output_prefix.endsWith('_IDMapper')) {
        output_prefix = output_prefix.substring(0, output_prefix.lastIndexOf('_'))
    }
    output_featureXML = "${output_prefix}_filtered.featureXML"
    """
    python ${projectDir}/src/FeatureXMLIDRemover.py \\
        --input-path ${input_featureXML} \\
        --output-path ${output_featureXML}
    """
}
