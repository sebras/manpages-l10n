#!/bin/bash
#
# Copyright © 2018-2019 Dr. Tobias Quathamer <toddy@debian.org>
# Copyright © 2019 Helge Kreutzmann <debian@helgefjell.de>
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

# Determine distribution names from upstream directory.
distributions=$(find ../upstream -maxdepth 1 -type d | cut -d/ -f3 | LC_ALL=C sort)
distribution_count=$(echo "$distributions" | wc --words)

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
        <li><a href="index-nl.html">The Dutch translation</a></li>
      </ul>
   </body>
  </html>
END_OF_HEADER

for tlang in de fr nl; do
    echo $tlang

# Determine manpage section names
manpage_sections=$(find ../po/$tlang/man* -maxdepth 1 -type d | cut -d/ -f4 | LC_ALL=C sort)

. ./setup-$tlang.inc

# Create the index file
cat index-$tlang.stub | awk -vTS="$timestamp" '{sub("TIMESTAMP",TS); print $0}' > index-$tlang.html

# Create an overview of untranslated manpages
cat untranslated-$tlang.stub | awk -vTS="$timestamp" '{sub("TIMESTAMP",TS); print $0}' > untranslated-$tlang.html

for distribution in $distributions; do
  echo "<p><a class=\"btn btn-primary\" href=\"#$distribution\">$distribution</a></p>" >> untranslated-$tlang.html
done

# Set up files for each distribution
for distribution in $distributions; do
  echo "<p><a class=\"btn btn-primary\" href=\"$distribution-$tlang.html\">$distribution</a></p>" >> index-$tlang.html

cat distribution-$tlang.stub | awk -vTS="$timestamp" '{sub("TIMESTAMP",TS); print $0}'| awk -vDB="$distribution" '{sub("DISTRIBUTION",DB); print $0}' > $distribution-$tlang.html

  echo "  $distribution"
  echo -n "   "

  for manpage_section in $manpage_sections; do
  	section_count=0
    table_rows=""
    echo -n " $manpage_section"
    translations=$(find "../po/$tlang/$manpage_section" -name "*.po" | LC_ALL=C sort)
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
			cat >> $distribution-$tlang.html <<-EOF_TABLE
			<table class="table table-striped table-bordered table-sm">
			  <thead class="thead-dark">
			    <tr>
			      <th scope="col" width="25%">$cname_name</th>
			      <th scope="col" width="10%">$cname_percent</th>
			      <th scope="col" width="15%">$cname_missing_strings</th>
			      <th scope="col" width="50%">$cname_statistics</th>
			    </tr>
			  </thead>
			  <tbody>
EOF_TABLE
      echo $table_rows >> $distribution-$tlang.html
      echo "</tbody>" >> $distribution-$tlang.html
			echo "</table>" >> $distribution-$tlang.html
      echo '<div class="alert alert-primary" role="alert">' >> $distribution-$tlang.html
			if [ $section_count -eq 1 ]; then
				echo "$cname_onepageuntranslated" >> $distribution-$tlang.html
			else
				echo "$section_count $cname_severalpagesuntranslated" >> $distribution-$tlang.html
			fi
      echo "</div>" >> $distribution-$tlang.html
    fi
  done
  # This is for the line break of the status messages
  echo

  echo "</div>" >> $distribution-$tlang.html
  echo "</body>" >> $distribution-$tlang.html
  echo "</html>" >> $distribution-$tlang.html

  # Create an overview of untranslated manpages
  echo "<h2 id=\"$distribution\">$distribution</h2>" >> untranslated-$tlang.html

  cat >> untranslated-$tlang.html <<-EOF_TABLE
  <table class="table table-striped table-bordered table-sm">
    <thead class="thead-dark">
      <tr>
        <th scope="col" width="25%">$cname_packet</th>
        <th scope="col" width="75%">$Handbuchseiten</th>
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
      echo "<tr>" >> untranslated-$tlang.html
      echo "<td>$previous_package</td>" >> untranslated-$tlang.html
      echo "<td>$manpages</td>" >> untranslated-$tlang.html
      echo "</tr>" >> untranslated-$tlang.html
      previous_package="$package"
      manpages="$manpage"
    else
      manpages="$manpages $manpage"
    fi
  done < ../upstream/$distribution/untranslated.txt

  echo "</tbody>" >> untranslated-$tlang.html
  echo "</table>" >> untranslated-$tlang.html

  echo '<div class="alert alert-primary" role="alert">' >> untranslated-$tlang.html
  echo "$cname_intotal1" >> untranslated-$tlang.html
  (wc -l  ../upstream/$distribution/untranslated.txt | cut -d" " -f1) >> untranslated-$tlang.html
  echo "$cname_intotal2" >> untranslated-$tlang.html
  echo "</div>" >> untranslated-$tlang.html
done

echo "</div>" >> untranslated-$tlang.html
echo "</body>" >> untranslated-$tlang.html
echo "</html>" >> untranslated-$tlang.html

echo "</div>" >> index-$tlang.html
echo "</body>" >> index-$tlang.html
echo "</html>" >> index-$tlang.html
echo ""
done

rm $tmppo
