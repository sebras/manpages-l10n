#!/bin/sh
#
# Copyright © 2010-2019 Dr. Tobias Quathamer <toddy@debian.org>
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

# Start with clean directories and no leftover links.txt
rm -rf man* links.txt untranslated.txt

# Process packages
while read package; do
	mkdir tmp

	# Download HTML page and discover the correct link
	echo "Downloading and updating package '$package'"
	url=$(wget --quiet -O - "https://packages.debian.org/sid/amd64/$package/download" |
	grep "http://ftp.de.debian.org/debian/pool/" |
	sed -e "s,.*\(http://ftp.de.debian.org/debian/pool/[^\"]*\).*,\1,")
	wget --quiet --directory-prefix=tmp/downloads "$url"


	# Update the manpages from the package
	latest_deb=$(ls tmp/downloads/$package\_*.deb)
	if [ -z $latest_deb ]; then
		echo "Warning: Could not find .deb for package '$package'"
	else
		data_tar=$(ar t $latest_deb | grep data.tar)
		ar x $latest_deb $data_tar
		tar xaf $data_tar --directory=tmp 2>/dev/null
		../move-manpages.sh "$package"
	fi
	# Finally, remove the tarball, so that the regexp
	# matching does not match the wrong tarball.
	# See pacman and pacman-contrib for an example.
	rm -rf tmp data.tar.*
done < packages.txt
