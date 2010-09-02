#!/bin/sh

rm -rf generated
mkdir generated
for section in `seq 8`; do
	mkdir generated/man$section;
done

for translation in po/man?/*.po; do
	manpage=`basename $translation .po`;
	section=`basename $manpage | sed -e "s/.\+\.//"`;
	original=`find english/ -type f -name "$manpage"`;
	addendum=`echo $translation | sed -e "s/\.po$/.add/"`;
	po4a-translate \
		-f man \
		-m $original \
		-p $translation \
		-a $addendum \
		-a lizenz.add \
		-l generated/man$section/$manpage;
done
