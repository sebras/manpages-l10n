#!/bin/sh
#
# Copyright © 2012 Tobias Quathamer <toddy@debian.org>
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

# Generate COPYRIGHT file
cat > COPYRIGHT <<END_OF_COPYRIGHT
Copyright information:

    Please note that these man pages are distributed under a variety of
    copyright licenses.  Although these licenses permit free distribution
    of the nroff sources contained in this package, commercial distribution
    may impose other requirements (e.g., acknowledgement of copyright or
    inclusion of the raw nroff sources with the commercial distribution).
    If you distribute these man pages commercially, it is your
    responsibility to figure out your obligations.  (For many man pages,
    these obligations require you to distribute nroff sources with any
    pre-formatted man pages that you provide.)  Each file that contains
    nroff source for a man page also contains the author(s) name, email
    address, and copyright notice.


Translators:
END_OF_COPYRIGHT

# Extract all translators from the copyright headers
for translation in `find po/man? -name "*po" | sort`; do
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
	# Save a list of all translators in a temporary file for copyright determination
	echo "$translators" >> translators.list
done
# Sort, unique and remove blank lines from file
sort translators.list | uniq | sed -e "/^$/d" > tmp.list
perl -ne 'print "\t"; print;' tmp.list >> COPYRIGHT
rm tmp.list translators.list
