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

rm -rf generated
mkdir generated
for section in `seq 8`; do
	mkdir generated/man$section;
done

cd po && ./generate-addendums.sh && cd ..

for translation in po/man?/*.po; do
	manpage=`basename $translation .po`;
	section=`basename $manpage | sed -e "s/.\+\.//"`;
	original=`find english/ -type f -name "$manpage"`;
	addendum=`echo $translation | sed -e "s/\.po$/.add/"`;
	# Determine if an encoding is specified,
	# otherwise fall back to ISO-8859-1
	coding=`grep "\-\*\- coding:" "$original" | sed -e "s/.*coding:\s\+\([^ ]\+\).*/\1/"`
	if [ -z "$coding" ]; then
		coding="ISO-8859-1"
	fi
	po4a-translate \
		-f man \
		--option groff_code=verbatim \
		--option untranslated="a.RE,\|" \
		--option generated \
		-m "$original" \
		-M "$coding" \
		-p $translation \
		-a $addendum \
		-a lizenz.add \
		-L UTF-8 \
		-l "generated/man$section/$manpage";
	# Check if the generated manpage already includes an encoding
	coding=`head -n1 "generated/man$section/$manpage" | grep "\-\*\- coding:"`
	if [ -n "$coding" ]; then
		# There is an encoding set, remove the first line
		sed -i -e "1d" "generated/man$section/$manpage"
	fi
	# Set an explicit encoding to prevent display errors
	echo "'\\\" t -*- coding: UTF-8 -*-" > encoding.txt
	cat encoding.txt "generated/man$section/$manpage" > manpage-with-encoding
	mv manpage-with-encoding "generated/man$section/$manpage"
done

rm encoding.txt
find po/ -name "*add" | xargs rm
