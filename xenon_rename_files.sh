#!/bin/bash

# DCCPC End-of-Pilot phase demo in Oct 2018.
#
# The script renames CRAI and CRAM files in a folder.


# INPUTS:
#   $1: path to the folder the files reside in


num_files=$(cat $1 | wc -l)  # total number of files to process
echo "Renaming $num_files files..."

counter=0  # counts all processed files

while read url; do

    # We want the same base name for cram and crai files, they should only
    # differ in their file extension. This is a crude way of achieving this.
    if [[ $filename = *"crai"* ]]; then
	objectname=$( echo "$filename" | cut -b84-123 )
    else
	objectname=$( echo "$filename" | cut -b84-118 )
    fi

    counter=$((counter+1))
    
    # Rename file in-place.
    mv "${filename}" "${objectname}"
    pids[${proc_counter}]=$!

    sleep 1
    
done < $1  # while

# Wait for all processes to finish before iterating.
for pid in ${pids[*]}; do
    echo "Waiting for all $num_cores processes to finish..."
    wait $pid
    sleep 1
done  # for

echo "Renamed $counter file in folder $1"
