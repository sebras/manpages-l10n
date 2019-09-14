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

# Get the current package, so that a list of untranslated
# files can be created.
package="$1"

for mandir in tmp/usr/share/man/man*; do
  section=$(echo $mandir | cut -d/ -f5)
  mkdir -p $section
  # Only copy directories with files
  files=$(ls $mandir)
  if [ -n "$files" ]; then
    # Remove manpages which are links, add them to links.txt
    for manpage in $mandir/*; do
      existing=$(readlink $manpage)
      if [ -n "$existing" ]; then
        # Get the filenames of manpage and link
        ex_filename=$(basename $existing)
        mp_filename=$(basename $manpage)
        # Get the manpage section of the link
        ex_section=$(basename $(dirname $existing))
        # If the link is in the same directory, there's no dirname.
        if [ "$ex_section" = "." ]; then
          ex_section=$(basename $mandir)
        fi
        # Strip various compression extensions (.gz or similar)
        ex_filename=${ex_filename%.gz}
        ex_filename=${ex_filename%.bz2}
        ex_filename=${ex_filename%.xz}
        mp_filename=${mp_filename%.gz}
        mp_filename=${mp_filename%.bz2}
        mp_filename=${mp_filename%.xz}
        echo $ex_section/$ex_filename $section/$mp_filename >> links.txt
        # Remove the link, as it cannot be translated
        rm $manpage
      fi
    done
    # See if there are regular files left
    files=$(ls $mandir)
    if [ -n "$files" ]; then
      mkdir tmp/$section
      # Copy remaining manpages
      cp $mandir/* tmp/$section
      # Decompress all manpages, using various decompressors
      extension=$(echo "$manpage" | sed -e "s/.*\.//")
      for manpage in tmp/$section/*; do
        if [ "$extension" = "gz" ]; then
          gzip -d $manpage
        elif [ "$extension" = "bz2" ]; then
          bzip2 -d $manpage
        elif [ "$extension" = "xz" ]; then
          xz -d $manpage
        fi
      done
      # Remove manpages which contain only .so links
      for manpage in tmp/$section/*; do
        existing=$(grep "^\.so" $manpage | sed -e "s/^\.so.//")
        if [ -n "$existing" ]; then
          ex_filename=$(basename $existing)
          # Try to get the mansection from the linked filename
          ex_section=$(basename $(dirname $existing))
          if [ "$ex_section" = "." ]; then
            ex_section=$section
          fi
          echo $ex_section/$ex_filename $section/$(basename $manpage) >> links.txt
          rm $manpage
        fi
      done
      # The remaining manpages should be scanned for untranslated files
      for manpage in tmp/$section/*; do
        translation="../../po/$section/"$(basename "$manpage")".po"
        if [ ! -f $translation ]; then
          echo "$package: $section/"$(basename "$manpage") >> untranslated.txt
          # Remove untranslated manpages to save space
          rm $manpage
        fi
      done
      # Copy remaining manpages, if there are any in the current directory
      files=$(ls tmp/$section)
      if [ -n "$files" ]; then
        cp tmp/$section/* $section
      fi
    fi
  fi
done

# Make the sorting order of generated files reproducible
temp=$(mktemp)
if [ -f links.txt ]; then
	LC_ALL=C sort links.txt > $temp
	mv $temp links.txt
fi

if [ -f untranslated.txt ]; then
	LC_ALL=C sort untranslated.txt > $temp
	mv $temp untranslated.txt
fi
rm -f $temp

# Special case for init.8, because the manpage contains
# a syntax error, so that the manpage cannot be translated
# with po4a. The bug has been reported upstream.
# https://savannah.nongnu.org/bugs/?55678
if [ -f man8/init.8 ]; then
  sed -i -e "s|\\\fB/run/initctl\\\f\\\P, closed. This may be used to make sure init is not|\\\fB/run/initctl\\\fP, closed. This may be used to make sure init is not|" man8/init.8
fi

# Another special case for man.7, which uses \c and
# is therefore not translatable by po4a.
# Reformat the part to display equally in the man browser.
# Line 272 and 273:
# .B \&.UE \c
# .RI [ trailer ]
# Reformat to: \fB\&.UE\fP [ \fItrailer\fP ]
if [ -f man7/man.7 ]; then
  sed -i -e "/^\.B \\\&\.UE \\\c/{N; s/.*/\\\fB\\\\\&.UE\\\fP [ \\\fItrailer\\\fP ]/}" man7/man.7
fi
