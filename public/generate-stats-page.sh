#!/bin/bash
#
# Copyright © 2018-2019 Dr. Tobias Quathamer <toddy@debian.org>
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

# Clean all generated files
rm -f *html

# Create header, using MET/MEST
timestamp=$(TZ='Europe/Berlin' date "+%d.%m.%Y, %H:%M Uhr")

# Determine distribution names from upstream directory.
distributions=$(find ../upstream -maxdepth 1 -type d | cut -d/ -f3 | LC_ALL=C sort)
distribution_count=$(echo "$distributions" | wc --words)

# Determine manpage section names
manpage_sections=$(find ../po/de/man* -maxdepth 1 -type d | cut -d/ -f4 | LC_ALL=C sort)

# Use a tempfile for stats generation
tmppo=$(mktemp)

# Create a global index file
cat > index.html <<-END_OF_HEADER
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" href="bootstrap.min.css">
    <title>Translation of manual pages</title>
  </head>
  <body>
      <p>
        Some Text explaining the project …
      </p>

      <ul>
	<li><a href="index-fr.html">The French translation</a></li>
	<li><a href="index-de.html">The German translation</a></li>
	<li><a href="index-nl.html">The Netherlands translation</a></li>
      </ul>
   </body>
  </html>
END_OF_HEADER


# Create the index file
cat > index-de.html <<-END_OF_HEADER
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
      <h1>Liste der Dateien, die nicht vollständig ins Deutsche übersetzt sind</h1>
      <p>Stand: $timestamp</p>
      <p>
        <a class="btn btn-primary" href="untranslated-de.html">Unübersetzte Handbuchseiten</a>
      </p>
END_OF_HEADER

# Create an overview of untranslated manpages
cat > untranslated-de.html <<-END_OF_HEADER
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
      <h1>Liste der Dateien, die nicht ins Deutsche übersetzt sind</h1>
      <p>Stand: $timestamp</p>
      <p>
        <a class="btn btn-primary" href="index-de.html">Deutsche Übersicht</a>
      </p>
END_OF_HEADER

for distribution in $distributions; do
  echo "<p><a class=\"btn btn-primary\" href=\"#$distribution\">$distribution</a></p>" >> untranslated-de.html
done

# Set up files for each distribution
for distribution in $distributions; do
  echo "<p><a class=\"btn btn-primary\" href=\"$distribution-de.html\">$distribution</a></p>" >> index-de.html

  cat > $distribution-de.html <<-END_OF_HEADER
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
        <h1>Liste der Dateien, die nicht vollständig ins Deutsche übersetzt sind</h1>
        <h2>$distribution</h2>
        <p>Stand: $timestamp</p>
        <p>
          <a class="btn btn-primary" href="index-de.html">Deutsche Übersicht</a>
        </p>
        <p>
          <a class="btn btn-primary" href="https://salsa.debian.org/manpages-l10n-team/manpages-l10n">Git-Depot ansehen</a>
        </p>
END_OF_HEADER

  for manpage_section in $manpage_sections; do
  	section_count=0
    table_rows=""
    translations=$(find "../po/de/$manpage_section" -name "*.po" | LC_ALL=C sort)
    for translation in $translations; do
      # Create a po file for the specific distribution
      LC_ALL=C msggrep --location="$distribution" "$translation" > "$tmppo"
      # Check if the file has a size > 0
      if [ -s "$tmppo" ]; then
        # Get the stats for that po file
        stats=$(LC_ALL=C msgfmt -cv -o /dev/null "$tmppo" 2>&1)
        # Get the translated messages
        translated=$(echo $stats | sed -e "s/\([0-9]\+\) translated message.*/\1/")
        # Check if there are at least two numbers
        fuzzy_or_untranslated=$(echo $stats | grep "[0-9]\+[^0-9]\+[0-9]\+")
        if [ -n "$fuzzy_or_untranslated" ]; then
        	# Remove the last text part
        	all=$(echo $stats | sed -e "s/[^0-9]\+$//")
        	# Replace all remaining text parts with the plus sign
        	all=$(echo $all | sed -e "s/[^0-9]\+/+/g")
        	# Calculate the sum
        	all=$(echo $all | bc)
        	# Calculate the percentage
        	percentage=$(echo "100 * $translated / $all" | bc)
        	# Calculate needed translations for 80%
        	needed=""
          highlight=""
        	if [[ $percentage -lt 80 ]]; then
        		needed=$(echo "(800 * $all / 100 + 9) / 10 - $translated" | bc)
            highlight="class=\"table-danger\""
        	fi
          table_rows=$(cat<<-EOF_ROW
          $table_rows
          <tr $highlight>
          <td>$(basename $translation .po)</td>
          <td class="text-right">$percentage%</td>
          <td class="text-right">$needed</td>
          <td>$stats</td>
EOF_ROW
)
          section_count=$(($section_count+1))
        fi
      fi
    done
    if [ $section_count -gt 0 ]; then
			cat >> $distribution-de.html <<-EOF_TABLE
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
      echo $table_rows >> $distribution-de.html
      echo "</tbody>" >> $distribution-de.html
			echo "</table>" >> $distribution-de.html
      echo '<div class="alert alert-primary" role="alert">' >> $distribution-de.html
			if [ $section_count -eq 1 ]; then
				echo "1 Datei ist nicht vollständig übersetzt." >> $distribution-de.html
			else
				echo "$section_count Dateien sind nicht vollständig übersetzt." >> $distribution-de.html
			fi
      echo "</div>" >> $distribution-de.html
    fi
  done

  echo "</div>" >> $distribution-de.html
  echo "</body>" >> $distribution-de.html
  echo "</html>" >> $distribution-de.html

  # Create an overview of untranslated manpages
  echo "<h2 id=\"$distribution\">$distribution</h2>" >> untranslated-de.html

  cat >> untranslated-de.html <<-EOF_TABLE
  <table class="table table-striped table-bordered table-sm">
    <thead class="thead-dark">
      <tr>
        <th scope="col" width="25%">Paket</th>
        <th scope="col" width="75%">Handbuchseiten</th>
      </tr>
    </thead>
    <tbody>
EOF_TABLE

  previous_package=""
  while read line; do
    package=$(echo "$line" | cut -d":" -f1)
    manpage=$(echo "$line" | cut -d":" -f2)
    # Special case: If this is the first line, previous_package is empty.
    if [ -z "$previous_package" ]; then
      previous_package="$package"
    fi
    if [ "$previous_package" != "$package" ]; then
      echo "<tr>" >> untranslated-de.html
      echo "<td>$previous_package</td>" >> untranslated-de.html
      echo "<td>$manpages</td>" >> untranslated-de.html
      echo "</tr>" >> untranslated-de.html
      previous_package="$package"
      manpages="$manpage"
    else
      manpages="$manpages $manpage"
    fi
  done < ../upstream/$distribution/untranslated.txt

  echo "</tbody>" >> untranslated-de.html
  echo "</table>" >> untranslated-de.html

  echo '<div class="alert alert-primary" role="alert">' >> untranslated-de.html
  echo "Insgesamt sind " >> untranslated-de.html
  (wc -l  ../upstream/$distribution/untranslated.txt | cut -d" " -f1) >> untranslated-de.html
  echo " Dateien nicht übersetzt." >> untranslated-de.html
  echo "</div>" >> untranslated-de.html
done

echo "</div>" >> untranslated-de.html
echo "</body>" >> untranslated-de.html
echo "</html>" >> untranslated-de.html

echo "</div>" >> index-de.html
echo "</body>" >> index-de.html
echo "</html>" >> index-de.html

rm $tmppo
