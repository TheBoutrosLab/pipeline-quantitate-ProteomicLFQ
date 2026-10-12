include { getOpenMSArgs } from "${moduleDir}/common"

PARAMETERS = []

FLAGS = []

PARAMETER_MAPPER = [
    'protein_quantifier_format_separator': '-format:separator',
    'protein_quantifier_format_quoting': '-format:quoting',
    'protein_quantifier_format_replacement': '-format:replacement'
]

FLAG_MAPPER = [
    'protein_quantifier_best_charge_and_fraction': '-best_charge_and_fraction',
    'protein_quantifier_consensus_normalize': '-consensus:normalize',
    'protein_quantifier_ratios': '-ratios'
]

process quantify_peptides {
    container params.docker_image_openms

    publishDir "${params.final_output_dir}/ProteinQuantifier",
        mode: 'copy',
        pattern: "*.csv"

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files,
        mode: 'copy',
        pattern: "*.csv"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple( val(sample_name), path(input_xml))

    output:
        tuple val(sample_name), path(peptide_out), optional: true
        file ".command.*"

    script:
    peptide_out = "${sample_name}_ProteinQuantifier_peptide.csv"
    extra_args = getOpenMSArgs(PARAMETERS, FLAGS, PARAMETER_MAPPER, FLAG_MAPPER)
    """
    ProteinQuantifier \\
        -in ${input_xml} \\
        -peptide_out ${peptide_out} \\
        -threads ${task.cpus} \\
        ${extra_args} \\
        || true

    # This is when ProteinQuantifier fails to quantify any peptide from the featureXML file.
    if grep -e "Error: Unexpected internal error (No protein matches found, cannot quantify proteins.)" .command.err; then
        exit 0
    elif [[ ! -f "$peptide_out" ]]; then
        exit 1
    fi
    """
}
