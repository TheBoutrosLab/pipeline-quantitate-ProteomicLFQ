include { getOpenMSArgs } from "${moduleDir}/common"

PARAMETERS = [

]

FLAGS = [

]

PARAMETER_MAPPER = [
    'find_features_ident_quantify_decoys': '-quantify_decoys',
    'find_features_ident_extract_batch_size': '-extract:batch_size',
    'find_features_ident_extract_mz_window': '-extract:mz_window',
    'find_features_ident_extract_n_isotopes': '-extract:n_isotopes',
    'find_features_ident_extract_rt_window': '-extract:rt_window',
    'find_features_ident_detect_min_peak_width': '-detect:min_peak_width',
    'find_features_ident_detect_signal_to_noise': '-detect:signal_to_noise',
    'find_features_ident_detect_peak_width': '-detect:peak_width',
    'find_features_ident_detect_mapping_tolerance': '-detect:mapping_tolerance',
    'find_features_ident_svm_samples': '-svm:samples',
    'find_features_ident_svm_no_selection': '-svm:no_selection',
    'find_features_ident_svm_xval_out': '-svm:xval_out',
    'find_features_ident_svm_kernel': '-svm:kernel',
    'find_features_ident_svm_xval': '-svm:xval',
    'find_features_ident_svm_log2_C': '-svm:log2_C',
    'find_features_ident_svm_log2_gamma': '-svm:log2_gamma',
    'find_features_ident_model_type': '-model:type',
    'find_features_ident_EMGScoring_max_iteration': '-EMGScoring:max_iteration',
    'find_features_ident_EMGScoring_init_mom': 'EMGScoring:init_mom'
]

FLAG_MAPPER = [:]

process find_features_id {
    container params.docker_image_openms

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files,
        mode: 'copy',
        pattern: "*.featureXML"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    // Ignore it if no PSMs left after filtering #67
    errorStrategy {
        def log_file = task.workDir/'.command.log'
        def strategy = 'terminate'
        log_file.eachLine { line -> 
            if (line ==~ /Error: Unexpected internal error \(No features provided.\)/) {
            strategy = 'ignore'
            return
            }
        }
        return strategy
    }

    input:
        tuple(
            val(sample_name),
            val(fraction),
            file(mzML),
            file(idXML),
            file(external_idXML)
        )

    output:
        tuple(
            val(sample_name),
            val(fraction),
            file(featureXML)
        )
        file ".command.*"

    script:
    featureXML = "${sample_name}_${fraction}_FeatureFinder.featureXML"
    extra_args = getOpenMSArgs(PARAMETERS, FLAGS, PARAMETER_MAPPER, FLAG_MAPPER)
    id_ext_arg = external_idXML.name == 'NO_FILE' ? '' : "-id_ext ${external_idXML}"
    """
    FeatureFinderIdentification \\
        -in ${mzML} \\
        -id ${idXML} \\
        ${id_ext_arg} \\
        -out ${featureXML} \\
        -threads ${task.cpus} \\
        ${extra_args}
    """
}
