/** Name peptide abundance columns from the quantified sample design. */
process reheader_PeptideQuantCSV {
    container params.docker_image_pyopenms
    containerOptions params.project_script_mount_options

    publishDir "${params.final_output_dir}",
        mode: 'copy',
        pattern: "*_ProteinQuantifier_peptide.csv"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple val(sample_name), path(peptide_raw), path(input_xml)

    output:
        tuple val(sample_name), path(peptide_out)
        file ".command.*"

    script:
    peptide_out = "${sample_name}_ProteinQuantifier_peptide.csv"
    """
    python ${projectDir}/src/ReheaderPeptideQuant.py \
        --input-csv ${peptide_raw} \
        --input-xml ${input_xml} \
        --sample-name '${sample_name}' \
        --output-csv ${peptide_out}
    """
}
