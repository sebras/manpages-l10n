#!/bin/sh

set -e

# Get all msgids with at most 2 occurences (only in compendium or in one other file)
msgcat --less-than=3 ../po/man?/*po compendium.po > max-2-occurences.po
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
"Last-Translator: Tobias Quathamer <toddy@debian.org>\n"
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
