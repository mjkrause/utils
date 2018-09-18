#!/bin/bash

# DCCPC End-of-Pilot phase demo in Oct 2018.
#
# This script copies files from Seven Bridges located in an AWS S3 bucket to a Google bucket.
# I had been given a list of presigned URLs that point and give access to these files.

# This is an attempt to copy CRAM and CRAI files from a presigned URL to
# Google bucket named commons-demo.

# INPUTS:
#   $1: a text file with presigned URLs, one URL per line

# Invoke like so:
#   ./upload_files.sh file_with_urls.txt

while read p; do
    # We want the same base name for cram and crai files, they should only differ in their
    # file extension. This is a crude way of achieving this.
    if [[ $p = *"crai"* ]]; then
	OBJECTNAME=$(echo "$p" | cut -b84-123)
    else
	OBJECTNAME=$(echo "$p" | cut -b84-118)
    fi
    echo "Copying $OBJECTNAME to Google bucket /commons-demo"
    URL=$(echo "$p")
    echo $URL
    # Stream the output of curl to gsutil.
    curl "${URL}" | gsutil cp - gs://commons-demo/xenon/$OBJECTNAME
done < $1
