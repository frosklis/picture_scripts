#!/bin/sh

this_dir=`dirname ${BASH_SOURCE[0]-$0}`
cd "$this_dir"
this_dir=`pwd`

source ./00_environment.sh

jpeg_data="${PICTURE_DATA_FOLDER}/jpeg_exif.tsv"
raw_data="${PICTURE_DATA_FOLDER}/raw_exif.tsv"

# todo take a second parameter that only does this for pictures taken after a given date
picture_data() {
    rm -f "$1"/newpicture_data.tsv
    exiftool "$1" -r -T -n -api MissingTagValue^= $EXIFTOOL_OPTIONS > "$1"/picture_data.tsv
}

if date_jpeg=$(stat -c %y -L "${jpeg_data}"); then
    echo "The date for jpeg is: " $date_jpeg
else
    echo "Generating jpeg_data"
    picture_data /home/fotos/jpeg &
fi
if date_raw=$(stat -c %y -L "${raw_data}"); then
    echo "The date for raw is:  " $date_raw
else
    echo "Generating raw_data"
    picture_data /home/fotos/negativos &
fi

wait

# Update picture_data