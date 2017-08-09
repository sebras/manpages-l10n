#!/bin/sh
#
# Copyright © 2017 Dr. Tobias Quathamer <toddy@debian.org>
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

# Handle primary messages
compendium=$(mktemp)
msgcat --use-first common-primary/*po > "$compendium"
rm -f common-primary/*po
tmppo=$(mktemp)
for potfile in ../templates/common-primary/*pot; do
	pofile=$(basename "$potfile")
	# Remove the letter "t" at the end
	pofile=${pofile%t}
	msgmerge --force-po --previous --compendium "$compendium" /dev/null "$potfile" > "$tmppo"
	mv "$tmppo" "common-primary/$pofile"
done

# Handle secondary messages, using also the compendium
# from primary, because some strings may have shifted
# between levels.
msgcat --use-first common-secondary/*po "$compendium" > "$tmppo"
mv "$tmppo" "$compendium"
rm -f common-secondary/*po
for potfile in ../templates/common-secondary/*pot; do
	pofile=$(basename "$potfile")
	# Remove the letter "t" at the end
	pofile=${pofile%t}
	msgmerge --force-po --previous --compendium "$compendium" /dev/null "$potfile" > "$tmppo"
	mv "$tmppo" "common-secondary/$pofile"
done

rm -f "$compendium" "$tmppo"
