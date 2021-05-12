#!/bin/sh
# creates an edited view of the raw cantent in the finished folder
# edited means getting processing the raw files into finished jpegs

# set -e

negatives="/srv/dropbox/Dropbox/Espacio familiar/Fotos/negativos"
finished="/srv/dropbox/Dropbox/Espacio familiar/Fotos/jpeg"
jpeg_quality=90
commands="/srv/dropbox/Dropbox/Espacio familiar/Fotos/scripts/commands.txt"
rm "$commands"
touch "$commands"

#
# update trees
#
echo "updating trees" | systemd-cat -t "jpeg_sync"
cd "$negatives"
tree -lfiDQF --timefmt "%Y%m%d_%H%M%S" --noreport ./ | grep -v "\->" > tree.txt && tail -n +2 tree.txt | head -n -1 > tree2.txt &
cd "$finished"
tree -lfiDQF --timefmt "%Y%m%d_%H%M%S" --noreport ./ | grep -v "\->" > tree.txt && tail -n +2 tree.txt | head -n -1 > tree2.txt &

wait

mv "${finished}/tree2.txt" "${finished}/tree.txt"
mv "${negatives}/tree2.txt" "${negatives}/tree.txt"

#
# Compare the trees
#
echo "comparing trees"
IFS=$'\n'
for raw_dir in $(grep -e '\".*\"/$' -o "${finished}/tree.txt") ; do
	dir=$(echo "$raw_dir" | cut -b 2- | rev | cut -b 3- | rev)
	if grep -Fq "$raw_dir" "${negatives}/tree.txt"
	then
		# the directory exists
		true	
	else
		# the directory does not exist
		echo "Deleting $dir because it does not exist in negatives"
		
		rm -Rf "${finished}/${dir}"
	fi
done
: '
for raw_dir in $(grep -e '\".*\"/$' -o "${negatives}/tree.txt") ; do
	dir=$(echo "$raw_dir" | cut -b 2- | rev | cut -b 3- | rev)
	if grep -Fq "$raw_dir" "${finished}/tree.txt"
	then 
		true
	else
		echo "Creating ${dir}"
		mkdir -p "${finished}/${dir}"
	fi
done
'
# grep -e '\".*\"/$' -v tree.txt | grep -e '\"\./.*\"' -o | cut -b 4- | rev | cut -b 2- | cut -d "." -f 1 | rev | sort | uniq

# for each file in the negatives there should be a corresponding file in the processed
# the other way around is true too
echo "Processing each file. This is going to take a while."
for line in $(grep -e '\".*\"/$' -v "${negatives}/tree.txt" | grep -e "\.xmp" -i -v | grep -e ".*\".*\"" -o) ; do
	# mod_date=$(echo "$line" | cut -b 2-16 )
	file=$(echo "$line" | cut -b 23- | rev | cut -b 2- | rev)
	# echo $mod_date $file $filename $extension
	if /home/fotos/scripts/skip_or_process.sh "$file" ; then
		true
	else
		if ln -s "${negatives}/${file}" "${finished}/${file}" ; then 
			true
		else
			true
		fi
	fi
done

