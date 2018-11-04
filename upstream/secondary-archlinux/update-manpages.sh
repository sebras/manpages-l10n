#!/bin/sh
#
# Copyright © 2018 Dr. Tobias Quathamer <toddy@debian.org>
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

mkdir downloads
mkdir man0 man1 man2 man3 man4 man5 man6 man7 man8

# Download packages
while read line; do
	repo=$(echo "$line" | cut -d" " -f1)
	package=$(echo "$line" | cut -d" " -f2)
	echo "Downloading package '$package' from '$repo'"
	# Download HTML page and discover the correct link
	url=$(wget --quiet -O - "https://mirror.netcologne.de/archlinux/$repo/os/x86_64/" |
	grep "\"$package-[0-9][^\"]*\.pkg\.tar\.xz[^.]" |
	sed -e "s,.*<a href=\"\($package-[^\"]*\).*,\1,")
	url="https://mirror.netcologne.de/archlinux/$repo/os/x86_64/$url"
	wget --quiet --directory-prefix=downloads "$url"
done < packages.txt

# Extract manpages
while read line; do
	repo=$(echo "$line" | cut -d" " -f1)
	package=$(echo "$line" | cut -d" " -f2)
	echo "Updating package '$package' from '$repo'"
	latest_pkg=$(ls downloads/$package-*.pkg.tar.xz 2>/dev/null | tail -n1)
	if [ -z $latest_pkg ]; then
		echo "Warning: Could not find .pkg.tar.xz for package '$package'"
	else
		mkdir -p tmp/$package
		tar xaf $latest_pkg --directory=tmp/$package
		for mandir in tmp/$package/usr/share/man/man*/; do
			section=$(echo $mandir | cut -d/ -f6)
			# Only copy directories with files
			files=$(ls $mandir)
			if [ -n "$files" ]; then
				mkdir -p tmp/$package/$section
				# Remove manpages which are links
				for manpage in $mandir/*; do
					existing=$(readlink $manpage)
					if [ -n "$existing" ]; then
						linked_section=$(basename $existing .gz | sed -e "s/.\+\.//")
						echo man$linked_section/$(basename $existing) $section/$(basename $manpage) >> tmp.links
						rm $manpage
					fi
				done
				cp $mandir/* tmp/$package/$section
				gzip -d tmp/$package/$section/*
				# Remove manpages which contain only .so links
				for manpage in tmp/$package/$section/*; do
					existing=$(grep "^\.so" $manpage | sed -e "s/^\.so //")
					if [ -n "$existing" ]; then
						echo $existing.gz $section/$(basename $manpage).gz >> tmp.links
						rm $manpage
					fi
				done
				# Copy remaining manpages
				cp tmp/$package/$section/* $section
			fi
		done
		if [ -e tmp.links ]; then
			cat tmp.links >> links.txt
		fi
		rm -rf tmp.links
	fi
done < packages.txt

rm -rf tmp downloads
