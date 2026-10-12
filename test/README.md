# NFTest fixtures

Copy `.env-template` to `.env` and set `TEST_DIR` to the fixture directory.
`test/run-nftest.sh` sources `.env` inside the Slurm job. The CSV expander
resolves environment variables to absolute paths in temporary input CSV files.

The `test-merged` case remains skipped in `nftest.yml`.
