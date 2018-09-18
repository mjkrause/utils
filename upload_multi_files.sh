#!/bin/bash

# DCCPC End-of-Pilot phase demo in Oct 2018.
#
# This script copies files from Seven Bridges located in an AWS S3 bucket to a Google bucket.
# I had been given a list of presigned URLs that point and give access to these files.

# This is an attempt to copy CRAM and CRAI files from a presigned URL to
# Google bucket named commons-demo.

# INPUTS:
#   $1: a text file with presigned URLs, one URL per line
#   $2: a master file that contains information to filter whether an object should be copied or not

# Invoke like so:
#   ./upload_files.sh file_with_urls.txt



while read url; do
    # We want the same base name for cram and crai files, they should only differ in their
    # file extension. This is a crude way of achieving this.
    if [[ $url = *"crai"* ]]; then
	objectname=$( echo "$url" | cut -b84-123 )
    else
	objectname=$( echo "$url" | cut -b84-118 )
    fi
    #echo $objectname
    # "objectname" has a substring ".recab". In order to string-match objectname to file gtex-wgs.tsv
    # we need to remove that substring by slicing.
    sub1=${objectname:0:24}
    sub2=${objectname:30}
    sub="$sub1$sub2"
    #echo "$sub"

    #sed -n "/.*$sub.*/=" $2

    # Return (if any) the line number of objectname in gtex-wgs.tsv.
    line_num=$(sed -n "/.*$sub.*/=" $2)
    #echo $line_num

    # Use line number to capture the line.
    matched_line=$(sed -n -e "$line_num"p $2)
    #echo $matched_line

    if [[ "$matched_line" = "Xenon" ]]; then
	echo $matched_line
	# Get line number of that file in `gtex-wgs.tsv`
	#echo "Copying $objectname to Google bucket /commons-demo"
	#echo $url
	# Stream the output of curl to gsutil.
	#curl "${url}" | gsutil -m cp -I gs://commons-demo/xenon2/$objectname
    fi
    
done < $1




