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

    . ./setup-$tlang.inc

    # Supersede inc file - we want the date of the untranslated.txt, not the one from this run
    timestamp=$(stat --format="%y" ../po/$tlang/untranslated.txt)

    cat untranslated-$tlang.stub | awk -vTS="$timestamp" '{sub("TIMESTAMP",TS); print $0}' > untranslated-$tlang.html

    cat >> untranslated-$tlang.html <<-EOF_TABLE
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
	    echo "<tr>" >> untranslated-$tlang.html
	    echo "<td>$previous_package</td>" >> untranslated-$tlang.html
	    echo "<td>$manpages</td>" >> untranslated-$tlang.html
	    echo "</tr>" >> untranslated-$tlang.html
	    previous_package="$package"
	    manpages="$manpage"
	else
	    manpages="$manpages $manpage"
	fi
    done < ../po/$tlang/untranslated.txt

    echo "</tbody>" >> untranslated-$tlang.html
    echo "</table>" >> untranslated-$tlang.html

    echo '<div class="alert alert-primary" role="alert">' >> untranslated-$tlang.html
    echo "$cname_intotal1" >> untranslated-$tlang.html
    (wc -l  ../po/$tlang/untranslated.txt | cut -d" " -f1) >> untranslated-$tlang.html
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
