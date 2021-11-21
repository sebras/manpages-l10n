#!/bin/bash
#
# Copyright © 2019 Dr. Tobias Quathamer <toddy@debian.org>
#             2021 Dr. Helge Kreutzmann <debian@helgefjell.de>
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
elif [ a"$3" != a ]; then
    if [ -d ../$3 ]; then
        cd ../$3
        lcode=$3
    else
        echo "Language $3 could not be found, aborting"
        exit 11
    fi
else
    echo "Could not determine target directory, aborting"
    exit 12
fi

source ../scripts/l10n_set


# This is the distribution for which the manpage should be generated
distribution="$1"

# This is the filename of the localized manpage
localized="$2"

# If the filename ends with ".po", remove that part.
localized=$(echo "$localized" | sed -e "s/\.po$//")

# Set up the path to the original manpage
master="../../upstream/$distribution/$localized"

# Cannot generate manpage if the original could not be found
if [ ! -f "$master" ]; then
	echo "The original manpage for '$localized' could not be found in '$distribution'." >&2
	exit 16
fi

# Set up the filename of the translation
translation="$localized.po"

# Append the output directory
localized="$distribution/$localized"

# It might be that addenda for a certain language do not (yet) work
if [ ! -f noaddendum ]; then
    # Create the addendum for this manpage
    addendum=$(mktemp)
    ../scripts/generate-addendum.sh "$translation" "$addendum"
fi

# Create a separate .po file for this distribution,
# otherwise po4a will emit really a lot of warnings
# about an outdated translation, because the number
# of translations in the (internally generated) pot
# and po file do not match.
pofile=$(mktemp)
msggrep --location="$distribution" $translation > $pofile

# Actual translation
if [ -f noaddendum ]; then
    po4a-translate \
	-f man \
	--option groff_code=verbatim \
	--option generated \
	--option untranslated="a.RE,\|" \
	--option unknown_macros=untranslated \
	-m "$master" \
	-M "utf-8" \
	-p "$pofile" \
	-L UTF-8 \
	-l "$localized";
else
    po4a-translate \
	-f man \
	--option groff_code=verbatim \
	--option generated \
	--option untranslated="a.RE,\|" \
	--option unknown_macros=untranslated \
	-m "$master" \
	-M "utf-8" \
	-p "$pofile" \
	-a "$addendum" \
	-a "license.add" \
	-L UTF-8 \
	-l "$localized";
fi

# Ensure a proper encoding if the generation has been successful
if [ -f "$localized" ]; then
	encoding=$(mktemp)
	manpage=$(mktemp)
	# Check if the generated manpage already includes an encoding
	coding=$(head -n1 "$localized" | grep "coding:")
	if [ -n "$coding" ]; then
		# There is an encoding set, remove the first line
		sed -i -e "1d" "$localized"
	fi
	# Set an explicit encoding to prevent display errors
	echo ".\\\" -*- coding: UTF-8 -*-" > "$encoding"
	cat "$encoding" "$localized" > "$manpage"
	mv "$manpage" "$localized"
	rm "$encoding"
fi

rm -f "$addendum" "$pofile"
