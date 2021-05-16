#!/bin/sh
# This script moves the pictures in the input
# folder to the working pictures folder
set -e

dest="/srv/dropbox/Dropbox/Espacio\ familiar/Fotos/en_proceso/"
dest_space="/srv/dropbox/Dropbox/Espacio familiar/Fotos/en_proceso/"
grp="fotos"
command="/usr/bin/vendor_perl/exiftool '$1' '-filename<CreateDate' -d ${dest}%Y%m%d_%H%M%S%%-c.%%le -r"

echo $command

eval $command

cd "$dest_space"
chown fotos:fotos *
chmod 664 *
