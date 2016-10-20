#!/bin/sh
#
# Copyright © 2010-2012 Dr. Tobias Quathamer <toddy@debian.org>
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
if [ -z "$1" ]; then
	echo "Specify the manpage."
	exit 1
fi

# If only the name without path has been provided,
# try to find the original manpage
if [ ! -f "$1" ]; then
	original=`find ../english/ -type f -name "$1"`
	if [ -z "$original" ]; then
		echo "The file $1 could not be found."
		exit 1
	fi
else
	original="$1"
fi

name=`basename "$original" | sed -e "s/\.[0-9]//"`
section=`basename "$original" | sed -e "s/.\+\.//"`
output=`mktemp`

# Determine if an encoding is specified,
# otherwise fall back to ISO-8859-1
coding=`grep "\-\*\- coding:" "$original" | sed -e "s/.*coding:\s\+\([^ ]\+\).*/\1/"`
if [ -z "$coding" ]; then
	coding="ISO-8859-1"
fi

# Create .po file with po4a
po4a-gettextize -f man \
 --option groff_code=verbatim \
 --option generated \
 --option untranslated="a.RE,\|" \
 --option unknown_macros=untranslated \
 --master "$original" -M "$coding" \
 --po "$output"

# Stop here if po4a fails
if [ $? -ne 0 ]; then
	echo "Fehler bei der Ausführung von po4a."
	rm "$output"
	exit 1
fi

# Remove location information
sed -i -e "/^#: /d" "$output"

# Specify encoding
sed -i -e "s/^\"Content-Type: text\/plain; charset=CHARSET\\\\n\"$/\"Content-Type: text\/plain; charset=UTF-8\\\\n\"/" "$output"

mv "$output" "man$section/$name.$section.po"
./update-po.sh "man$section/$name.$section.po" CREATE_HEADER
echo "Created man$section/$name.$section.po"
