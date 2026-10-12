nextflow.enable.dsl = 2

include { quantify_peptides } from "${projectDir}/../../modules/quantify_peptides"

workflow {
    ich = Channel.from([['UCLA0001', file("${projectDir}/test.featureXML")]])
    quantify_peptides(ich)
}
