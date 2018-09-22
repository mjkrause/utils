#!/bin/bash

# Writes file names in input directory to an output TSV files.

# (Computing a checksum is IO-bound, and parallelizing. When I tested it
# on my local (8 cores) it  took 16 min for 6 files (3 CRAI, 3 CRAM) when
# using GNU parallel, and 17 min when computing it sequentially.)

# INPUTS:
#   $1: (str) directory name
#   $2: (str) output file name

# OUTPUTS:
# A TSV file where the columns are as follows:
# first:  file name
# second: file size
# third:  MD5 sum

counter=0
pids=()
filename=()
md5_array=()
file_size=()

for filepath in $1/*.*; do

    file_size[$counter]=$(stat --printf="%s" $filepath)
    # Extract file name from path.
    filename[$counter]=$(echo "$filepath" | sed "s/.*\///")
    md5_array[$counter]=$(md5sum $filepath)
    pids[$counter]=$!
    echo "Started processing PID $pids[$counter]..."

    counter=$((counter+1))

done  # for

# Wait for all processes to finish before iterating.
for pid in ${pids[*]}; do
    echo "Waiting for all $counter processes to finish..."
    wait # $pid
    sleep 1
done  # for

# Write arrays to file such that the first column is the file name,
# second column is the MD5 checksum, and the third column is the file size.
for  ((i=0; i<=$counter; i++)); do
    # Get only the MD5 sum from the array element (i.e., drop the file path).
    md5=$(echo "${md5_array[i]}" | awk '{ print $1 }')
    printf '%s\t%s\t%s\n' "${filename[i]}" "${md5}" "${file_size[i]}" >> $2
done

# Add header to TSV file.
echo -e "FILE ID\tMD5 CHECKSUM\tFILE SIZE (bytes)" | cat - $2 > /tmp/out && mv /tmp/out $2

echo "Wrote $counter records to file $2"
