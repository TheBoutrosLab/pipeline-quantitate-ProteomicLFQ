process seed_features_FFMultiplex {
    container params.docker_image_pyopenms_processing
    containerOptions params.project_script_mount_options

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files,
        mode: 'copy',
        pattern: '*.featureXML'

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple val(sample_name), val(fraction), path(mzML)

    output:
        tuple val(sample_name), val(fraction), path(seed_featureXML)
        path '.command.*'

    script:
    seed_featureXML = "${sample_name}_${fraction}_FFMultiplex_seed.featureXML"
    """
    export OMP_NUM_THREADS=${task.cpus}
    python ${projectDir}/src/FeatureFinderMultiplex.py \\
        -in ${mzML} \\
        -out ${seed_featureXML} \\
        -threads ${task.cpus} \\
        -threshold_mower:threshold ${params.ffmultiplex_intensity_threshold} \\
        -algorithm:charge ${params.ffmultiplex_min_charge}:${params.ffmultiplex_max_charge}
    """
}
