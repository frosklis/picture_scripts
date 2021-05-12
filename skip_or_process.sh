#!/bin/sh

negatives="/srv/dropbox/Dropbox/Espacio familiar/Fotos/negativos"
finished="/srv/dropbox/Dropbox/Espacio familiar/Fotos/jpeg"

file=$1
dir=${file%/*}
filename="${file%.*}"
filename="${filename##*/}"
extension="${file##*.}"
echo Parsed: $dir $filename $extension
if [ ${extension} = "xmp" ] ; then
	echo "Wrong input $1"
	exit 1
fi

counter=$(( 0 ))

IFS=$'\n'
for f in $(find "${negatives}/${dir}" -name "${filename}*.xmp" -printf "%f" ) ; do
	(( counter++ ))
	echo $f $filename
	no_ext=${f%".${extension}.xmp"} 
	echo $no_ext
	if [ $(stat -c %Y "${finished}/${dir}/${no_ext}.jpg") -ge $(stat -c %Y "${negatives}/${dir}/$f")  ]  
	then
		echo "Skipping $no_ext"
	else
		darktable-cli "${negatives}/${dir}/${filename}.${extension}" "${finished}/${dir}/" --verbose --core --conf plugins/imageio/format/jpeg/quality=90
		exit 0
	fi
done

echo Counter: $counter

if [ $counter -eq 0 ] ; then
	if [ $(stat -c %Y "${finished}/${dir}/${filename}.jpg") -ge $(stat -c %Y "${negatives}/${dir}/${filename}.${extension}")  ]  
	then
		echo "Skipping $filename"
		exit 0
	else
		# Run the command
		darktable-cli "${negatives}/${dir}/${filename}.${extension}" "${finished}/${dir}/" --verbose --core --conf plugins/imageio/format/jpeg/quality=90
	fi
fi

