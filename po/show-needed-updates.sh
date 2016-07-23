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

count=0
for translation in `find man?/ -name "*.po" | sort`; do
	stats=`msgfmt -cv -o /dev/null $translation 2>&1`
	fuzzy_or_untranslated=`echo $stats | grep "[0-9]\+[^0-9]\+[0-9]\+"`
	if [ -n "$fuzzy_or_untranslated" ]; then
		# Remove the last text part
		all=`echo $stats | sed -e "s/[^0-9]\+$//"`
		# Replace all remaining text parts with the plus sign
		all=`echo $all | sed -e "s/[^0-9]\+/+/g"`
		# Calculate the sum
		all=`echo $all | bc`
		# Get the translated messages
		translated=`echo $stats | sed -e "s/\([0-9]\+\).*/\1/"`
		# Calculate the percentage
		percentage=`echo "100 * $translated / $all" | bc`
		echo `basename $translation`: $percentage%
		echo $stats
		echo
		count=$(($count+1))
	fi
done
if [ $count -eq 0 ]; then
	echo "Alle Dateien sind vollständig übersetzt."
else
	if [ $count -eq 1 ]; then
		echo "1 Datei ist nicht vollständig übersetzt."
	else
		echo "$count Dateien sind nicht vollständig übersetzt."
	fi
fi
