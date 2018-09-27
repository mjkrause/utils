#!/bin/bash

# Script to download CRAM and CRAI files from Team Argon (Globus).
#
# INPUT:
#   $1: URL to the zipped BDBag

# You need two tokens to download the data files: one to download the zipped
# BDBag, and another to download the actual CRAM file.
#
# For the bag token run
#   python oauth_cli_login/example.py "https://auth.globus.org/scopes/898e3aae-b8a3-4be2-993b-1cf30c663b84/https" d76263f4-d723-41d8-add7-7840ec71bea8
#
# For the results token:
#   python oauth_cli_login/example.py "https://auth.globus.org/scopes/2ca3c24c-af4d-4d0b-b5b0-38d03ff8e68d/https" d76263f4-d723-41d8-add7-7840ec71bea8
#
# Once you have both token, copy them into keychain.json. Then run the script.

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
token_bdbag=$(cat keychain.json | jq -r '.token_bdbag')
token_results=$(cat keychain.json | jq -r '.token_results')

# Download a compressed BDBag.
wget -L --header "Authorization: Bearer $token_bdbag" "$bdbag_url"

# The bag file should now be in the current directory. Get its ID by getting the
# substring following the last slash character.
bag_id=$(echo $bdbag_url | awk -F"/" '{ print $NF }')

# Unzip the downloaded bag.
bdbag $bag_id

# Remove the extension (and dot) from the end of the bag_id string.
bag_id=$(echo ${bag_id::-4})

# Read URI for the data file from the bag's manifest.json.
resp=$(cat $bag_id/metadata/manifest.json | python -m json.tool)

# From bag/metadata/manifest.json grab the URI to the CRAM or CRAI file. 
result_uri=$(echo $resp | jq -r '.aggregates[].uri')

cd data
# Download that URI to the present subdirectory
wget -L --header "Authorization: Bearer $token_results" "$result_uri"
cd -;  # go back to where we were before downloading
