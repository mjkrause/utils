#!/bin/bash

# 1. Get list of files from Google bucket written to a file.
# ($NF denotes to print everything that follows the character "/")
gsutil ls gs://commons-demo/helium | awk -F"/" '{ print $NF }' > files_in_bucket.txt

# 2. Filenames in that file have the substring ".recab", and CRAI files end on
# ".cram.crai". We don't want that substring, and we want that filenames have the
# format <GTEX_ID>.<either "cram" or "crai">.

# Get rid of substring ".recab" and overwrite the output file (need to write
# to temp file first, then move that temp file to overwrite the actual file
# for in-place replacement).
cat files_in_bucket.txt | sed s'/.recab//'\
			      > /tmp/files_in_bucket.tmp\
    | mv /tmp/files_in_bucket.tmp files_in_bucket.txt

# Get rid of ".cram" in filenames of CRAI files (same strategy).
cat files_in_bucket.txt | sed s'/.recab//'\
			      > /tmp/files_in_bucket2.tmp\
    | mv /tmp/files_in_bucket2.tmp files_in_bucket.txt

# Actually, remove everything from the filename that follows ".".
cat files_in_bucket.txt |\
    sed s'/\..*$//' > /tmp/files_in_bucket3.txt |\
    mv /tmp/files_in_bucket3.txt files_in_bucket.txt

# Because we removed all extensions, there are duplicate lines in that files
# (because each CRAI had a corresponding CRAM). Remove the duplicate lines.
# (Note: this would be the only manipulation we actually need to achieve the
# objective but I leave everything else here for the sake of seeing how easy
# it is to manipulate strings in bash)
tmp=$(mktemp)
awk '!seen[$0]++' files_in_bucket.txt > "$tmp" && mv "$tmp" files_in_bucket.txt
# (combination of
# https://unix.stackexchange.com/questions/30173/how-to-remove-duplicate-lines-inside-a-text-file and
# https://stackoverflow.com/questions/42716734/modify-a-key-value-in-a-json-using-jq)

# Now the file holding the files in the Google bucket is ready to be compared
# to the file holding the required file names.

# The diff command below is from:
# https://stackoverflow.com/questions/18204904/fast-way-of-finding-lines-in-one-file-that-are-not-in-another

# Print number of files which are on the priority list and in the Google bucket.
num_hits=$(diff --new-line-format=""\
		--unchanged-line-format=""\
		<(sort required_files.txt)\
		<(sort files_in_bucket.txt) | wc -l)

echo "Files in priority list and in bucket: $num_hits"

# From:
# https://unix.stackexchange.com/questions/418429/find-intersection-of-lines-in-two-files
intersec=$(awk 'NR==FNR { lines[$0]=1; next } $0 in lines' required_files.txt files_in_bucket.txt)
echo "Files priority list and in-bucket have in common (intersection): $intersec"
