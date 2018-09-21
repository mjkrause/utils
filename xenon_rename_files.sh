#!/bin/bash

# DCCPC End-of-Pilot phase demo in Oct 2018.
#
# The script renames CRAI and CRAM files in a folder.


# INPUTS:
#   $1: path to the folder the files reside in


num_files=$(ls $1 | wc -l)  # total number of files to process
echo "Renaming $num_files files..."

counter=0  # counts all processed files

# From https://stackoverflow.com/questions/5031764/position-of-a-string-within-a-string-using-linux-shell-script.
strindex() {
  x="${1%%$2*}"
  [[ "$x" = "$1" ]] && echo -1 || echo "${#x}"
}

for filepath in $1/*.*; do
    echo "File path: $filepath"

    filename=$(echo "$filepath" | sed "s/.*\///")
    start=$(strindex "$filename" "GTEX")
    start=$((start+1))
    echo "Start index of new filename: $start"
    # Use hard-coded length of two strings to get stop indices.
    stop_crai=$((start + 39))
    stop_cram=$((start + 34))

    # We want the same base name for cram and crai files, they should only
    # differ in their file extension. This is a crude way of achieving this.
    if [[ $filename = *"crai"* ]]; then
	objectname=$( echo "$filename" | cut -b$start-$stop_crai )
    else
	objectname=$( echo "$filename" | cut -b$start-$stop_cram )
    fi

    counter=$((counter+1))

    echo "Old file name: $filename"
    echo "New file name: $objectname"
    
    # Rename file in-place.
    mv "$1/$filename" "$1/$objectname"

    sleep 1
    
done

echo "Renamed $counter file in folder $1"
