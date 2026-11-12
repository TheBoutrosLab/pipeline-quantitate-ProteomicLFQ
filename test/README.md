# NFTest fixtures

Copy `.env-template` to `.env` and set `TEST_DIR` to the fixture directory.
`test/run-nftest.sh` sources `.env` inside the Slurm job. The CSV expander
resolves environment variables to absolute paths in temporary input CSV files.

The `test-merged` case remains skipped in `nftest.yml`.

The `test-internal-only` case covers two three-fraction samples. The
`test-unfractionated` case uses fraction 1 of each sample and quantifies each
sample separately. The existing empty-result case uses the 3.6 image to check
that a valid featureXML with no quantifiable peptides is handled as an empty
result.
