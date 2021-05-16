#!/bin/sh

input_folder="/srv/dropbox/Dropbox/Espacio familiar/Fotos/terminado"
raw_folder="/srv/dropbox/Dropbox/Espacio familiar/Fotos/negativos"
jpeg_folder="/srv/dropbox/Dropbox/Espacio familiar/Fotos/jpeg"

# The folder must go to a directory based on dates
cd "${input_folder}"

for date in $(ls | cut -b 1-8 | uniq) ; do
	year=${date:0:4}
	month=${date:4:2}
	day=${date:6:2}
	echo $date $year-$month-$day
	destination="${raw_folder}/${year}/${year}-${month}-${day}"
	mkdir -p "${destination}"
	mv ${date}* "${destination}/" &

	jpeg="${jpeg_folder}/${year}/${year}-${month}-${day}"
	mkdir -p "${jpeg}"
done
wait
