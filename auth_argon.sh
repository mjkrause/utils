#!/bin/bash

set -e

# This should open a browser window, let you authenticate, and
# return the requested token in the terminal.
#
# INPUTS
#  $1:  string, either 'bag' or 'results'

# For this to work we need to be in a virtualenv for Python. Check
# whether this is the case and if not activate one.
tf=$(python -c 'import sys;\
 print ("1" if hasattr(sys, "real_prefix") else "0")')

if [[ $tf = 0 ]]; then
    echo "Will activate virtualenv now"
    source .venv3/bin/activate
fi

# Get the personal UUID and the requested URI.
keychain_file=$HOME/dev/dcppc/argon/mykeychain.json
pers_uuid=$(jq -r .personal_UUID $keychain_file)

if [ "$1" == "bag" ]; then
    uri=$(jq -r .scope_bdbag $keychain_file)
elif [ "$1" == "results" ]; then
    uri=$(jq -r .scope_results $keychain_file)
else
    echo "Only one argument: either bag or results"
    exit 1
fi

# Open a browser window.
python oauth_cli_login/example.py $uri $pers_uuid

