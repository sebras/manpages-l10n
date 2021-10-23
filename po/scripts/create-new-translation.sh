#!/bin/bash
#
# Copyright © 2018-2019 Dr. Tobias Quathamer <toddy@debian.org>
#             2021 Dr. Helge Kreutzmann <debian@helgefejll.de>
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

if [ -d man1 ]; then
    lcode=$(basename $(pwd))
elif [ a"$2" != a ]; then
    if [ -d ../$2 ]; then
        cd ../$2
	lcode=$2
    else
        echo "Language $2 could not be found, aborting"
        exit 1
    fi
else
    echo "Could not determine target directory, aborting"
    exit 2
fi

source ../scripts/l10n_set

# Require one argument (the name of the manpage)
if [ -z "$1" ]; then
	echo "Please specify the name of the manpage, e.g. 'arch.1'." >&2
	exit 1
fi

# Normalize to the basename of the manpage
manpage=$(basename $1)
mandir="man"$(echo $manpage | sed -e "s/.*\.\([0-9]\).\?$/\1/")
pofile=$mandir/$manpage.po
potfile=../../templates/$mandir/$manpage.pot

# Create the template
cd ../../templates
./generate-one-template.sh $manpage
# Update common templates
./create-common-templates.sh
cd ../po/$lcode

# Update common translations
../scripts/update-common.sh $lcode

# Ensure that there is a .po file
if [ ! -f $mandir/$manpage.po ]; then
	# Create a new .po file
	msginit --no-translator --locale="$lcode" -i "$potfile" -o "$pofile"

	# Get the head of the file until first msgid line
	# and generate the standard header
	tmppo1=$(mktemp)
	tmppo2=$(mktemp)
	sed -e "1,/^msgid/d" "$pofile" > "$tmppo1"
	echo "# $langname translation of manpages" > "$pofile"
	echo "# This file is distributed under the same license as the manpages-l10n package." >> "$pofile"
	echo "# Copyright © of this file:" >> "$pofile"
	echo "msgid \"\"" >> "$pofile"
	cat "$pofile" "$tmppo1" > "$tmppo2"
	mv "$tmppo2" "$pofile"
	rm -f "$tmppo1" "$tmppo2"

	# Adjust two header lines
	#sed -i -e "s/^\"Language-Team: none\\\n\"$/\"Language-Team: German <debian-l10n-german@lists.debian.org>\\\n\"/" "$pofile"
	sed -i -e "s/^\"Language-Team: none\\\n\"$/\"Language-Team: $langmail\\\n\"/" "$pofile"
	sed -i -e "s/^\"Project-Id-Version: manpages-de .*$/\"Project-Id-Version: manpages-l10n\\\n\"/" "$pofile"
fi

# Finally, populate the translation from the compendium.
../scripts/update-po.sh "$pofile" "$lcode"
