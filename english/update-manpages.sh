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
#
# Usage: Put the latest .deb files of the packages into their
# corresponding directory and run this script.

packages=`find -maxdepth 1 -type d | grep -v "^\.$" | cut -d/ -f2 | sort`

for package in $packages; do
	echo "Updating package $package"
	latest_deb=`ls $package/$package*.deb 2>/dev/null | tail -n1`
	if [ -z $latest_deb ]; then
		echo "Warning: Could not find .deb for package '$package'"
	else
		ar x $latest_deb data.tar.gz data.tar.bz2 2>/dev/null
		mkdir tmp
		if [ -e "data.tar.gz" ]; then
			tar xzf data.tar.gz --directory=tmp/
		else
			tar xjf data.tar.bz2 --directory=tmp/
		fi
		rm -rf $package/man?
		git rm --quiet -r $package
		for mandir in tmp/usr/share/man/man?/; do
			section=`echo $mandir | cut -d/ -f5`
			# Only copy directories with files
			files=`ls $mandir`
			if [ -n "$files" ]; then
				mkdir $package/$section
				# Remove manpages which are links
				for manpage in $mandir/*; do
					existing=`readlink $manpage`
					if [ -n "$existing" ]; then
						linked_section=`basename $existing .gz | sed -e "s/.\+\.//"`
						echo man$linked_section/`basename $existing` $section/`basename $manpage` >> tmp.links
						rm $manpage
					fi
				done
				cp $mandir/* $package/$section
				gzip -d $package/$section/*
				# Remove manpages which contain only .so links
				for manpage in $package/$section/*; do
					existing=`grep "^\.so" $manpage | sed -e "s/^\.so //"`
					if [ -n "$existing" ]; then
						echo $existing.gz $section/`basename $manpage`.gz >> tmp.links
						rm $manpage
					fi
				done
			fi
		done
		if [ -e tmp.links ]; then
			LC_ALL=C sort tmp.links > $package/$package.links
		else
			rm -f $package/$package.links
		fi
		rm -rf tmp/ data.tar.* tmp.links
		git add $package
		changes=`git status | grep "Changes to be committed:"`
		if [ -n "$changes" ]; then
			version=`basename "$latest_deb" | cut -d_ -f2`
			git commit -m "Update $package $version manpages"
		fi
	fi
done
