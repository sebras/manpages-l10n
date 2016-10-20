#!/bin/sh
#
# Copyright © 2012 Dr. Tobias Quathamer <toddy@debian.org>
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

# Generate AUTHORS file
echo "The following people have contributed to the german translation" > AUTHORS
echo "of Linux manpages. The list is sorted alphabetically." >> AUTHORS
echo >> AUTHORS

# Extract all translators from the copyright headers
for translation in `find po/man? -name "*po" | sort`; do
	# Use the header up until the first msgid
	# and remove the comment character
	translators=`sed '/msgid/q;s/^#\s\+//' "$translation" |
	# Throw away the common (non translator) lines
	grep -v "German translation of manpages" |
	grep -v "This file is distributed under the same license as the manpages-de package." |
	grep -v "Copyright © of this file:" |
	grep -v "msgid" |
	# Split lines to extract the name (and e-mail address)
	cut -f1 -d","`
	# Save a list of all translators in a temporary file for copyright determination
	echo "$translators" >> translators.list
done
# Sort, unique and remove blank lines from file
sort translators.list | uniq | sed -e "/^$/d" > tmp.list
cat tmp.list >> AUTHORS
rm tmp.list translators.list
