""" Removes the features that matched to any PSM from the idXML """
import argparse
from pyopenms import FeatureXMLFile, FeatureMap, DataProcessing, DateTime, PeptideIdentificationList


PROG_NAME = 'FeatureXMLIDRemover'
VERSION = '0.0.1'

class FeatureXMLIDRemover():
    """ FeatureXMLIDRemover """
    def __init__(self):
        """ Constructor """
        self.input_path:str = None
        self.output_path:str = None
        self.args:argparse.ArgumentParser = None
        self.fmap = FeatureMap()
        self.fmap_filtered:FeatureMap = None

    def parse_args(self):
        """ parse args """
        parser = argparse.ArgumentParser(prog=PROG_NAME)
        parser.add_argument(
            '--input-path',
            type=str,
            help="Path to the input file. Valid format: ['.featureXML']"
        )
        parser.add_argument(
            '--output-path',
            type=str,
            help="Path to the output file. Valid format: ['.featureXML']"
        )

        args = parser.parse_args()
        self.args = args
        self.input_path = args.input_path
        self.output_path = args.output_path

    def add_data_processing(self):
        """ add DataProcessing """
        dp = DataProcessing()
        # 11 is for 'FILTERING', from 'DataProcessing.h'
        dp.setProcessingActions({11})
        software = dp.getSoftware()
        software.setName(PROG_NAME)
        software.setVersion(VERSION)

        dp.setSoftware(software)
        dp.setCompletionTime(DateTime().now())

        # pylint: disable=W0212
        for k,v in self.args._get_kwargs():
            dp.setMetaValue(f"parameter: {k}", v)

        data_processing = self.fmap_filtered.getDataProcessing()
        data_processing.append(dp)

        self.fmap_filtered.setDataProcessing(data_processing)

    def main(self):
        """ main """
        self.parse_args()
        FeatureXMLFile().load(self.input_path, self.fmap)
        print(f"Number of spectra loaded: {self.fmap.size()}", flush=True)

        self.fmap_filtered = FeatureMap(self.fmap)
        self.fmap_filtered.clear(False)
        self.fmap_filtered.setProteinIdentifications([])
        self.fmap_filtered.setUnassignedPeptideIdentifications(PeptideIdentificationList())

        self.add_data_processing()

        for feature in self.fmap:
            if not feature.getPeptideIdentifications():
                self.fmap_filtered.push_back(feature)

        self.fmap_filtered.ensureUniqueId()

        FeatureXMLFile().store(self.output_path, self.fmap_filtered)

        print(f"Number of spectra saved: {self.fmap_filtered.size()}", flush=True)

if __name__ == '__main__':
    FeatureXMLIDRemover().main()
