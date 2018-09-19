#!/bin/bash

# DCCPC End-of-Pilot phase demo in Oct 2018.
#
# The script copies files from the full stacks (represented for instance by
# presigned URLs to the location or DOS GUIDs) to a Google bucket
# gs://commons-demo.


# INPUTS:
#   $1: a text file with presigned URLs, one URL per line
#   $2: a master file that contains information to filter whether an object
#       should be copied or not
#   $3: a string containing the full stack name, but it actually denotes the
#       name of the directory in bucket "commons-dev", so make sure a directory
#       with whatever name you use exists (this script isn't checking for it)

# Invoke like so:
#   ./upload_files.sh file_with_links.txt gtex-wgs.txt $fullstack_name

# Let the number of cores be the number of processes to process simultaneously
# to avoid machine overloading.
num_procs=grep -c ^processor /proc/cpuinfo  
num_files=$( cat $1 | wc -l)  # total number of files to process
    
counter=0

while read url; do
    # We want the same base name for cram and crai files, they should only
    # differ in their file extension. This is a crude way of achieving this.
    if [[ $url = *"crai"* ]]; then
	objectname=$( echo "$url" | cut -b84-123 )
    else
	objectname=$( echo "$url" | cut -b84-118 )
    fi
    #echo $objectname
    
    # "objectname" has a substring ".recab". In order to string-match objectname
    # to strings in file "gtex-wgs.tsv" we need to remove that substring by
    # slicing.
    sub1=${objectname:0:24}
    sub2=${objectname:30}
    sub="$sub1$sub2"
    #echo "$sub"

    # Return (if any) the line number of objectname in the master file
    # "gtex-wgs.tsv", which is the second input argument to this script.
    line_num=$(sed -n "/.*$sub.*/=" $2)
    #echo $line_num

    # Use line number to retrieve the line in the master file (second input
    # argument), which corresponds to the the file in objectname.
    matched_line=$(sed -n -e "$line_num"p $2)
    #echo $matched_line"\n"

    # Check whether the line contains string fullstack_name, and if so, pass the
    # objectname to copy it to the Google bucket.
    if [[ $matched_line == *$fullstack_name* || $matched_line == *"All"* ]]; then
	#echo $matched_line"\n"
	counter=$((counter+1))
	#echo $objectname

	# Get line number of that file in `gtex-wgs.tsv`
	echo "Copying $objectname to Google bucket /commons-demo"
	#echo $url
	
	# Run one copy process per core at a time. Run processes and store
	# pids in array.
	for i in $num_procs; do
    	    # Stream the output of curl to gsutil.
	    curl "${url}" | gsutil cp - gs://commons-demo/$fullstack_name/$objectname &
	    pids[${i}]=$!
	done

	# Wait for all processes to finish before iterating.
	for pid in ${pids[*]}; do
	    echo "Waiting for PID $pid to finish..."
	    wait $pid
	done
    fi
    #sleep 1
    
done < $1

echo "Number of files to analyze by $fullstack_name: $counter"


