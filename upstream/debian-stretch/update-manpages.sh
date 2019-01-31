#!/bin/sh
#
# Copyright © 2010-2017 Dr. Tobias Quathamer <toddy@debian.org>
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
mkdir man1 man2 man3 man4 man5 man6 man7 man8

# Download packages
while read package; do
	echo "Downloading package '$package'"
	# Download HTML page and discover the correct link
	# Prefer manpages from stretch-backports, then try stretch
	url=$(wget --quiet -O - "http://packages.debian.org/stretch-backports/amd64/$package/download" |
	grep "http://ftp.de.debian.org/debian/pool/" |
	sed -e "s,.*\(http://ftp.de.debian.org/debian/pool/[^\"]*\).*,\1,")
	if [ -z "$url" ]; then
		url=$(wget --quiet -O - "http://packages.debian.org/stretch/amd64/$package/download" |
		grep "http://ftp.de.debian.org/debian/pool/" |
		sed -e "s,.*\(http://ftp.de.debian.org/debian/pool/[^\"]*\).*,\1,")
	fi
	# If the URL is still not set, try security.d.o
	if [ -z "$url" ]; then
		url=$(wget --quiet -O - "http://packages.debian.org/stretch/amd64/$package/download" |
		grep "http://security.debian.org/debian-security/pool/" |
		sed -e "s,.*\(http://security.debian.org/debian-security/pool/[^\"]*\).*,\1,")
	fi
	wget --quiet --directory-prefix=downloads "$url"
done < packages.txt

# Extract manpages
while read package; do
	echo "Updating package '$package'"
	latest_deb=$(ls downloads/$package\_*.deb 2>/dev/null | tail -n1)
	if [ -z $latest_deb ]; then
		echo "Warning: Could not find .deb for package '$package'"
	else
		data_tar=$(ar t $latest_deb | grep data.tar)
		ar x $latest_deb $data_tar
		mkdir -p tmp/$package
		tar xaf $data_tar --directory=tmp/$package
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
		rm -rf $data_tar tmp.links
	fi
done < packages.txt

rm -rf tmp downloads
