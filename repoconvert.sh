#!/bin/sh
#
# Copyright © 2019 Dr. Tobias Quathamer <toddy@debian.org>
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


# This script should convert the git repository to the new
# layout and workflow.

### UPSTREAM ############################################################

cd upstream
git mv primary debian-unstable
git mv secondary-debian-stretch debian-stretch
git mv secondary-archlinux archlinux
git commit -m "Rename upstream directories" .
cd ..


### TRANSLATIONS ########################################################

cd po
git mv primary/* .
git add man?
git commit -m "Move primary translations into man[1-8] directories"
cd ..

sed -i -e "s,^po/\[ps\].*$,po/man*/*\\\\.[0-9].?," .gitignore
git commit -m "Update generated manpages ignore rule in .gitignore file" .gitignore


### TEMPLATES ###########################################################

cd templates
rm -rf man[0-8]/
for i in $(seq 1 8); do mkdir man$i; done
./update-all-templates.sh
git add man?
git commit -m "Create templates for all translated manpages"

git mv common-primary common
git commit -m "Rename common-primary templates directory" .
git rm -rf common-secondary
git commit -m "Remove common-secondary templates directory" .
cd ..


### TRANSLATIONS ########################################################

cd po

# Update .po files from new templates
# Find all upstream manpages with a matching name
pofiles=$(find man? -type f | LC_ALL=C sort)
removals=""
for i in $pofiles; do
	otherpo=""
	if [ -f secondary-archlinux/$i ]; then
		otherpo="secondary-archlinux/$i"
	fi
	if [ -f secondary-debian-stretch/$i ]; then
		otherpo="$otherpo secondary-debian-stretch/$i"
	fi
	removals="$removals $otherpo"
	mergedpo=$(mktemp)
	msgcat $otherpo > $mergedpo
	# Update primary translation
	echo $i
	msgmerge -U --compendium=$mergedpo $i ../templates/$i"t"
	rm $mergedpo
	# Remove backup
	rm -f $i"~"
done
git add man?
git commit -m "Update translations from secondary directories"
git rm $removals
git add secondary*
git commit -m "Remove merged translations from secondary directories"

cd secondary-archlinux
pofiles=$(find man? -type f | LC_ALL=C sort)
for i in $pofiles; do
	git mv $i ../$i
done
cd ..
cd secondary-debian-stretch
pofiles=$(find man? -type f | LC_ALL=C sort)
for i in $pofiles; do
	git mv $i ../$i
done
cd ..
git commit -m "Move remaining translations into man[1-8] directories"

cd ..


### TEMPLATES ###########################################################

cd templates
./update-all-templates.sh
git add man?
git commit -m "Create templates for remaining translations"
./create-common-templates.sh
git commit -m "Update common templates" common
cd ..

sed -i -e "/^templates/d" .gitignore
git commit -m "Remove templates directories from .gitignore file" .gitignore


### TRANSLATIONS ########################################################

cd po

pofiles=$(find common-*/ -type f | LC_ALL=C sort)
compendium=$(mktemp "compendium.XXX.po")
msgcat $pofiles > $compendium

git mv common-primary common
git commit -m "Rename common-primary translation directory" .
git rm -rf common-secondary
git commit -m "Remove common-secondary translation directory" .

pofiles=$(find common/ -type f | LC_ALL=C sort)
for i in $pofiles; do
	msgmerge -U --compendium=$compendium $i ../templates/$i"t"
	rm -f $i"~"
done

git add common
git commit -m "Update common translations from secondary directories"


### COMPENDIUM UPDATE ###################################################

# Merge all translations into one file

pofiles=$(find man*/ -type f | LC_ALL=C sort)
msgcat $pofiles | msgattrib --translated --no-fuzzy --no-obsolete > $compendium

# Update common files from those translations
pofiles=$(find common/ -type f | LC_ALL=C sort)
for i in $pofiles; do
	msgmerge -U --compendium=$compendium $i ../templates/$i"t"
	rm -f $i"~"
done
git add common
git commit -m "Update common translations from existing translations"

./update-translations.sh
git add man*
git commit -m "Update translations from compendium"

rm $compendium
cd ..
