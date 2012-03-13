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

set -e

# Get all msgids with at least 2 occurences
msgcat --more-than=1 man?/*po > min-2-occurences.po
# Remove most comment lines, preserve "#, fuzzy"
sed -i -e "/^# /d;/^#\. /d" min-2-occurences.po
# Remove first (empty) msgid with all combined headers
sed -i -e "1,/^$/d" min-2-occurences.po
# Create a temporary header for the above .po file
cat > tmp.po <<END_OF_HEADER
msgid ""
msgstr ""
"Project-Id-Version: manpages-de\n"
"POT-Creation-Date: 2010-10-18 14:52+0200\n"
"PO-Revision-Date: 2010-10-18 14:52+0200\n"
"Last-Translator: Tobias Quathamer <toddy@debian.org>\n"
"Language-Team: German <debian-l10n-german@lists.debian.org>\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"

END_OF_HEADER
cat tmp.po min-2-occurences.po > tmp2.po
# In order to remove msgids which are already in the compendium,
# first create a .po file with all msgids ...
msgcat --use-first compendium.po tmp2.po > tmp.po
# ... and then filter out every msgid which is doubled.
msgcat --unique compendium.po tmp.po > tmp2.po
# Remove dates from compendium, as they are translated automatically
msggrep --msgid -v -E -e "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" tmp2.po > candidates.po
rm -f tmp.po tmp2.po min-2-occurences.po
