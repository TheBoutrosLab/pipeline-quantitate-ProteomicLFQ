include { getOpenMSArgs } from "${moduleDir}/common"

PARAMETERS = [

]

FLAGS = [

]

PARAMETER_MAPPER = [
    'align_featureXML_id_reference_file': '-reference:file',
    'align_featureXML_id_reference_index': '-reference:index',
    'align_featureXML_id_design': '-design',
    'align_featureXML_id_algorithm_auto_reference': '-algorithm:auto_reference',
    'align_featureXML_id_algorithm_score_cutoff': '-algorithm:score_cutoff',
    'align_featureXML_id_algorithm_min_score': '-algorithm:min_score',
    'align_featureXML_id_algorithm_min_run_occur': '-algorithm:min_run_occur'
]

FLAG_MAPPER = [:]

process align_featureXML_id {
    container params.docker_image_openms_processing

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':', '/')}/",
        mode: 'copy',
        enabled: params.save_intermediate_files,
        pattern: "*.featureXML"

    publishDir "${params.process_log_dir}/${task.process.replace(':', '/')}-${task.index}/",
        mode: 'copy',
        pattern: '.command.*',
        saveAs: { "log${file(it).name}" }

    input:
        tuple(
            val(fraction),
            val(sample_names),
            file(input_featureXMLs)
        )

    output:
        tuple(
            val(fraction),
            val(ordered_sample_names),
            file("*.featureXML"),
            file("*.trafoXML")
        )
        file ".command.*"

    script:
    // Set -out and -trafo_out
    output_featureXMLs = ""
    output_trafoXMLs = ""
    sample_names = sample_names as Set
    ordered_sample_names = []
    suffixes = ['setSpectraPath', 'FeatureFinder', 'MapAligner']
    input_featureXMLs.each {itt->
        prefix = itt.baseName
        for (suffix in suffixes) {
            if (prefix.endsWith("_${suffix}")) {
                prefix = prefix.replace("_${suffix}", '')
                break
            }
        }
        index = prefix.lastIndexOf("_${fraction}")
        if (index > 0) {
            prefix = prefix.substring(0, index)
        }
        if (!(prefix in sample_names)) {
            throw new Exception("The prefix for the input featureXML file ${itt} can not be found in the input channel `sample_names` (${sample_names})")
        }
        ordered_sample_names.add(prefix)
        output_featureXMLs += " ${prefix}_MapAligner.featureXML"
        output_trafoXMLs += " ${prefix}_MapAligner.trafoXML"
    }

    extra_args = getOpenMSArgs(PARAMETERS, FLAGS, PARAMETER_MAPPER, FLAG_MAPPER)
    """
    MapAlignerIdentification \\
        -in ${input_featureXMLs} \\
        -out ${output_featureXMLs} \\
        -trafo_out ${output_trafoXMLs} \\
        -threads ${task.cpus} \\
        ${extra_args}
    """
}
