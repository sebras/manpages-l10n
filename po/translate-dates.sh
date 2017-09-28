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

# Require two arguments (the .po file of the manpage and the .pot file)
if [ ! -f "$1" ]; then
	echo "The po file '$1' could not be found."
	exit 1
fi
if [ ! -f "$2" ]; then
	echo "The pot file '$2' could not be found."
	exit 1
fi

# Is there a translatable date in the file?
translatable_date=$(grep -P "^msgid \"[1-2][0-9]{3}-[0-1][0-9]-[0-3][0-9]\"$" "$1")
if [ -z "$translatable_date" ]; then
	exit
fi

# Split the date into components
date_year=$(echo "$translatable_date" | sed -e "s/.\+\([0-9]\{4\}\).\+/\1/")
date_month=$(echo "$translatable_date" | sed -e "s/.\+\([0-9]\{2\}\)-.\+/\1/")
date_day=$(echo "$translatable_date" | sed -e "s/.\+-\([0-9]\{2\}\)\"/\1/")

# Set up the German month name
case "$date_month" in
	"01") month="Januar" ;;
	"02") month="Februar" ;;
	"03") month="März" ;;
	"04") month="April" ;;
	"05") month="Mai" ;;
	"06") month="Juni" ;;
	"07") month="Juli" ;;
	"08") month="August" ;;
	"09") month="September" ;;
	"10") month="Oktober" ;;
	"11") month="November" ;;
	"12") month="Dezember" ;;
	*) month="ERROR" ;;
esac

# Remove leading zero from day
first_digit=$(echo "$date_day" | cut -c1)
if [ "x$first_digit" = "x0" ]; then
	date_day=$(echo "$date_day" | cut -c2)
fi

# Remove the existing translation from the .po file
newfile=$(mktemp)
msggrep -v -K -E -e "^[1-2][0-9]{3}-[0-1][0-9]-[0-3][0-9]$" "$1" > "$newfile"

# Add the translated pair at the end of the file
echo >> "$newfile"
echo $translatable_date >> "$newfile"
echo "msgstr \"$date_day. $month $date_year\"" >> "$newfile"

# Move translation back to original filename
msgmerge --previous "$newfile" "$2" > "$1"
