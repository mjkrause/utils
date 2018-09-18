#!/bin/bash

# This is an attempt to copy CRAM and CRAI files from a presigned URL to
# Google bucket named commons-demo.

while read p; do
    FOLDERNAME=$(echo "$p" | cut -b89-98)
    echo $FOLDERNAME
    URL=$(echo "$p")
    echo $URL
    # Stream the output of curl to gsutil.
    curl "{$URL}" | gsutil cp - gs://commons-demo/xenon/{$FOLDERNAME}
done < $1
