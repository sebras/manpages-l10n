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

# Require two arguments
if [ ! -f "$1" ]; then
	echo "The file $1 could not be found."
	exit 1
fi
if [ -z "$2" ]; then
	echo "Specify the custom compendium filename."
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
output=`mktemp`

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
}" "$original" > "$output"

# Set up strings for coreutils
cat >> "$output" <<END_COMPENDIUM

msgid "UPCASE"
msgstr "UPCASE"

msgid ""
"Report PROGRAM translation bugs to E<lt>http://translationproject.org/team/E<gt>"
msgstr ""
"Berichten Sie Fehler in der Übersetzung von PROGRAM an "
"E<lt>http://translationproject.org/team/de.htmlE<gt>"

msgid ""
"Full documentation at: E<lt>http://www.gnu.org/software/coreutils/PROGRAME<gt>"
msgstr ""
"Vollständige Dokumentation unter: E<lt>http://www.gnu.org/software/coreutils/PROGRAME<gt>"

msgid "or available locally via: info \\\\(aq(coreutils) PROGRAM invocation\\\\(aq"
msgstr "oder lokal verfügbar mit: info \\\\(aq(coreutils) PROGRAM invocation\\\\(aq"
END_COMPENDIUM
# Replace PROGRAM with current program
upcase=`echo "$name" | tr [:lower:] [:upper:]`
sed -i -e "s/PROGRAM/$name/g;s/UPCASE/$upcase/g" "$output"

# If a header has been given on the command line, reuse it.
# This is useful for generating a template header.
# Otherwise, extract the existing header
if [ ! -f "$3" ]; then
	header=`mktemp`
	# Extract header entry for custom compendium (first line until first blank line)
	sed -n "1,/^$/p" "$1" > "$header"
else
	header="$3"
fi
# Create a custom compendium with the header from the translation
tmpcompendium=`mktemp`
msgcat --use-first "$header" compendium.po > "$tmpcompendium"
cat "$tmpcompendium" "$output" > "$2"
rm -f "$tmpcompendium" "$header" "$output"
