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

# Require one argument (the name of the new distribution)
distribution=$1
if [ -z "$distribution" ]; then
	echo "Please specify the name of the new distribution."
	exit 1
fi

# Safety net
if [ ! -d "upstream/secondary-$distribution" ]; then
	echo "The distribution '$distribution' does not exist."
	echo "Please start with the first part of this script."
	exit
fi

# Make sure that the update-manpages.sh script has been run
# Start with clean directories and no leftover links.txt
cd "upstream/secondary-$distribution"
rm -rf man* links.txt
./update-manpages.sh
# Sort the file links.txt
if [ -f links.txt ]; then
	LC_ALL=C sort links.txt > tmp.links
	mv tmp.links links.txt
fi
git add .
git commit -m "Add manpages for '$distribution'"
cd ../..


# Create the po directory
cd "po"
mkdir "secondary-$distribution"
cp -r primary/* secondary-$distribution
git add secondary-$distribution
git commit -m "Copy all translations from primary to secondary-$distribution"
cd ..

# Create the templates directory
cd "templates"
mkdir "secondary-$distribution"
./update-templates.sh
if [ ! -d "common-secondary" ]; then
	# Create a new secondary directory from primary
	mkdir "common-secondary"
	cp common-primary/* common-secondary
fi
./create-common-templates.sh
git add common-secondary/*
git commit -m "Add common templates for new distribution '$distribution'"
cd ..

# Create the common po directory
cd "po"
if [ ! -d "common-secondary" ]; then
	# Create a new secondary directory from primary
	mkdir "common-secondary"
	cp common-primary/* common-secondary
fi
compendium=$(mktemp)
msgcat secondary-$distribution/man*/*po > "$compendium"
for pofile in common-secondary/*po; do
	# Find the pot file by adding the letter 't'
	potfile="../templates/$pofile""t"
	msgmerge --previous --compendium "$compendium" "$pofile" "$potfile" > tmp.po
	# Remove obsolete strings
	msgattrib --force-po --no-obsolete tmp.po > "$pofile"
done
git add common-secondary
git commit -m "Fill up common translations from manpages"
rm -f "$compendium" tmp.po
cd ..
