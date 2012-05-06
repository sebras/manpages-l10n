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

set -e

# Check if there is a .po file without the corresponding
# upstream manpage, e.g. when a package has been removed.

translations=`find man? -name "*.po" | sort`
for translation in $translations; do
	manpage=`basename "$translation" .po`
	original=`find ../english/ -name "$manpage"`
	if [ -z "$original" ]; then
		echo "No upstream found for" $translation
	fi
done
