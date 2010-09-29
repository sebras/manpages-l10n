#!/bin/sh

translations=`find man? -name "*.po" | sort`
for translation in $translations; do
	manpage=`basename $translation .po`
	original=`find ../english/ -name $manpage`
	# Print the progress
	echo -n "$translation "
	# Determine if there's a recognizable date in the original file
	perl -ne "if (/^\.TH.*(([1-2][0-9]{3})-([0-1][0-9])-([0-3][0-9])).*/) {
		print \"\\n\";
		print \"msgid \\\"\$1\\\"\\n\";
		print \"msgstr \\\"\";
		\$month['01'] = 'Januar';
		\$month['02'] = 'Februar';
		\$month['03'] = 'März';
		\$month['04'] = 'April';
		\$month['05'] = 'Mai';
		\$month['06'] = 'Juni';
		\$month['07'] = 'Juli';
		\$month['08'] = 'August';
		\$month['09'] = 'September';
		\$month['10'] = 'Oktober';
		\$month['11'] = 'November';
		\$month['12'] = 'Dezember';
		printf('%d', \$4);
		print '. ' . \$month[\$3] . ' ' . \$2;
		print '\"';
		print \"\\n\";
	}" $original > tmp.po
	# Extract header entry for custom compendium (first line until first blank line)
	sed -n "1,/^$/p" $translation > header.po
	# Create a custom compendium with the header from the translation
	msgcat --use-first header.po ../work/compendium.po > tmp-compendium.po
	cat tmp-compendium.po tmp.po > custom.po
	# Update .po file from master file
	po4a-updatepo -f man --option groff_code=verbatim \
		-m $original -M ISO-8859-1 \
		--msgmerge-opt "--backup=none --no-location --compendium custom.po --previous" \
		--po $translation
	# Remove obsolete strings
	msgattrib --no-obsolete $translation > tmp.po
	# Prefer the translations from the compendium
	msgmerge --compendium custom.po --no-fuzzy-matching /dev/null tmp.po > result.po
	mv result.po $translation
done
# Cleanup
rm header.po tmp.po tmp-compendium.po custom.po
