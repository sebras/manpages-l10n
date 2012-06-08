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

mkdir -p downloads

while read package; do
	echo -n "Checking package $package ... "
	# Download HTML page and discover the correct link
	url=`wget --quiet -O - "http://packages.debian.org/sid/amd64/$package/download" |
	grep "http://ftp.de.debian.org/debian/pool/" |
	sed -e "s,.*\(http://ftp.de.debian.org/debian/pool/[^\"]*\).*,\1,"`
	deb_version=`basename $url`
	if [ -f "downloads/$deb_version" ]; then
		echo "current"
	else
		echo "downloading"
		wget --quiet --directory-prefix=downloads "$url"
		# Remove older Debian packages
		ls downloads/$package\_* | head --lines=-1 | xargs rm
	fi
done < packages.list
