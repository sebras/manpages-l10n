#!/bin/sh

for translation in `find ../man?/ -type f | sort`; do
	program=`basename "$translation" | sed -e "s/\.[0-9]//"`
	section=`basename "$translation" | sed -e "s/.\+\.//"`
	files=`find ../ori/ -name "$program.$section" | sort -r`
	echo -n Working on "$translation: "
	if [ -z "$files" ]; then
		echo no files found.
	else
		echo files found.
		cp $translation $program.$section.de.$section
		for file in $files; do
			./create-po.sh $file 2>/dev/null
			if [ $? -eq 0 ]; then
				cp $file $program.$section
				echo Successfully converted with $file
				break;
			fi
		done
		if [ -f $program.$section.po ]; then
			./update-po.sh $program.$section
			if [ $? -eq 0 ]; then
				./commit-po.sh $program.$section
			else
				echo Error: $program.$section does no longer exist upstream.
			fi
		else
			echo Could not convert $program.$section
		fi
		rm -f $program.$section*
		rm -f gettextization.failed.po
	fi;
done
