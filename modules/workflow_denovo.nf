include { findSingleFractionIdXML } from "${projectDir}/modules/common"
include { find_features_centroided } from "${projectDir}/modules/find_features_centroided"
include { split_idXML } from "${projectDir}/modules/split_idXML"
include { map_idXML } from "${projectDir}/modules/map_idXML"
include { set_featureXMLSpectraPath } from "${projectDir}/modules/set_featureXMLSpectraPath"
include { align_featureXML_id } from "${projectDir}/modules/align_featureXML_id"
include { transform_rt } from "${projectDir}/modules/transform_rt"
include { link_features } from "${projectDir}/modules/link_features"
include { resolve_conflict } from "${projectDir}/modules/resolve_conflict"
include { quantify_peptides } from "${projectDir}/modules/quantify_peptides"
include { filter_FeatureXMLMapped } from "${projectDir}/modules/filter_FeatureXMLMapped"
include { merge_featureXML } from "${projectDir}/modules/merge_featureXML"
include { merge_consensusXML } from "${projectDir}/modules/merge_consensusXML"
include { convert_featureXML2consensusXML } from "${projectDir}/modules/convert_featureXML2consensusXML"
include { set_consensusXMLColumnHeaders } from "${projectDir}/modules/set_consensusXMLColumnHeaders"

workflow denovo {
    if (params.featureXML_entrypoint == true) { // featureXML entrypoint
        ich_featureXML = Channel.fromPath(params.featureXML_csv)
            .splitCsv(header:true)
            .map {[it.sample_name, it.fraction_id, file(it.featureXML)]}
    } else { // mzML entrypoint
        ich_mzML = Channel.fromPath(params.mzML_csv)
            .splitCsv(header:true)
            .map {[it.sample_name, it.fraction_id, file(it.mzML)]}

        // FeatureFinderCentroided
        find_features_centroided(ich_mzML)
        ich_featureXML = find_features_centroided.out[0]
    }

    /*
    * ich_featureXML:
    * [
    *   [sample_name, fraction_id, featureXML]
    * ]
    */

    ich_idXML = Channel.fromPath(params.idXML_csv)
        .splitCsv(header:true)
        .map {[it.sample_name, file(it.idXML)]}

    if (params.fractionated) {
        // IDRipper
        split_idXML(ich_idXML)

        ich_idXML_featureXML = ich_featureXML
            .map { [it[0], [it[1], it[2]]] } // [[sample_1, [fr1, 1.featureXML]]]
            .groupTuple(by:0)
            .join(split_idXML.out[0], by:0) // [sample_1, [[1, featureXML1], [fr2, featureXML2]], [idXML1, idXML2]]], ...]
            .map { it ->
                sample_name = it[0]
                fractionated_featureXMLs = it[1]
                idXMLs = it[2] instanceof List ? it[2] : [it[2]]
                pairs = []

                fractionated_featureXMLs.each { fraction_id, featureXML ->
                    prefix = featureXML.baseName.replace('_FeatureFinder', '')
                    matched_idXML = findSingleFractionIdXML(
                        sample_name, fraction_id, featureXML, prefix, idXMLs
                    )
                    pairs.add([
                        'sample_name': sample_name,
                        'fraction_id': fraction_id,
                        'idXML': matched_idXML,
                        'featureXML': featureXML
                    ])
                }
                return pairs
            }
            .flatten()
            .map { [it['sample_name'], it['fraction_id'], it['idXML'], it['featureXML']] }
    } else {
        ich_idXML_featureXML = ich_featureXML
            .join(ich_idXML, by:0) // [CPT0001, featureXML, idXML]
            .map { [it[0], it[1], it[3], it[2]] }
    }

    // IDMapper: map idXML to featureXML
    map_idXML(ich_idXML_featureXML)

    // FeatureXMLIDRemover: remove features mapped to any PSM
    if (params.filter_mapped_features) {
        filter_FeatureXMLMapped(map_idXML.out[0])
    }

    if (params.merge_featureXML) {
        if (params.number_of_samples > 1) {
            ich_fraction_samples_featureXMLs = map_idXML.out[0]
                .map { [it[1], it[0], it[2]] }
                .groupTuple(by: 0)
            // MapAlignerIdentification: resolve RT transformation
            align_featureXML_id(ich_fraction_samples_featureXMLs)

            ich_fraction_sample_featureXML_trafoXML = align_featureXML_id.out[0]
                .map { it ->
                    data = []
                    it[1].eachWithIndex { sample_name, i ->
                        data.add([
                            'sample_name': sample_name,
                            'fraction': it[0],
                            'featureXML': it[2][i],
                            'trafoXML': it[3][i]
                        ])
                    }
                    return data
                }
                .flatten()
                .map { [it['sample_name'], it['fraction'], it['featureXML'], it['trafoXML']] }

            // MapRTTransformer: apply RT transfomation
            transform_rt(ich_fraction_sample_featureXML_trafoXML)

            ich_fraction_featureXMLs = transform_rt.out[0]
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
            link_features(ich_fraction_featureXMLs)
            set_consensusXMLColumnHeaders(link_features.out[0])

            if (params.fractionated) {
                ch_fraction_consensusXMLs = set_consensusXMLColumnHeaders.out[0]
                    .map { it[1] }
                    .collect()
                    .map { files -> [params.project_name, files.sort { it.name }] }
                merge_consensusXML(ch_fraction_consensusXMLs)
                ich_consensusXML = merge_consensusXML.out[0]
            } else {
                ich_consensusXML = set_consensusXMLColumnHeaders.out[0]
            }
        } else {
            ich_sample_featureXMLs = map_idXML.out[0]
                .map { [it[0], it[2]] }
                .groupTuple(by:0)
            merge_featureXML(ich_sample_featureXMLs)

            set_featureXMLSpectraPath(merge_featureXML.out[0])
            convert_featureXML2consensusXML(set_featureXMLSpectraPath.out[0])
            set_consensusXMLColumnHeaders(convert_featureXML2consensusXML.out[0])
            ich_consensusXML = set_consensusXMLColumnHeaders.out[0]
        }

        // ConflictResolver
        resolve_conflict(ich_consensusXML)

        // ProteinQuantfier: quantify peptides
        quantify_peptides(resolve_conflict.out[0])
    } else {
        // Merge fractions
        ich_sample_featureXMLs = map_idXML.out[0]
            .map { [it[0], it[2]] }
            .groupTuple(by:0)
        merge_featureXML(ich_sample_featureXMLs)

        set_featureXMLSpectraPath(merge_featureXML.out[0])
        quantify_peptides(set_featureXMLSpectraPath.out[0])
    }
}
