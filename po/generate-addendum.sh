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

pofile="$1"
tmpfile=`mktemp`

# Use the header up until the first msgid
# and remove the comment character
translators=`sed '/msgid/q;s/^#\s\+//' "$pofile" |
# Throw away the common (non translator) lines
grep -a -v "German translation of manpages" |
grep -a -v "This file is distributed under the same license as the manpages-de package." |
grep -a -v "Copyright © of this file:" |
grep -a -v "msgid" |
# Split lines to extract the name (and e-mail address)
cut -f1 -d","`
# Determine number of translators
number_translators=`echo "$translators" | wc -l`

# Output of common header
echo "PO4A-HEADER:mode=after;position=^\.(TH|Dt);beginboundary=FakePo4aBoundary" > "$tmpfile"
echo >> "$tmpfile"
# Special case for manpages which use mdoc syntax (currently only tar.1)
case "$pofile" in
	tar.1.po ) echo ".Sh ÜBERSETZUNG" >> "$tmpfile" ;;
	* ) echo ".SH ÜBERSETZUNG" >> "$tmpfile" ;;
esac
echo "Die deutsche Übersetzung dieser Handbuchseite wurde von" >> "$tmpfile"

# Warn if the translators string is empty
if [ -z "$translators" ]; then
	echo "Warning: No translators found for '$pofile'."
fi
# Apply correct formatting, depending on the number of translators
if [ $number_translators -eq 1 ]; then
	echo "$translators" >> "$tmpfile"
fi
if [ $number_translators -eq 2 ]; then
	echo "$translators" | head -n1 >> "$tmpfile"
	echo "und" >> "$tmpfile"
	echo "$translators" | tail -n1 >> "$tmpfile"
fi
if [ $number_translators -ge 3 ]; then
	echo "$translators" | head -n$(($number_translators - 2)) | perl -pe "s/$/,/" >> "$tmpfile"
	echo "$translators" | tail -n2 | head -n1 >> "$tmpfile"
	echo "und" >> "$tmpfile"
	echo "$translators" | tail -n1 >> "$tmpfile"
fi

# Output of common ending
echo "erstellt." >> "$tmpfile"
mv "$tmpfile" `basename "$pofile" .po`.add
