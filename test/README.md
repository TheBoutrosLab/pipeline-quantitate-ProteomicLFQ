# NFTest fixtures

Copy `.env-template` to `.env` and set `TEST_DIR` to the fixture directory.
`test/run-nftest.sh` sources `.env` inside the Slurm job. The CSV expander
resolves environment variables to absolute paths in temporary input CSV files.

The `test-merged` case remains skipped in `nftest.yml`.

The `test-internal-only` case covers two three-fraction samples and checks the
cohort peptide CSV and six-map consensusXML with fraction metadata when run through `test/run-nftest.sh`. The
`test-unfractionated` case uses fraction 1 of each sample, quantifies each
sample separately, and checks both peptide CSVs and final featureXML files.
The checks expect `abundance|<sample_name>` headers and `fraction=all` peptide rows. The existing
empty-result case uses the 3.6 image to check that a valid featureXML with no
quantifiable peptides is handled as an empty result.
