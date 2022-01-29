#!/bin/bash
#
# Copyright © 2022 Helge Kreutzmann <debian@helgefjell.de>
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


# Determine all languages
cd ../po
MT_LANGLIST=$(find . -maxdepth 1 -type d | grep -v scripts | grep -v "^\.$" | sed 's/\.\///' | sort)
cd - > /dev/null

echo -n "Processing: "
for tlang in $MT_LANGLIST; do
    echo -n "$tlang "
    #htmlfile=untranslated-$tlang.html
    htmlfile=untranslated-$tlang.2.html

    . ./setup-$tlang.inc

    # Supersede inc file - we want the date of the untranslated.txt, not the one from this run
    timestamp=$(stat --format="%y" ../po/$tlang/untranslated.txt)

    cat untranslated-$tlang.stub | awk -vTS="$timestamp" '{sub("TIMESTAMP",TS); print $0}' > $htmlfile

    cat >> $htmlfile <<-EOF_TABLE
  <table class="table table-striped table-bordered table-sm">
    <thead class="thead-dark">
      <tr>
        <th scope="col" width="25%">$cname_packet</th>
        <th scope="col" width="75%">$cname_manpages</th>
      </tr>
    </thead>
    <tbody>
EOF_TABLE

    previous_package=""
    while read line; do
	package=$(echo "$line" | cut -d" " -f1)
	manpage=$(echo "$line" | cut -d" " -f4)
	# Special case: If this is the first line, previous_package is empty.
	if [ -z "$previous_package" ]; then
	previous_package="$package"
	fi
	if [ "$previous_package" != "$package" ]; then
	    echo "<tr>" >> $htmlfile
	    echo "<td>$previous_package</td>" >> $htmlfile
	    echo "<td>$manpages</td>" >> $htmlfile
	    echo "</tr>" >> $htmlfile
	    previous_package="$package"
	    manpages="$manpage"
	else
	    manpages="$manpages $manpage"
	fi
    done < ../po/$tlang/untranslated.txt

    echo "</tbody>" >> $htmlfile
    echo "</table>" >> $htmlfile

    echo '<div class="alert alert-primary" role="alert">' >> $htmlfile
    echo "$cname_intotal1" >> $htmlfile
    (wc -l  ../po/$tlang/untranslated.txt | cut -d" " -f1) >> $htmlfile
    echo "$cname_intotal2" >> $htmlfile
    echo "</div>" >> $htmlfile

    echo "</div>" >> $htmlfile
    echo "</body>" >> $htmlfile
    echo "</html>" >> $htmlfile

    echo "</div>" >> $htmlfile
    echo "</body>" >> $htmlfile
    echo "</html>" >> $htmlfile
done
