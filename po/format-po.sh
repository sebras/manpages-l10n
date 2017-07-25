#!/bin/sh
#
# Copyright © 2010-2017 Dr. Tobias Quathamer <toddy@debian.org>
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

# Determine directory names from upstream directory.
directories=$(find ../upstream -maxdepth 1 -type d | cut -d/ -f3- | LC_ALL=C sort)

header=$(mktemp)
tail=$(mktemp)
result=$(mktemp)

for directory in $directories; do
	echo "Processing directory '$directory'"
	translations=$(find "$directory"/man* -name "*.po" | LC_ALL=C sort)
	for translation in $translations; do
		# Get the head of the file until first msgid line
		# and filter out all comment lines without year information
		sed -n "1,/^msgid/p" "$translation" |
		grep -v "^# German translation of manpages" |
		grep -v "^# This file is distributed under the same license as the manpages-de package." |
		grep -v "^# Copyright © of this file:" |
		grep -v "^#\s*$" > "$header"
		sed -e "1,/^msgid/d" "$translation" > "$tail"
		echo "# German translation of manpages" > "$result"
		echo "# This file is distributed under the same license as the manpages-de package." >> "$result"
		echo "# Copyright © of this file:" >> "$result"
		cat "$result" "$header" "$tail" > "$translation"
		# Now remove location information, which is not needed in our case
		sed -i -e "/^#: /d" "$translation"
		# Reformat manpage to wrap lines
		msgcat "$translation" > "$result"
		mv "$result" "$translation"
	done
done
rm -f "$header" "$tail" "$result"
