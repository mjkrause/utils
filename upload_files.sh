#!/bin/bash


while read p; do
    FILENAME=$(echo "$p" | cut -b89-98)
    echo $FILENAME
    URL=$(echo "$p")
    echo $URL
     curl "{$URL}" | gsutil cp - gs://commons-demo/xenon/{$FILENAME}
done < $1
