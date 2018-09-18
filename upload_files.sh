#!/bin/bash


while read p; do
    echo "$p" | cut -b89-98
done <download-links.txt

