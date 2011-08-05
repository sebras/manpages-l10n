#!/bin/sh

if [ -z "$1" ]; then
	echo "Geben Sie die Handbuchseite an."
	exit 1
fi

original=`find ../english/ -type f -name "$1"`
if [ -z "$original" ]; then
  echo "Die Datei $1 wurde nicht gefunden."
  exit 1
fi

# Create uniform header
cat > header.po <<END_OF_HEADER
# German translation of manpages
# This file is distributed under the same license as the manpages-de package.
# Copyright © of this file:
# MEIN NAME <EMAIL>, JAHR.
msgid ""
msgstr ""
"Project-Id-Version: manpages-de\n"
"POT-Creation-Date: CURRENT_DATE\n"
"PO-Revision-Date: CURRENT_DATE\n"
"Last-Translator: MEIN NAME <EMAIL>\n"
"Language-Team: German <debian-l10n-german@lists.debian.org>\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
END_OF_HEADER
current_date=`date +"%Y-%m-%d %H:%M%z"`
sed -i -e "s/CURRENT_DATE/$current_date/" header.po

# Generate custom compendium
../po/generate-custom-compendium.sh $original

# Update .po file from master file
po4a-updatepo -f man --option groff_code=verbatim \
	--option generated \
	--option untranslated="a.RE,\|" \
	--option unknown_macros=untranslated \
	-m $original -M ISO-8859-1 \
	--msgmerge-opt "--backup=none --no-location --compendium custom.po --previous" \
	--po $1.po
# Remove obsolete strings
msgattrib --no-obsolete $1.po > tmp.po
# Prefer the translations from the compendium
msgmerge --compendium custom.po --no-fuzzy-matching /dev/null tmp.po > result.po
mv result.po $1.po

# Cleanup
rm -f header.po tmp.po tmp-compendium.po custom.po gettextization.failed.po
