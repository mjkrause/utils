#!/bin/bash

# DCCPC End-of-Pilot phase demo in Oct 2018.
#
# The script uploads CRAI and CRAM from a folder to a Google bucket.
# (see https://cloud.google.com/storage/docs/gsutil/commands/cp for
# details)

# INPUTS:
#   $1: path to the folder the files reside in (this will create a new
#       subdirectory in the bucket with the same name)
#       WHAT IF THAT SUBDIRIRECTORY ALREADY EXISTS - DOES IT APPEND TO IT?

start_time=$SECONDS
num_files=$(ls $1 | wc -l)  # total number of files to process
echo "Uploading $num_files files..."
dest_bucket=gs://commons-demo/xenon_final

# Upload command.
#   -m: upload multiple files (some for of parllel processing)
#   -r: recurse into $1
gsutil -m cp -r $1 $dest_bucket

echo "...done uploading $num_files files to folder $1"

end_time=$SECONDS
execution_time=$(($((end_time-$start_time)) / 60))
echo "That took $execution_time min"
