#!/bin/sh
#
# Copyright © 2017-2019 Dr. Tobias Quathamer <toddy@debian.org>
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

# Find all translation mandirs
mandirs=$(find ../po -maxdepth 1 -type d -name "man*"  | cut -d/ -f3- | LC_ALL=C sort)

# Save old templates for comparing the file contents
mkdir backup
for i in man*/*; do
  mv $i backup
done

# Start with clean directories
rm -rf man*

tmp1=$(mktemp)
tmp2=$(mktemp)

for mandir in $mandirs; do
  echo Section $mandir
  mkdir "$mandir"

  # Find all translations of the section
  translations=$(find "../po/$mandir" -type f | cut -d/ -f3- | LC_ALL=C sort)
  for translation in $translations; do
    manpage=$(basename $translation .po)

    # Create pot file
    echo "Generating pot file for manpage '$manpage'"

    # Get the current time to ensure that all potfiles
    # have the exact same date and time of creation in the header.
    datetime=$(date --iso-8601=minutes | sed -e "s/T/ /")

    # Find all upstream manpages with a matching name
    potfiles=""
    upstream_manpages=$(find ../upstream/*/ -type f -name "$manpage" | LC_ALL=C sort)
    for upstream_manpage in $upstream_manpages; do
      # Create a template for each distribution
      distribution=$(echo $upstream_manpage | cut -d/ -f3)

      potfile=$(mktemp --tmpdir "$distribution.$manpage.XXX.pot")
      potfiles="$potfiles $potfile"
      ./generate-template.sh $distribution $manpage > $potfile

      # Ensure the same timestamp
      if [ -f "$potfile" ]; then
        sed -i -e "s/^\"POT-Creation-Date: .*$/\"POT-Creation-Date: $datetime\\\\n\"/" "$potfile"
      fi
    done

    # Merge all pot files into one
    msgcat -o "$mandir/$manpage.pot" $potfiles

    # Remove random characters from multiple file information
    # and reformat the comment into something more readable, e.g.:
    # "#. #-#-#-#-#  archlinux.fclose.3.0bX.pot (PACKAGE VERSION)  #-#-#-#-#"
    sed -i -e "s/^#\. #-#-#-#-# \([^.]*\)\.\(.\+\)\.[A-Za-z0-9]\{3\}\.pot/#. #-#-#-#-# \1: \2.pot/" "$mandir/$manpage.pot"

    # Determine if the only change is the "POT-Creation-Date:" header
    # If so, copy back the backup to revert that change
    if [ -f "$mandir/$manpage.pot" -a -f "backup/$manpage.pot" ]; then
      sed -f remove-potcdate.sed < "backup/$manpage.pot" > "$tmp1"
      sed -f remove-potcdate.sed < "$mandir/$manpage.pot" > "$tmp2"
      if cmp "$tmp1" "$tmp2" >/dev/null 2>&1; then
        mv "backup/$manpage.pot" "$mandir/$manpage.pot"
      fi
    fi
  done
done

rm -rf backup $tmp1 $tmp2 $potfiles
