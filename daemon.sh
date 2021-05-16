#!/bin/zsh

# Starts dropbox and watches the Camera Uploads folder

# This is meant to be run as root

dropbox_users=( claudio ceci fotos )
sync_users=( claudio ceci )
for user in "${dropbox_users[@]}"
do
        echo "starting dropbox for ${user}"
        sudo -u ${user}  /home/${user}/.dropbox-dist/dropboxd &
done

for user in "${sync_users[@]}"
do
        echo "watching camera uploads for ${user}"
        /srv/dropbox/Dropbox/Espacio\ familiar/Fotos/scripts/01_sync_camera_uploads.sh ${user} &
done

wait
