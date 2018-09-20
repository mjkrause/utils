#!/bin/bash


# https://helium.commonsshare.org/dosapi/dataobjects/2a7f9eb4878f4f6ca4464c794f8eaf95/

url=https://helium.commonsshare.org/dosapi/dataobjects

curl -v --header "Authorization: Bearer $1" "$url/$2/"
