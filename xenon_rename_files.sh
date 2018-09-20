#!/bin/bash

# DCCPC End-of-Pilot phase demo in Oct 2018.
#
# The script renames CRAI and CRAM files in a folder.


# INPUTS:
#   $1: path to the folder the files reside in


num_files=$(ls $1 | wc -l)  # total number of files to process
echo "Renaming $num_files files..."

counter=0  # counts all processed files

for filepath in $1/*.*; do

    echo "File path: $filepath"

    filename=$(echo "$filepath" | sed "s/.*\///")

    # We want the same base name for cram and crai files, they should only
    # differ in their file extension. This is a crude way of achieving this.
    if [[ $filename = *"crai"* ]]; then
	objectname=$( echo "$filename" | cut -b38-77 )
    else
	objectname=$( echo "$filename" | cut -b38-72 )
    fi

    counter=$((counter+1))

    echo "Old file name: $filename"
    echo "New file name: $objectname"
    
    # Rename file in-place.
    mv "$1/$filename" "$1/$objectname"

    sleep 1
    
done

echo "Renamed $counter file in folder $1"
