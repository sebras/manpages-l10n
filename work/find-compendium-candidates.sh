#!/bin/sh

set -e

# Get all msgids with at least 3 occurences
msgcat --more-than=2 ../po/man?/*po > min-3-occurences.po
# Remove most comment lines, preserve "#, fuzzy"
sed -i -e "/^# /d;/^#\. /d" min-3-occurences.po
# Remove first (empty) msgid with all combined headers
sed -i -e "1,/^$/d" min-3-occurences.po
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
cat tmp.po min-3-occurences.po > tmp2.po
# In order to remove msgids which are already in the compendium,
# first create a .po file with all msgids ...
msgcat --use-first compendium.po tmp2.po > tmp.po
# ... and then filter out every msgid which is doubled.
msgcat --unique compendium.po tmp.po > tmp2.po
# Remove dates from compendium, as they are translated automatically
msggrep --msgid -v -E -e "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" tmp2.po > candidates.po
rm -f tmp.po tmp2.po min-3-occurences.po
