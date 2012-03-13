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

set -e

# Make sure there is an argument
if [ -z "$1" ]; then \
	echo "Geben Sie die .po-Datei an." ; \
	exit ; \
fi

pofile="$1"
program=`basename "$pofile" .po | sed -e "s/\.[0-9]//"`
section=`basename "$pofile" .po | sed -e "s/.\+\.//"`

# Get translator
translator=`grep ^\"Last-Translator: "$pofile" |
	sed -e "s/.\+Last-Translator:\s\+\(.\+\)\s\+\(<[^>]\+>\).\+/\1 \2/"`

# Get statistics
stats=`LC_ALL=C msgfmt -cv -o /dev/null "$pofile" 2>&1 |
	sed -e "s/\s*translated messages\?/t/;
		s/\s*fuzzy translations\?/f/;
		s/\s*untranslated messages\?/u/;
		s/\.//"`

# Reformat file to use the correct width
tmpname=`mktemp`
msgcat "$pofile" > "$tmpname"
mv "$tmpname" "$pofile"

git add "$pofile"
git commit --author "$translator" -m "$program.$section: $stats"
