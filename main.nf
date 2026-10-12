nextflow.enable.dsl = 2

include { print_prelogue } from "${projectDir}/modules/common"

include { denovo } from "${projectDir}/modules/workflow_denovo"
include { ffid } from "${projectDir}/modules/workflow_ffid"

workflow {
    print_prelogue()

    if (params.algorithm == 'de novo') {
        denovo()
    } else {
        ffid()
    }
}
