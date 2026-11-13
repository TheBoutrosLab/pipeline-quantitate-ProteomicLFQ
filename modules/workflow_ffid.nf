include { findSingleFractionIdXML } from "${projectDir}/modules/common"
include { split_idXML } from "${projectDir}/modules/split_idXML"
include { find_features_FFId } from "${projectDir}/modules/find_features_FFId"
include { seed_features_FFMultiplex } from "${projectDir}/modules/seed_features_FFMultiplex"
include { find_features_FFIdSeeded } from "${projectDir}/modules/find_features_FFIdSeeded"
include { align_featureXML_id } from "${projectDir}/modules/align_featureXML_id"
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

    if (params.enable_mbr) {
        seed_features_FFMultiplex(ich_fraction_mzML_idXML.map { sample, fraction, mzML, idXML ->
            [sample, fraction, mzML]
        })
        ich_seeded_input = ich_fraction_mzML_idXML
            .join(seed_features_FFMultiplex.out[0], by: [0, 1], failOnMismatch: true)
            .map { sample, fraction, mzML, idXML, seeds ->
                [sample, fraction, mzML, idXML, seeds]
            }
        find_features_FFIdSeeded(ich_seeded_input)
        ich_featureXML = find_features_FFIdSeeded.out[0]
    } else {
        find_features_FFId(ich_fraction_mzML_idXML)
        ich_featureXML = find_features_FFId.out[0]
    }

    if (params.merge_featureXML) {
        if (params.number_of_samples > 1) {
            ich_fraction_group_featureXML = ich_featureXML
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
                .join(ich_fraction_numbers, by: 0, failOnMismatch: true)
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
                ich_sample_featureXMLs = ich_featureXML
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
                convert_featureXML2consensusXML(ich_featureXML.map { [it[0], it[2]] })
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
        ich_sample_featureXMLs = ich_featureXML
            .map { [it[0], it[2]] }
            .groupTuple(by:0)
        merge_featureXML(ich_sample_featureXMLs)

        set_featureXMLSpectraPath(merge_featureXML.out[0])
        quantify_peptides(set_featureXMLSpectraPath.out[0])
        reheader_PeptideQuantCSV(quantify_peptides.out[0])
    }
}
