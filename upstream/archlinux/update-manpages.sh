#!/bin/sh
#
# Copyright © 2018-2019 Dr. Tobias Quathamer <toddy@debian.org>
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
rm -rf man* links.txt

mkdir man0p man1 man1p man2 man3 man3p man4 man5 man6 man7 man8

# Process packages
while read line; do
	mkdir tmp

	repo=$(echo "$line" | cut -d" " -f1)
	package=$(echo "$line" | cut -d" " -f2)

	# Download HTML page and discover the correct link
	echo "Downloading and updating package '$package' from '$repo'"
	url=$(wget --quiet -O - "https://mirror.netcologne.de/archlinux/$repo/os/x86_64/" |
	grep "\"$package-[0-9][^\"]*\.pkg\.tar\.zst[^.]" |
	sed -e "s,.*<a href=\"\($package-[^\"]*\).*,\1,")
	url="https://mirror.netcologne.de/archlinux/$repo/os/x86_64/$url"
	wget --quiet --directory-prefix=tmp/downloads "$url"

	# Update the manpages from the package
	latest_pkg=$(ls tmp/downloads/$package-*.pkg.tar.zst)
	if [ -z $latest_pkg ]; then
		echo "Warning: Could not find .pkg.tar.zst for package '$package'"
	else
		tar xaf $latest_pkg --directory=tmp 2>/dev/null
		./move-manpages.sh
	fi
	# Finally, remove the tarball, so that the regexp
	# matching does not match the wrong tarball.
	# See pacman and pacman-contrib for an example.
	rm -rf tmp
done < packages.txt

if [ -f links.txt ]; then
	LC_ALL=C sort links.txt > tmp.links
	mv tmp.links links.txt
fi
