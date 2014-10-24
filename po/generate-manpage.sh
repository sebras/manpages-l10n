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

top_srcdir="$1"
manpage="$2"

translation="$manpage".po
addendum="$manpage".add
section=`basename "$manpage" | sed -e "s/.\+\.//"`

# Try to locate original manpage
original=$top_srcdir/english/man$section/$manpage
# If the original is not there, try using the system wide installation
if [ ! -f "$original" ]; then
	original=/usr/share/man/man$section/$manpage
fi
# Try a gzip compressed version
if [ ! -f "$original" ]; then
	original=/usr/share/man/man$section/$manpage.gz
	if [ -f "$original" ]; then
		# The manpage exists, but needs to be decompressed
		uncompressed_manpage=`mktemp`
		gzip -d -c "$original" > "$uncompressed_manpage"
		original="$uncompressed_manpage"
	fi
fi
# Try a xz compressed version
if [ ! -f "$original" ]; then
	original=/usr/share/man/man$section/$manpage.xz
	if [ -f "$original" ]; then
		# The manpage exists, but needs to be decompressed
		uncompressed_manpage=`mktemp`
		xz -d -c "$original" > "$uncompressed_manpage"
		original="$uncompressed_manpage"
	fi
fi
# Cannot generate manpage if the original could not be found
if [ ! -f "$original" ]; then
	echo "The original manpage for $manpage could not be found." >&2
	exit
fi

# Determine if an encoding is specified,
# otherwise fall back to ISO-8859-1
coding=`grep "\-\*\- coding:" "$original" | sed -e "s/.*coding:\s\+\([^ ]\+\).*/\1/"`
if [ -z "$coding" ]; then
	coding="ISO-8859-1"
fi

po4a-translate \
	-f man \
	--option groff_code=verbatim \
	--option generated \
	--option untranslated="a.RE,\|" \
	--option unknown_macros=untranslated \
	-m "$original" \
	-M "$coding" \
	-p "$translation" \
	-a "$addendum" \
	-a "$top_srcdir/lizenz.add" \
	-L UTF-8 \
	-l "$manpage";

if [ -f "$manpage" ]; then
	tmp_encoding=`mktemp`
	tmp_manpage=`mktemp`
	# Check if the generated manpage already includes an encoding
	coding=`head -n1 "$manpage" | grep "coding:"`
	if [ -n "$coding" ]; then
		# There is an encoding set, remove the first line
		sed -i -e "1d" "$manpage"
	fi
	# Set an explicit encoding to prevent display errors
	echo ".\\\" -*- coding: UTF-8 -*-" > "$tmp_encoding"
	cat "$tmp_encoding" "$manpage" > "$tmp_manpage"
	mv "$tmp_manpage" "$manpage"
	rm "$tmp_encoding"
fi

# Clean up temporary file, if necessary
if [ -f "$uncompressed_manpage" ]; then
	rm -f "$uncompressed_manpage"
fi
