#!/bin/sh
#
# Copyright © 2010-2012 Tobias Quathamer <toddy@debian.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Require one argument
if [ ! -f "$1" ]; then
	echo "The file $1 could not be found."
	exit 1
fi

# Try to find the original manpage
manpage=`basename "$1" .po`
original=`find ../english/ -type f -name "$manpage"`
if [ -z "$original" ]; then
	echo "The original manpage for $1 could not be found."
	exit 1
fi

name=`basename "$original" | sed -e "s/\.[0-9]//"`
section=`basename "$original" | sed -e "s/.\+\.//"`

# If the .po file has just been created, we need to
# insert a better header than the default from po4a.
if [ "x$2" = "xCREATE_HEADER" ]; then
	header=`mktemp`
	cat > "$header" <<END_OF_HEADER
# German translation of manpages
# This file is distributed under the same license as the manpages-de package.
# Copyright © of this file:
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
	sed -i -e "s/CURRENT_DATE/$current_date/" "$header"
fi

# Generate custom compendium
custom=`mktemp`
./generate-custom-compendium.sh "$1" "$custom" "$header"

# Update .po file from master file
po4a-updatepo -f man \
 --option groff_code=verbatim \
 --option generated \
 --option untranslated="a.RE,\|" \
 --option unknown_macros=untranslated \
 --master "$original" -M ISO-8859-1 \
 --msgmerge-opt "--backup=none --no-location --compendium \"$custom\" --previous" \
 --po "$1"
# Remove obsolete strings
tmppo=`mktemp`
result=`mktemp`
msgattrib --no-obsolete "$1" > "$tmppo"
# Prefer the translations from the compendium
msgmerge --compendium "$custom" --no-fuzzy-matching /dev/null "$tmppo" > "$result"
mv "$result" "$1"

# Cleanup
rm -f "$header" "$tmppo" "$custom"
