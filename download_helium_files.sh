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
#  $1:  bearer token
#  $2:  GUID


#curl -v --header "Authorization: Bearer $token" "https://helium.commonsshare.org/dosapi/dataobjects/cce38e8723a24ce38ec8f8d0fb1beddb/"

url=https://helium.commonsshare.org/dosapi/dataobjects

resp=$(curl --header "Authorization: Bearer $1" "$url/$2/")

#echo $resp

echo $resp | | bat -p -l json  # pretty-prints JSON

#curl -v --header "Authorization: Bearer $1" "$url/$2/"
