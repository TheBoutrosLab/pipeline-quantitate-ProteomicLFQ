# NFTest fixtures

Copy `.env-template` to `.env` and set `TEST_DATA_DIR` to the fixture directory.
The Python launcher loads `.env`; the CSV expander resolves environment
variables to absolute paths in temporary input CSV files.

The `test-internal-only` case covers two three-fraction samples. The
`test-unfractionated` case uses fraction 1 of each sample and quantifies each
sample separately. The existing empty-result case uses the 3.6 image to check
that a valid featureXML with no quantifiable peptides is handled as an empty
result.

Run `python3 test/run-nftest.py <case-name>` from the repository root in an
environment with NFTest, PyYAML, and python-dotenv. Set
`NFT_CLUSTER=boutroslab_aws` inside an AWS Slurm job to use
`$NFT_RUN_ROOT/$SLURM_JOB_ID`; set `NFT_CLUSTER=pines` to use `$NFT_RUN_ROOT`
directly and select Apptainer. With no cluster selected, the existing Docker
profile is used. An unset `NFT_RUN_ROOT` defaults to the repository root.
Results go to `<run-root>/<case-name>/`, with temporary files under
`<run-root>/.nftest-temp/`.
