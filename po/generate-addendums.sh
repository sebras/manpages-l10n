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

for translation in `find man?/ -name "*po" | sort`; do
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
	# Determine number of translators
	number_translators=`echo "$translators" | wc -l`
	
	# Output of common header
	echo "PO4A-HEADER:mode=after;position=^\.(TH|Dt);beginboundary=FakePo4aBoundary" > tmp.add
	echo >> tmp.add
	# Special case for manpages which use mdoc syntax (currently only tar.1)
	case $translation in
		*/tar.1.po ) echo ".Sh ÜBERSETZUNG" >> tmp.add ;;
		* ) echo ".SH ÜBERSETZUNG" >> tmp.add ;;
	esac
	echo "Die deutsche Übersetzung dieser Handbuchseite wurde von" >> tmp.add
	
	# Apply correct formatting, depending on the number of translators
	if [ $number_translators -eq 1 ]; then
		echo "$translators" >> tmp.add
	fi
	if [ $number_translators -eq 2 ]; then
		echo "$translators" | head -n1 >> tmp.add
		echo "und" >> tmp.add
		echo "$translators" | tail -n1 >> tmp.add
	fi
	if [ $number_translators -ge 3 ]; then
		echo "$translators" | head -n$(($number_translators - 2)) | perl -pe "s/$/,/" >> tmp.add
		echo "$translators" | tail -n2 | head -n1 >> tmp.add
		echo "und" >> tmp.add
		echo "$translators" | tail -n1 >> tmp.add
	fi
	
	# Output of common ending
	echo "erstellt." >> tmp.add
	mv tmp.add `dirname $translation`/`basename $translation .po`.add
done
