include { findSingleFractionIdXML; externalAlignedIdXMLs } from "${projectDir}/modules/common"
include { split_idXML } from "${projectDir}/modules/split_idXML"
include { find_features_id } from "${projectDir}/modules/find_features_id"
include { align_featureXML_id } from "${projectDir}/modules/align_featureXML_id"
include { align_idXML } from "${projectDir}/modules/align_idXML"
include { merge_idXML } from "${projectDir}/modules/merge_idXML"
include { transform_rt } from "${projectDir}/modules/transform_rt"
include { link_features } from "${projectDir}/modules/link_features"
include { merge_consensusXML } from "${projectDir}/modules/merge_consensusXML"
include { merge_featureXML } from "${projectDir}/modules/merge_featureXML"
include { convert_featureXML2consensusXML } from "${projectDir}/modules/convert_featureXML2consensusXML"
include { set_consensusXMLColumnHeaders } from "${projectDir}/modules/set_consensusXMLColumnHeaders"
include { set_featureXMLSpectraPath } from "${projectDir}/modules/set_featureXMLSpectraPath"
include { resolve_conflict } from "${projectDir}/modules/resolve_conflict"
include { quantify_peptides } from "${projectDir}/modules/quantify_peptides"
include { reheader_PeptideQuantCSV } from "${projectDir}/modules/reheader_PeptideQuantCSV"

