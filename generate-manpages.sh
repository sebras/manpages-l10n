#!/bin/sh

rm -rf generated
mkdir generated
for section in `seq 8`; do
	mkdir generated/man$section;
done

cd po && ./generate-addendums.sh && cd ..

for translation in po/man?/*.po; do
	manpage=`basename $translation .po`;
	section=`basename $manpage | sed -e "s/.\+\.//"`;
	original=`find english/ -type f -name "$manpage"`;
	addendum=`echo $translation | sed -e "s/\.po$/.add/"`;
	po4a-translate \
		-f man \
		--option groff_code=verbatim \
		--option generated \
		-m $original \
		-M ISO-8859-1 \
		-p $translation \
		-a $addendum \
		-a lizenz.add \
		-l generated/man$section/$manpage;
done

find po/ -name "*add" | xargs rm
