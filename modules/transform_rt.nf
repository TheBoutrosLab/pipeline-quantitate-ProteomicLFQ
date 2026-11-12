include { getOpenMSArgs } from "${moduleDir}/common"

PARAMETERS = [

]

FLAGS = [

]

PARAMETER_MAPPER = [
    'transform_rt_model_type': '-model:type',
    'transform_rt_linear_symmetric_regression': '-model:linear:symmetric_regression',
    'transform_rt_linear_x_weight': '-model:linear:x_weight',
    'transform_rt_linear_y_weight': '-model:linear:y_weight',
    'transform_rt_linear_x_datum_min': '-model:linear:x_datum_min',
    'transform_rt_linear_x_datum_max': '-model:linear:x_datum_max',
    'transform_rt_linear_y_datum_min': '-model:linear:y_datum_min',
    'transform_rt_linear_y_datum_max': '-model:linear:y_datum_max',
    'transform_rt_b_spline_wavelength': '-model:b_spline:wavelength',
    'transform_rt_b_spline_num_nodes': '-model:b_spline:num_nodes',
    'transform_rt_b_spline_extrapolate': '-model:b_spline:extrapolate',
    'transform_rt_b_spline_boundary_condition': '-model:b_spline:boundary_condition',
    'transform_rt_lowess_span': '-model:lowess:span',
    'transform_rt_lowess_num_iterations': '-model:lowess:num_iterations',
    'transform_rt_lowess_delta': '-model:lowess:delta',
    'transform_rt_lowess_interpolation_type': '-model:lowess:interpolation_type',
    'transform_rt_lowess_extrapolation_type': '-model:lowess:extrapolation_type',
    'transform_rt_interpolated_interpolation_type': '-model:interpolated:interpolation_type',
    'transform_rt_interpolated_extrapolation_type': '-model:interpolated:extrapolation_type'
]

FLAG_MAPPER = [
    'transform_rt_invert': '-invert',
    'transform_rt_store_original_rt': '-store_original_rt'
]

process transform_rt {
    container params.docker_image_openms_processing

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':','/')}",
        enabled: params.save_intermediate_files,
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
            file(input_featureXML),
            file(input_trafoXML)
        )

    output:
        tuple(
            val(sample_name),
            val(fraction),
            file(output_featureXML)
        )
        file ".command.*"

    script:
    output_featureXML = "${sample_name}_${fraction}_MapRTTransformer.featureXML"
    extra_args = getOpenMSArgs(PARAMETERS, FLAGS, PARAMETER_MAPPER, FLAG_MAPPER)
    """
    MapRTTransformer \\
        -in ${input_featureXML} \\
        -trafo_in ${input_trafoXML} \\
        -out ${output_featureXML} \\
        -threads ${task.cpus} \\
        ${extra_args}
    """
}
