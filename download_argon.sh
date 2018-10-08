#!/bin/bash

# Script to download CRAM and CRAI files from Team Argon (Globus).
#
# INPUT:
#   $1: URL to the zipped BDBag

# EXAMPLE:
#  download_argon.sh "https://bags.fair-research.org/15374771912446_1_15379605364218.outputs.bdbag.zip"
#
# Once you have both token, copy them into mykeychain.json. Then run the script.
#
# RUNNING WITH GNU parallel
# ~$ find <first_few_characters>* | parallel ./../utils/download_argon.sh {1}
#
# ALTERNATIVE TO USING THIS SCRIPT
# As of 2018-10-08 you can use
#   ~$ bdbag --materialize $bag_url
# to download and unzip the BDBag, and to download the CRAM into its
# data directory. (you can also use parallel with it)

usage="$(basename "$0") [-h] [arg1] -- downloads CRAM and CRAI files from Team Argon (Globus)

where:
    -h    show this help text
    -arg1 URL to a zipped Argon BDBag"

if [ "$1" == "-h" ] ; then
    echo "Usage: $usage"  #`basename $0` [-h]"
    exit 0
fi

bdbag_url=$1

# Get all needed token.
token_bdbag=$(jq -r .token_bdbag mykeychain.json)
token_results=$(jq -r .token_results mykeychain.json)
echo "bags token: $token_bdbag"
echo "result token: $token_results"

# # Download a compressed BDBag.
wget -L --header "Authorization: Bearer $token_bdbag" "$bdbag_url"

# The bag file should now be in the current directory. Get its ID by getting the substring following the last slash character.
bag_id=$(echo $bdbag_url | awk -F"/" '{ print $NF }')

# Unzip the downloaded bag.
bdbag $bag_id

# Remove the extension (and dot) from the end of the bag_id string.
bag_id=$(echo ${bag_id::-4})
echo $bag_id

# From bag/metadata/manifest.json grab the URI to the CRAM or CRAI file. 
result_uri=$(jq -r '.aggregates[].uri' $bag_id/metadata/manifest.json)
echo "result_uri: $result_uri"

cd data
# Download that URI to the present subdirectory
wget -L --header "Authorization: Bearer $token_results" "$result_uri"
cd -;  # go back to where we were before downloading
