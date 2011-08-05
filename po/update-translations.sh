#!/bin/sh

translations=`find man? -name "*.po" | sort`
for translation in $translations; do
	manpage=`basename $translation .po`
	original=`find ../english/ -name $manpage`
	# Print the progress
	echo -n "$translation "
	# If the manpage does no longer exist, remove the translation
	if [ -z "$original" ]; then
		git rm "$translation"
	else
		# Create a custom compendium
		./generate-custom-compendium.sh $original
		# Update .po file from master file
		po4a-updatepo -f man --option groff_code=verbatim --option generated \
			--option untranslated="a.RE,\|" \
			-m $original -M ISO-8859-1 \
			--msgmerge-opt "--backup=none --no-location --compendium custom.po --previous" \
			--po $translation
		# Remove obsolete strings
		msgattrib --no-obsolete $translation > tmp.po
		# Prefer the translations from the compendium
		msgmerge --compendium custom.po --no-fuzzy-matching /dev/null tmp.po > result.po
		mv result.po $translation
	fi
done
# Cleanup
rm tmp.po custom.po
