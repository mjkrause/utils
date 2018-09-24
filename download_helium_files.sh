#!/bin/bash


# Download files from Team Helium

# 1. log at https://helium.commonsshare.org/
# 2. in ~/dccpc/data-commons-workspace/bin create a Python 3.6 virtual environment
# 3. pip-install packages requests and six
# 4. run `python helium.py login
# 5. this returns a URL, paste it in the browser
# 6. bach in the terminal this should print "Detected login for user..."
#    together with a prompt, answer "y"
# 7. this should return the bearer token, which should be valid for > 12 h

# INPUTS
#  $1:  TSV file with list of GUIDs
#  $2:  string of bearer token
#  $3:  destination path where files will be downloaded to

# EXAMPLE:
# curl -v --header "Authorization: Bearer $token" "https://helium.commonsshare.org/dosapi/dataobjects/cce38e8723a24ce38ec8f8d0fb1beddb/"


function download_guid() {
    # Download file with specific GUID to specific folder. If downloaded file
    # is corrupted retry up to 3 times. All inputs are string variables.
    
    # $1:  GTEX file name
    # $2:  DOS GUID
    # $3:  bearer token for access
    # $4:  destination directory for download

    #$token=$3
    #$dos_guid=$2
    #$download_dir=$4

    retry_counter=0 
    url=https://helium.commonsshare.org/dosapi/dataobjects
    resp=$(curl --header "Authorization: Bearer $3" "$url/$2/")
    echo $resp | python -m json.tool  # pretty-prints JSON

    download_url=$(echo $resp | jq -r '.urls[].url')
    checksum_real=$(echo $resp | jq -r '.urls[].checksum')
    cd $4
    curl -L -O --header "Authorization: Bearer $3" "$download_url"
    checksum_test=$($(echo sha256sum $1) | awk '{ print $1 }')
    echo "Test checksum: $checksum_test"
    cd -;  # navigate back to original directory
    # If checksum of downloaded file doesn't match the real checksum, try again.
    if ! [ $checksum_real = $checksum_test ]; then
	if [ $retry_counter < 4 ]; then
	    download_guids $1 $2 $3 $4  # recurse to retry
	    retry_counter=$((retry_counter+=1))
	else
	    # Standard out in red color.
	    echo "$(tput setaf 1)Retried downloading $retry_counter times - file with DOS GUID $2 is corrupted"
	fi
    fi
}

# Log output.
#LOG_LOCATION=/home/user/scripts/logs
#exec > >(tee -i $LOG_LOCATION/logfile.txt)
exec > >(tee -i logfile.txt)
exec 2>&1
line_counter=1
while read line; do
    echo $line

    gtex_filename=$(echo $line | awk '{print $1}')
    dos_guid=$(echo $line | awk '{print $2}')

    echo $dos_guid

    download_guid $gtex_filename $dos_guid $2 $3
    echo "Number of files processed: $line_counter"
    
done < $1
