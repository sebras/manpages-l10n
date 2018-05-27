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

# Create header, using MET/MEST
timestamp=$(TZ='Europe/Berlin' date "+%d.%m.%Y, %H:%M Uhr")
cat<<-END_OF_HEADER
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" href="bootstrap.min.css">
    <title>Deutsche Übersetzung der Handbuchseiten</title>
  </head>
  <body>
	  <div class="container-fluid">
      <h1>Liste der Dateien, die nicht vollständig übersetzt sind</h1>
      <p>Stand: $timestamp</p>
      <p>
        <a class="btn btn-primary" href="https://salsa.debian.org/manpages-de-team/manpages-de">Git-Repository ansehen</a>
      </p>
END_OF_HEADER

# Determine directory names from upstream directory.
directories=$(find ../upstream -maxdepth 1 -type d | cut -d/ -f3- | LC_ALL=C sort)

total_count=0
for directory in $directories; do
	echo "<h2>Distribution: $directory</h2>"
	distribution_count=0
	previous_section=""
	section_count=0
	translations_tmp=$(find "../po/$directory"/man* -name "*.po" | LC_ALL=C sort)
	translations="$translations_tmp ../po/$directory/man1/cat.1.po"
	for translation in $translations; do
		man_name=$(basename $translation)
		man_section=$(echo "$translation" | cut -d/ -f4)
		if [ "$previous_section" != "$man_section" ]; then
			# We start a new man section, so create a new table
			if [ $section_count -gt 0 ]; then
				cat<<-EOF_TABLE
				<table class="table table-striped table-bordered table-sm">
				  <thead class="thead-dark">
				    <tr>
				      <th scope="col" width="25%">Name</th>
				      <th scope="col" width="10%">Prozent</th>
				      <th scope="col" width="15%">Übersetzungen bis 80%</th>
				      <th scope="col" width="50%">Statistik</th>
				    </tr>
				  </thead>
				  <tbody>
EOF_TABLE
        echo $section_table_rows
        echo "</tbody>"
				echo "</table>"
        echo '<div class="alert alert-primary" role="alert">'
				if [ $section_count -eq 1 ]; then
					echo "1 Datei ist nicht vollständig übersetzt."
				else
					echo "$section_count Dateien sind nicht vollständig übersetzt."
				fi
        echo "</div>"
			fi
			distribution_count=$(($distribution_count+$section_count))
			previous_section=$man_section
			section_table_rows=""
			section_count=0
		fi
		# Determine the stats
		stats=$(msgfmt -cv -o /dev/null $translation 2>&1)
		fuzzy_or_untranslated=$(echo $stats | grep "[0-9]\+[^0-9]\+[0-9]\+")
		if [ -n "$fuzzy_or_untranslated" ]; then
			# Remove the last text part
			all=$(echo $stats | sed -e "s/[^0-9]\+$//")
			# Replace all remaining text parts with the plus sign
			all=$(echo $all | sed -e "s/[^0-9]\+/+/g")
			# Calculate the sum
			all=$(echo $all | bc)
			# Get the translated messages
			translated=$(echo $stats | sed -e "s/\([0-9]\+\).*/\1/")
			# Calculate the percentage
			percentage=$(echo "100 * $translated / $all" | bc)
			# Calculate needed translations for 80%
			needed=""
      highlight=""
			if [ $percentage -lt 80 ]; then
				needed=$(echo "(800 * $all / 100 + 9) / 10 - $translated" | bc)
        highlight="class=\"table-danger\""
			fi
			section_table_rows=$(cat<<-EOF_ROW
      $section_table_rows
      <tr $highlight>
        <td>$man_name</td>
        <td class="text-right">$percentage%</td>
        <td class="text-right">$needed</td>
        <td>$stats</td>
      </tr>
EOF_ROW
)
			section_count=$(($section_count+1))
    fi
	done
  echo '<div class="alert alert-primary" role="alert">'
	if [ $distribution_count -eq 0 ]; then
		echo "Alle Dateien sind vollständig übersetzt."
	else
		if [ $distribution_count -eq 1 ]; then
			echo "Insgesamt ist in dieser Distribution eine Datei nicht vollständig übersetzt."
		else
			echo "Insgesamt sind in dieser Distribution $distribution_count Dateien nicht vollständig übersetzt."
		fi
	fi
  echo "</div>"
	total_count=$(($total_count+$distribution_count))
done

echo '<div class="alert alert-primary" role="alert">'
if [ $total_count -eq 0 ]; then
	echo "Alle Dateien sind vollständig übersetzt."
else
	if [ $total_count -eq 1 ]; then
		echo "Insgesamt ist eine Datei nicht vollständig übersetzt."
	else
		echo "Insgesamt sind $total_count Dateien nicht vollständig übersetzt."
	fi
fi
echo "</div>"

echo "</div>"
echo "</body>"
echo "</html>"
