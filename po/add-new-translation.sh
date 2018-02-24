#!/bin/sh
#
# Copyright © 2018 Dr. Tobias Quathamer <toddy@debian.org>
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

# Require one argument (the name of the manpage)
if [ -z "$1" ]; then
	echo "Please specify the name of the manpage, e.g. 'arch.1'."
	exit 1
fi

# Normalize to the basename of the manpage
manpage=$(basename $1)

# Determine directory names from upstream directory.
directories=$(find ../upstream -maxdepth 1 -type d | cut -d/ -f3- | LC_ALL=C sort)

for directory in $directories; do
	# Skip adding a new translation if it exists already.
	pofile=$(find $directory -type f -name "$manpage.po")
	if [ -f "$pofile" ]; then
		echo "The translation for '$manpage' already exists in '$directory', skipping."
		continue
	fi

	# Find the upstream manpage
	manpage_path=$(find "../upstream/$directory" -type f -name "$manpage")
	if [ ! -f "$manpage_path" ]; then
		echo "The manpage '$manpage' does not exist in '$directory', skipping."
		continue
	fi

	# Determine if an encoding is specified,
	# otherwise fall back to ISO-8859-1
	coding=$(grep "\-\*\- coding:" "$manpage_path" | sed -e "s/.*coding:\s\+\([^ ]\+\).*/\1/")
	if [ -z "$coding" ]; then
		coding="ISO-8859-1"
	fi

	# Extract the mandir from the upstream path
	mandir=$(dirname "$manpage_path" | cut -d/ -f3-)
	potfile="../templates/$mandir/$manpage.pot"
	pofile="$mandir/$manpage.po"

	# As there hasn't been a translation yet, the potfile
	# has been skipped by "update-templates.sh".
	# Therefore, create a potfile now.
	po4a-gettextize -f man \
	 --option groff_code=verbatim \
	 --option generated \
	 --option untranslated="a.RE,\|" \
	 --option unknown_macros=untranslated \
	 --master "$manpage_path" -M "$coding" \
	 --po "$potfile"

	if [ -f "$potfile" ]; then
		# Remove location information
		sed -i -e "/^#: /d" "$potfile"
		# Ensure the correct encoding is set
		sed -i -e "s/^\"Content-Type: text\/plain; charset=CHARSET\\\\n\"$/\"Content-Type: text\/plain; charset=UTF-8\\\\n\"/" \
			"$potfile"
	fi

	# Create a new .po file
	msginit --no-translator --locale="de" -i "$potfile" -o "$pofile"

	# Get the head of the file until first msgid line
	# and generate the standard header
	tmppo1=$(mktemp)
	tmppo2=$(mktemp)
	sed -e "1,/^msgid/d" "$pofile" > "$tmppo1"
	echo "# German translation of manpages" > "$pofile"
	echo "# This file is distributed under the same license as the manpages-de package." >> "$pofile"
	echo "# Copyright © of this file:" >> "$pofile"
	echo "msgid \"\"" >> "$pofile"
	cat "$pofile" "$tmppo1" > "$tmppo2"
	mv "$tmppo2" "$pofile"
	rm -f "$tmppo1" "$tmppo2"

	# Adjust two header lines
	sed -i -e "s/^\"Language-Team: none\\\n\"$/\"Language-Team: German <debian-l10n-german@lists.debian.org>\\\n\"/" "$pofile"
	sed -i -e "s/^\"Project-Id-Version: manpages-de .*$/\"Project-Id-Version: manpages-de\\\n\"/" "$pofile"

	# Finally, populate the translation from the compendium.
	./update-po.sh "$pofile"
done
