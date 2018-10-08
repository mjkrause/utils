#!/bin/bash

# Script to download CRAM and CRAI files from Team Argon (Globus).
#
# INPUT:
#   $1: URL to the zipped BDBag

# EXAMPLE:
#  download_argon.sh "https://bags.fair-research.org/15374771912446_1_15379605364218.outputs.bdbag.zip"
#
# You need two tokens to download the data files: one to download the
# zipped BDBag, and another to download the actual CRAM file. First,
# source .venv3 in this directory.
#
# For the bag token run
#   python oauth_cli_login/example.py "https://auth.globus.org/scopes/898e3aae-b8a3-4be2-993b-1cf30c663b84/https" d76263f4-d723-41d8-add7-7840ec71bea8
#
# For the results token:
#   python oauth_cli_login/example.py "https://auth.globus.org/scopes/2ca3c24c-af4d-4d0b-b5b0-38d03ff8e68d/https" d76263f4-d723-41d8-add7-7840ec71bea8
#
# Run the first command. It returns a JSON and the path where that JSON
# is stored. Copy that JSON to the present directory, and rename it as the
# second command will save it using the same UUID. Do the same with the
# JSON returned from the second command.
#
# Once you have both token, copy them into keychain.json. Then run the script.
#
# RUNNING WITH GNU parallel
# ~$ find <first_few_characters>* | parallel ./../utils/download_argon.sh {1}

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
