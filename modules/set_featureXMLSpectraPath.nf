
process set_featureXMLSpectraPath {
    container params.docker_image_pyopenms_processing
    containerOptions params.project_script_mount_options

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files == true && params.merge_featureXML == true,
        mode: 'copy',
        pattern: "*.featureXML"

    publishDir "${params.final_output_dir}",
        enabled: params.merge_featureXML == false,
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
    output_featureXML = "${sample_name}_setSpectraPath.featureXML"
    """
    python ${projectDir}/src/SetFeatureXMLSpectraPath.py \\
        --input-path ${input_featureXMLs} \\
        --output-path ${output_featureXML} \\
        --spectra-path ${sample_name}
    """
}
