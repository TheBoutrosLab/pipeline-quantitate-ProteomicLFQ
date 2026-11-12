nextflow.enable.dsl = 2

include { print_prelogue } from "${projectDir}/modules/common"

include { denovo } from "${projectDir}/modules/workflow_denovo"
include { ffid } from "${projectDir}/modules/workflow_ffid"

workflow {
    def featureInput = params.algorithm == 'de novo' && params.featureXML_entrypoint
    def inputCsv = featureInput ? params.featureXML_csv : params.mzML_csv
    def inputFiles = Channel.fromPath(inputCsv).splitCsv(header:true).collect()
        .flatMap { rows ->
            if (!rows) {
                throw new Exception("Empty input CSV: ${inputCsv}")
            }
            def numbers = [:]
            rows.collect { row ->
                def fractionId = row.fraction_id?.trim()
                if (!fractionId) {
                    throw new Exception("Missing fraction_id in ${inputCsv}: ${row}")
                }
                if (!numbers.containsKey(fractionId)) {
                    numbers[fractionId] = numbers.size() + 1
                }
                def path = featureInput ? row.featureXML : row.mzML
                [row.sample_name, fractionId, numbers[fractionId], file(path)]
            }
        }
    def idXMLs = Channel.fromPath(params.idXML_csv).splitCsv(header:true)
        .map { row -> [row.sample_name, file(row.idXML)] }
    print_prelogue()

    if (params.algorithm == 'de novo') {
        denovo(inputFiles, idXMLs)
    } else {
        ffid(inputFiles, idXMLs)
    }
}
