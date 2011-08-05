#!/bin/sh
# Usage: Put the latest .deb files of the packages into their
# corresponding directory and run this script.

packages=`find -maxdepth 1 -type d | grep -v "^\.$" | cut -d/ -f2 | sort`

for package in $packages; do
	echo "Updating package $package"
	latest_deb=`ls $package/$package*.deb 2>/dev/null | tail -n1`
	if [ -z $latest_deb ]; then
		echo "Warning: Could not find .deb for package '$package'"
	else
		ar x $latest_deb data.tar.gz
		mkdir tmp
		tar xzf data.tar.gz --directory=tmp/
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
		rm -rf tmp/ data.tar.gz tmp.links
		git add $package
		changes=`git status | grep "Changes to be committed:"`
		if [ -n "$changes" ]; then
			version=`basename "$latest_deb" | cut -d_ -f2`
			git commit -m "Update $package $version manpages"
		fi
	fi
done
