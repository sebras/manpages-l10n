#!/bin/sh
#
# Copyright © 2017 Dr. Tobias Quathamer <toddy@debian.org>
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

# Determine directory names.
# The path "../upstream" points here. This way, it's possible
# to filter out the current directory named ".".
directories=`find ../upstream -maxdepth 1 -type d | cut -d/ -f3- | LC_ALL=C sort`

for directory in $directories; do
	echo "Processing directory '$directory'"
	cd $directory

	# Start with clean directories and no leftover links.txt
	rm -rf man* links.txt

	# Call the script inside the directory for handling
	# the needed instructions for the given distribution.
	./update-manpages.sh

	# Sort the file links.txt
	if [ -f links.txt ]; then
		LC_ALL=C sort links.txt > tmp.links
		mv tmp.links links.txt
	fi

	cd ..
done
