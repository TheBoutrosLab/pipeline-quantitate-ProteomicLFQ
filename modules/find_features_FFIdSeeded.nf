include { getOpenMSArgs } from "${moduleDir}/common"

PARAMETER_MAPPER = [
    'find_features_ident_extract_batch_size': '-extract:batch_size',
    'find_features_ident_extract_mz_window': '-extract:mz_window',
    'find_features_ident_extract_n_isotopes': '-extract:n_isotopes',
    'find_features_ident_extract_rt_window': '-extract:rt_window',
    'find_features_ident_detect_min_peak_width': '-detect:min_peak_width',
    'find_features_ident_detect_signal_to_noise': '-detect:signal_to_noise',
    'find_features_ident_detect_peak_width': '-detect:peak_width',
    'find_features_ident_detect_mapping_tolerance': '-detect:mapping_tolerance',
    'find_features_ident_model_type': '-model:type',
    'find_features_ident_EMGScoring_max_iteration': '-EMGScoring:max_iteration',
    'find_features_ident_EMGScoring_init_mom': '-EMGScoring:init_mom',
    'find_features_ident_min_psm_cutoff': '-min_psm_cutoff',
    'find_features_ident_add_mass_offset_peptides': '-add_mass_offset_peptides',
    'find_features_ident_seed_apex_rt_tolerance': '-seed_apex_rt_tolerance',
    'find_features_ident_extract_isotope_pmin': '-extract:isotope_pmin'
]

FLAG_MAPPER = [
    'find_features_ident_quantify_decoys': '-quantify_decoys'
]

process find_features_FFIdSeeded {
    container params.docker_image_pyopenms_processing
    containerOptions "-v ${projectDir}/src/:${projectDir}/src/"

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files,
        mode: 'copy',
        pattern: '*.featureXML'

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple val(sample_name), val(fraction), path(mzML), path(idXML), path(seeds)

    output:
        tuple val(sample_name), val(fraction), path(featureXML)
        path '.command.*'

    script:
    featureXML = "${sample_name}_${fraction}_FeatureFinder.featureXML"
    extra_args = getOpenMSArgs([], [], PARAMETER_MAPPER, FLAG_MAPPER)
    """
    export OMP_NUM_THREADS=${task.cpus}
    python ${projectDir}/src/FeatureFinderIdentification.py \
        -in ${mzML} \
        -id ${idXML} \
        -seeds ${seeds} \
        -out ${featureXML} \
        -threads ${task.cpus} \
        ${extra_args}
    """
}
