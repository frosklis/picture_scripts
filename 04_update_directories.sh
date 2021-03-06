#!/bin/sh

this_dir=`dirname ${BASH_SOURCE[0]-$0}`
cd "$this_dir"
this_dir=`pwd`
source ./00_environment.sh

# Make sure all the directories are in sync

# 1. See what's changed

picture_data() {
    cd "$1"
    rm -f newpicture_data.tsv
    find . -newer picture_data.tsv -not -name "*.tsv" -type f -exec exiftool {} -T -n -api MissingTagValue^= ${EXIFTOOL_OPTIONS} >> newpicture_data.tsv \;
}

echo "Looking for new pictures in raw and jpeg folders"
picture_data "${RAW_FOLDER}" &
picture_data "${JPEG_FOLDER}" &

wait

# 2. The next part requires more processing, so it is done in python
echo "Updating pictures"
cd "$this_dir"
./sync_folders.py

echo "Executing..."
wc autogenerated_commands
. ./autogenerated_commands.sh
