#!/bin/sh

# Environment variables for picture related script

# Directories
RAW_FOLDER="/srv/dropbox/Dropbox/Espacio familiar/Fotos/negativos"
JPEG_FOLDER="/srv/dropbox/Dropbox/Espacio familiar/Fotos/jpeg"
COLLECTIONS_FOLDER="srv/dropbox/Dropbox/Espacio familiar/Fotos/colecciones"
PICTURE_SCRIPTS_FOLDER="srv/dropbox/Dropbox/Espacio familiar/Fotos/scripts"
PICTURE_DATA_FOLDER="srv/dropbox/Dropbox/Espacio familiar/Fotos/scripts/data"

# exiftool
EXIFTOOL_OPTIONS="-Rating -GPSlatitude -GPSlongitude -datetimeoriginal -directory -filename -title -description -derivedfrom -filemodifydate -subject -hierarchicalsubject -Make -Model -Lens -LensID -ImageWidth -ImageHeight -Aperture -ExposureTime -ISO"
JPEQ_QUALITY=90