workflow ffid {
    take:
    ich_mzML_files
    ich_idXML

    main:
    ich_fraction_numbers = ich_mzML_files.map { sample, fractionId, number, inputFile ->
        [params.fractionated ? fractionId : 1, number]
    }.unique()
    ich_mzML = ich_mzML_files.map { sample, fractionId, number, mzML ->
        [sample, params.fractionated ? fractionId : 1, mzML]
    }

    // Create pairs of mzML and idXML for each fraction.
    if (params.fractionated) {
        split_idXML(ich_idXML)
        /*
         * ich_fraction_mzML_idXML:
         *  [
         *      [sample_1, fraction_1, 1-1.mzML, 1-1.idXML]
         *  ]
         */
        ich_fraction_mzML_idXML = ich_mzML // [sample_name, fraction_id, mzML]
            .map { [it[0], [it[1], it[2]]] }
            .groupTuple(by:0)
            .join(split_idXML.out[0], by:0)
            .map {[it]}
            .collect()
            .map { merged_data ->
                data = []
                merged_data.each { it ->
                    sample_name = it[0]
                    fractionated_mzMLs = it[1]
                    idXMLs = it[2]
                    // If there is only one file, nextflow doesn't treat it as a list.
                    if (! (idXMLs in List)) {
                        idXMLs = [idXMLs]
                    }
                    pairs = []

                    // Require one split idXML for every mzML fraction.
                    fractionated_mzMLs.each { fraction_id, mzML ->
                        prefix = mzML.baseName
                        matched_idXML = findSingleFractionIdXML(
                            sample_name, fraction_id, mzML, prefix, idXMLs
                        )
                        pairs.add([
                            'sample_name': sample_name,
                            'fraction_id': fraction_id,
                            'mzML': mzML,
                            'idXML': matched_idXML
                        ])
                    }

                    data += pairs
                }
                return data
            }
            .flatten()
            .map {[it['sample_name'], it['fraction_id'], it['mzML'], file(it['idXML'].toRealPath())]}
    } else {
        ich_fraction_mzML_idXML = ich_mzML
            .join(ich_idXML, by:0)
    }

    if (params.ffid_strategy == 'merged') { // ffid internal & external id

        ich_fraction_group_mzML_idXML = ich_fraction_mzML_idXML
            .map { [it[1], it[0], it[2], it[3]] }
            .groupTuple(by: 0) // [[fraction, [sample_1, sample_2], [1.mzML, 2.mzML], [1.idXML, 2.idXML]]]

        ich_fraction_idXMLs = ich_fraction_group_mzML_idXML
            .map { [it[0], it[1], it[3]] }
        align_idXML(ich_fraction_idXMLs)

        merge_idXML(align_idXML.out[0].map {[it[0], params.project_name, it[1]]})

        ich_sample_fraction_mzML_idXML_external = ich_fraction_group_mzML_idXML
            .map { [it[0], it[1], it[2]] }
            .join(merge_idXML.out[0].map{[it[0], it[2]]}) // [[fraction, [sample_1,..], [mzML_1,..], idXML_1]]
            .map { it ->
                data = []
                it[1].eachWithIndex { sample_name, i ->
                    entry = [
                        'sample_name': sample_name,
                        'fraction': it[0],
                        'mzML': it[2][i],
                        'idXML': it[3]
                    ]
                    data.add(entry)
                }
                return data
            }
            .flatten()
            .map { [it['sample_name'], it['fraction'], it['mzML'], it['idXML'], file("${projectDir}/input/NO_FILE")] }

        // FeatureFinderdentification: merge internal and exteranl PSMs when building the SVM
        // classifier
        find_features_id(ich_sample_fraction_mzML_idXML_external)

    } else if (params.ffid_strategy == 'machine_learning') { // ffid mechine learning
        ich_fraction_group_mzML_idXML = ich_fraction_mzML_idXML
            .map { [it[1], it[0], it[2], it[3]] }
            .groupTuple(by: 0) // [[fraction, [sample_1, sample_2], [1.mzML, 2.mzML], [1.idXML, 2.idXML]]]

        ich_fraction_idXMLs = ich_fraction_group_mzML_idXML
            .map { [it[0], it[1], it[3]] }
        align_idXML(ich_fraction_idXMLs)

        ich_unique_samples = ich_idXML
            .map { it[0] }
            .unique()

        ich_aligned_idXMLs = ich_unique_samples
            .combine(align_idXML.out[0])
            .map {
                external_idXMLs = externalAlignedIdXMLs(it[0], it[2])
                return [it[1], it[0], external_idXMLs]
            }
        merge_idXML(ich_aligned_idXMLs)

        // replace intial idXML with aligned idXML, then use the merged idXML of other samples as
        // external idXML
        ich_sample_fraction_mzML_idXML_external = ich_fraction_mzML_idXML
            .join(
                merge_idXML.out[0].map({[it[1], it[0], it[2]]}) ,
                by: [0,1]
            )

        // FeatureFinderdentification: separate internal and exteranl PSMs when building the SVM
        // classifier
        find_features_id(ich_sample_fraction_mzML_idXML_external)

    } else { // ffid internal only
        // // FeatureFinderIdentification: Find features using internal PSMs
        ich_sample_fraction_mzML_idXML_external = ich_fraction_mzML_idXML
            .map { [it[0], it[1], it[2], it[3], file("${projectDir}/input/NO_FILE")] }
        find_features_id(ich_sample_fraction_mzML_idXML_external)
    }

    if (params.merge_featureXML) {
        if (params.number_of_samples > 1) {
            ich_fraction_group_featureXML = find_features_id.out[0]
                .map { [it[1], it[0], it[2]] }
                .groupTuple(by:0)

            // MapAlignerIdentification: resolve RT transformation
            align_featureXML_id(ich_fraction_group_featureXML)
            ich_fraction_sample_featureXML_trafoXML = align_featureXML_id.out[0]
                .map { it ->
                    data = []
                    it[1].eachWithIndex { sample_name, i ->
                        if (it[1].size() == 1) {
                            featureXML = it[2]
                            trafoXML = it[3]
                        } else {
                            featureXML = it[2][i]
                            trafoXML = it[3][i]
                        }
                        data.add([
                            'sample_name': sample_name,
                            'fraction': it[0],
                            'featureXML': featureXML,
                            'trafoXML': trafoXML
                        ])
                    }
                    return data
                }
                .flatten()
                .map { [it['sample_name'], it['fraction'], it['featureXML'], it['trafoXML']] }

            // MapRTTransformer: apply RT transfomation
            transform_rt(ich_fraction_sample_featureXML_trafoXML)

            ich_fraction_transformed_featureXML = transform_rt.out[0]
                .map { [it[1], [it[0], it[2]]] }
                .groupTuple(by:0, sort: {it[0]})
                .map {fraction_id, vals -> {
                    sample_ids = []
                    filepaths = []
                    vals.each{sample_id, filepath -> {
                            sample_ids.add(sample_id)
                            filepaths.add(filepath)
                        }
                    }
                    return [fraction_id, sample_ids, filepaths]
                }}
            // FeatureLinkerUnlabeledQT: combine featureXMLs to consensusXML
            link_features(ich_fraction_transformed_featureXML)
            ch_fraction_consensusXML = link_features.out[0]
                .join(ich_fraction_numbers, by: 0)
                .map { fractionId, sampleNames, consensusXML, number ->
                    [fractionId, params.fractionated ? number : 0, sampleNames, consensusXML]
                }
            set_consensusXMLColumnHeaders(ch_fraction_consensusXML)

            if (params.fractionated) {
                ch_fraction_consensusXMLs = set_consensusXMLColumnHeaders.out[0]
                    .map { it[1] }
                    .collect()
                    .map { files -> [params.project_name, files.sort { it.name }] }
                merge_consensusXML(ch_fraction_consensusXMLs)
                ich_sample_consensusXML = merge_consensusXML.out[0]
            } else {
                ich_sample_consensusXML = set_consensusXMLColumnHeaders.out[0]
            }
        } else {
            if (params.fractionated) {
                ich_sample_featureXMLs = find_features_id.out[0]
                    .map { [it[0], it[2]] }
                    .groupTuple(by:0) // [sample_name, [f1.featureXML, f2.featureXML]]
                merge_featureXML(ich_sample_featureXMLs)

                set_featureXMLSpectraPath(merge_featureXML.out[0])
                convert_featureXML2consensusXML(set_featureXMLSpectraPath.out[0])
                ch_sample_consensusXML = convert_featureXML2consensusXML.out[0]
                    .map { [it[0], it[0], it[1]] }

                set_consensusXMLColumnHeaders(ch_sample_consensusXML.map { [it[0], 0, it[1], it[2]] })
                ich_sample_consensusXML = set_consensusXMLColumnHeaders.out[0]
            } else {
                convert_featureXML2consensusXML(find_features_id.out[0].map { [it[0], it[2]] })
                ch_sample_consensusXML = convert_featureXML2consensusXML.out[0]
                    .map { [it[0], it[0], it[1]] }

                set_consensusXMLColumnHeaders(ch_sample_consensusXML.map { [it[0], 0, it[1], it[2]] })
                ich_sample_consensusXML = set_consensusXMLColumnHeaders.out[0]
            }
        }
        // ConflictResolver
        resolve_conflict(ich_sample_consensusXML)

        // ProteinQuantfier: quantify peptides
        quantify_peptides(resolve_conflict.out[0])
        reheader_PeptideQuantCSV(quantify_peptides.out[0])
    } else {
        // Merge fractions
        ich_sample_featureXMLs = find_features_id.out[0]
            .map { [it[0], it[2]] }
            .groupTuple(by:0)
        merge_featureXML(ich_sample_featureXMLs)

        set_featureXMLSpectraPath(merge_featureXML.out[0])
        quantify_peptides(set_featureXMLSpectraPath.out[0])
        reheader_PeptideQuantCSV(quantify_peptides.out[0])
    }
}
