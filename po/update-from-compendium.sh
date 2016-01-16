#!/bin/sh
#
# Copyright © 2010-2012 Tobias Quathamer <toddy@debian.org>
# 2016 Helge Kreutzmann <debian@helgefjell.de>
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
	echo "The po file $1 could not be found."
	exit 1
fi

backup=$(mktemp)
cp "$1" "$backup"

# Generate custom compendium (simplified for this purpose)
custom=$(mktemp)
header=$(mktemp)
sed -n "1,/^$/p" "$1" > "$header"
msgcat --use-first "$header" compendium.po > "$custom"

# Update .po file from master file
tmppo=$(mktemp)
cp $1 $tmppo

# Prefer the translations from the compendium
msgmerge --compendium "$custom" --no-fuzzy-matching /dev/null "$tmppo" > "$1"
if [ $? -ne 0 ]; then
	echo "Fehler bei der Ausführung von msgmerge."
	rm -f "$header" "$tmppo" "$custom" "$backup" "$result"
	exit 1
fi

# Determine if the only change is the "POT-Creation-Date:" header
# If so, copy back the backup to revert that change
sed -f remove-potcdate.sed < "$backup" > "$tmppo"
sed -f remove-potcdate.sed < "$1" > "$custom"
if cmp "$tmppo" "$custom" >/dev/null 2>&1; then \
	mv "$backup" "$1"; \
fi

# Cleanup
rm -f "$header" "$tmppo" "$custom" "$backup" "$result"
