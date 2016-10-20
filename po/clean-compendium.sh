#!/bin/sh
#
# Copyright © 2010-2012 Dr. Tobias Quathamer <toddy@debian.org>
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

set -e

# Get all msgids with at most 2 occurences (only in compendium or in one other file)
msgcat --less-than=3 man?/*po compendium.po > max-2-occurences.po
# Remove most comment lines, preserve "#, fuzzy"
sed -i -e "/^# /d;/^#\. /d" max-2-occurences.po
# Remove first (empty) msgid with all combined headers
sed -i -e "1,/^$/d" max-2-occurences.po
# Create a temporary header for the above .po file
cat > tmp.po <<END_OF_HEADER
msgid ""
msgstr ""
"Project-Id-Version: manpages-de\n"
"POT-Creation-Date: 2010-10-18 14:52+0200\n"
"PO-Revision-Date: 2010-10-18 14:52+0200\n"
"Last-Translator: Dr. Tobias Quathamer <toddy@debian.org>\n"
"Language-Team: German <debian-l10n-german@lists.debian.org>\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"

END_OF_HEADER
cat tmp.po max-2-occurences.po > tmp2.po
# Extract msgids which are only in the compendium, nowhere else ...
msgcat --more-than=1 compendium.po tmp2.po > tmp.po
# ... and then filter out every msgid which is doubled.
msgcat --unique --use-first compendium.po tmp.po > tmp2.po
mv tmp2.po compendium.po
rm -f tmp.po max-2-occurences.po
