# NFTest fixtures

The existing cases in `nftest.yml` use the original UCLA fixture filenames.
Their CSV files now reference environment variables instead of UCLA `/hot` paths.
Copy `.env-template` to `.env` and point the four `LFQ_*` variables at equivalent
local fixture directories. `test/run-nftest.sh` sources `.env` when launching a
case in a Slurm job. The CSV expander resolves the variables to a temporary CSV
for each case; the pipeline still receives ordinary absolute file paths.

The two cases already marked `skip: true` in `nftest.yml` remain skipped.
The isolated `test_split_idXML/test.nf` case also uses `LFQ_MOUSE_DATA_DIR`.
