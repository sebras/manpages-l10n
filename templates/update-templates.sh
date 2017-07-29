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

# Find all upstreams
upstreams=$(find ../upstream -maxdepth 1 -type d | cut -d/ -f3- | LC_ALL=C sort)

# Create pot files for all upstreams
for upstream in $upstreams; do
  echo "Generating pot files for upstream '$upstream'"

  # Start with clean directories
  rm -rf $upstream

  # Find all manpage sections
  mandirs=$(find "../upstream/$upstream" -maxdepth 1 -type d | cut -d/ -f4- | LC_ALL=C sort)
  for mandir in $mandirs; do
    echo Section $mandir

    mkdir -p "$upstream/$mandir"

    # Find all manpages of the upstream
    manpage_paths=$(find "../upstream/$upstream/$mandir" -type f | LC_ALL=C sort)
    for manpage_path in $manpage_paths; do
      # Determine manpage name
      manpage_name=$(basename "$manpage_path")

      # Check if there is a translation
      translation="../po/$upstream/$mandir/$manpage_name.po"
      if [ ! -f "$translation" ]; then
        continue
      fi

      # Determine if an encoding is specified,
      # otherwise fall back to ISO-8859-1
      coding=$(grep "\-\*\- coding:" "$manpage_path" | sed -e "s/.*coding:\s\+\([^ ]\+\).*/\1/")
      if [ -z "$coding" ]; then
        coding="ISO-8859-1"
      fi

      # Create pot with po4a
      po4a-gettextize -f man \
       --option groff_code=verbatim \
       --option generated \
       --option untranslated="a.RE,\|" \
       --option unknown_macros=untranslated \
       --master "$manpage_path" -M "$coding" \
       --po "$upstream/$mandir/$manpage_name.pot"

      if [ -f "$upstream/$mandir/$manpage_name.pot" ]; then
        # Remove location information
        sed -i -e "/^#: /d" "$upstream/$mandir/$manpage_name.pot"
        # Ensure the correct encoding is set
        sed -i -e "s/^\"Content-Type: text\/plain; charset=CHARSET\\\\n\"$/\"Content-Type: text\/plain; charset=UTF-8\\\\n\"/" \
          "$upstream/$mandir/$manpage_name.pot"
      fi
    done
  done
  echo Done.
done
