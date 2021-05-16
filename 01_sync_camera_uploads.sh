#!/bin/sh

me=$1
watch_folder="/home/${me}/Dropbox/Camera Uploads/"
echo Syncing camera uploads from $me
echo Folder: $watch_folder

# first run, if the server has been powered off
"/srv/dropbox/Dropbox/Espacio familiar/Fotos/scripts/02_import_new_pictures.sh" "$watch_folder"

# Run with inotify for continuos monitoring
inotifywait -mr -e moved_to -e create -q /home/${me}/Dropbox/Camera\ Uploads/ |
while read ; do
    echo "Loading to pictures processing"
    "/srv/dropbox/Dropbox/Espacio familiar/Fotos/scripts/02_import_new_pictures.sh" "$watch_folder"
done

