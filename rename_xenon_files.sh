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

# INPUT
# $1:  current state
# $2:  total state
function ProgressBar {
    # Process data
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    # Build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:                           
# 1.2.1.1 Progress : [########################################] 100%
printf "\rProgress : [${_fill// /\#}${_empty// /-}] ${_progress}%%"

}

for filepath in $1/*.*; do

    ProgressBar ${counter} ${num_files}
    #echo "File path: $filepath"

    oldname=$(echo "$filepath" | sed "s/.*\///")
    start=$(strindex "$oldname" "GTEX")
    start=$((start+1))
    #echo "Start index of new oldname: $start"
    # Use hard-coded length of two strings to get stop indices.
    stop_crai=$((start + 39))
    stop_cram=$((start + 34))

    # We want the same base name for cram and crai files, they should only
    # differ in their file extension. This is a crude way of achieving this.
    if [[ $oldname = *"crai"* ]]; then
	newname=$( echo "$oldname" | cut -b$start-$stop_crai )
    else
	newname=$( echo "$oldname" | cut -b$start-$stop_cram )
    fi

    counter=$((counter+1))

    #echo "Old file name: $oldname"
    #echo "New file name: $newname"
    
    # Rename file in-place.
    mv "$1/$oldname" "$1/$newname"

    sleep 1
    
done

echo "Renamed $counter file in folder $1"
