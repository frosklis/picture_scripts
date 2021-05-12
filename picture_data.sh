#!/bin/sh

jpeg_data=/home/fotos/scripts/data/jpeg_exif.tsv
raw_data=/home/fotos/scripts/data/raw_exif.tsv

# todo take a second parameter that only does this for pictures taken after a given date
picture_data() {
    exiftool "$1" -r -T -n -api MissingTagValue^= -Rating -GPSlatitude -GPSlongitude -datetimeoriginal -directory -filename -title -description -derivedfrom -filemodifydate -subject -hierarchicalsubject -Make -Model -ImageWidth -ImageHeight -Aperture -ExposureTime -ISO > "$1"/picture_data.tsv
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