#!/bin/bash
#
# Copyright © 2018-2019 Dr. Tobias Quathamer <toddy@debian.org>
# Copyright © 2019,2020,2022 Helge Kreutzmann <debian@helgefjell.de>
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

# Determine list of languages
cd ../po
languages=$(find . -maxdepth 1 -type d | grep -v scripts | grep -v "^\.$" | sed 's/\.\///' | sort)
cd - > /dev/null

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
<h1>Welcome to the l10n project</h1>
<p>
  In the past, several projects independently maintained man page translation. Some tried to manually keep
  the translation and the upstream text in sync, while others used tools like 
  <a href="https://po4a.org/">po4a</a>. Some where tied into certain distributions, while others were generic. 
</p>
<p>
  This project aims to ease the burden for translation teams by providing a common infrastructure
  for obtaining the upstream sources (for various distributions), automaticly maintaining the 
  translated text with automatisms where possible (e.g. by maintaining lists of identical strings,
  automatic translation of dates) and finally the regular distribution of tarballs, ready for
  integration into several major distributions (and usuable by others as well, of course).
</p>
<p>
  Currently, the following languages are integrated:
  </p>
      <ul>
        <li><a href="index-cs.html">The Czech translation</a></li>
        <li><a href="index-da.html">The Danish translation</a></li>
        <li><a href="index-nl.html">The Dutch translation</a></li>
        <li><a href="index-fi.html">The Finnish translation</a></li>
        <li><a href="index-fr.html">The French translation</a></li>
        <li><a href="index-de.html">The German translation</a></li>
        <li><a href="index-el.html">The Greek translation</a></li>
        <li><a href="index-hu.html">The Hungarian translation</a></li>
        <li><a href="index-id.html">The Indonesian translation</a></li>
        <li><a href="index-it.html">The Italian translation</a></li>
        <li><a href="index-mk.html">The Macedonian translation</a></li>
        <li><a href="index-nb.html">The Norwegian bokmål translation</a></li>
        <li><a href="index-fa.html">The Persian translation</a></li>
        <li><a href="index-pl.html">The Polish translation</a></li>
        <li><a href="index-pt_BR.html">The Brazilian Portuguese translation</a></li>
        <li><a href="index-ro.html">The Romanian translation</a></li>
        <li><a href="index-sr.html">The Serbian translation</a></li>
        <li><a href="index-es.html">The Spanish translation</a></li>
        <li><a href="index-sv.html">The Swedish translation</a></li>
        <li><a href="index-vi.html">The Vietnamese translation</a></li>
      </ul>
      <p>
      You also  might want to <a href="https://salsa.debian.org/manpages-l10n-team/manpages-l10n">view the git repository</a> directly.
      </p>
 <h1>Other man pages translations</h1>
 <p>
   Some further man page translations are hosted independently. They consider various parts of man pages and use various tools. For
   details please contact the respective maintainers.
   </p>
     <ul>
       <li><a href="https://gitlab.com/arabeyes-i18n/manpages">Arabic</a>, last commit 2006, using po4a, only few pages</li>
       <li><a href="https://github.com/man-pages-zh/man-pages-translation">Chinese</a>, active, using po4a</li>
       <li><a href="https://linuxjm.osdn.jp/">Japanese</a>, active, but not current (e.g. partially on the state of 2011/2016)</li>
       <li><a href="https://web.archive.org/web/20060205162241/http://man.kldp.org/wiki">Korean (archived website)</a>, appears inactive, last release 2005, license situation unclear</li>
       <li>Portuguese (no web page), last release 2004</li>
       <li><a href="https://sourceforge.net/projects/man-pages-ru/">Russian</a>, last activity 2019-10-17, only man-pages itself (e.g. no coreutils); probably to be considered as inactive</li>
       <li><a href="https://sourceforge.net/projects/belgeler/files/man-pages-tr/">Turkish</a>, appears inactive, last release 2008</li>
     </ul>
   </body>
  </html>
END_OF_HEADER

for tlang in $languages; do
    echo $tlang

# Determine manpage section names
manpage_sections=$(find ../po/$tlang/man* -maxdepth 1 -type d | cut -d/ -f4 | LC_ALL=C sort)

. ./setup-$tlang.inc

# Create the index file
cat index-$tlang.stub | awk -vTS="$timestamp" '{sub("TIMESTAMP",TS); print $0}' > index-$tlang.html

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

done

echo "</div>" >> index-$tlang.html
echo "</body>" >> index-$tlang.html
echo "</html>" >> index-$tlang.html
echo ""

# The new approach
  if [ -r untranslated-$tlang.2.htm ]; then
      cat untranslated-$tlang.2.htm > untranslated-$tlang.html
  fi
done

rm $tmppo
