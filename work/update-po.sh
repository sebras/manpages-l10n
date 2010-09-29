#!/bin/sh

if [ -z $1 ]; then \
  echo "Geben Sie die Handbuchseite an." ; \
  exit ; \
fi

program=`basename $1 | sed -e "s/\.[0-9]//"`
section=`basename $1 | sed -e "s/.\+\.//"`

original=`find ../english/ -type f -name "$1"`
if [ -z $original ]; then \
  echo "Die Handbuchseite wurde nicht gefunden." ; \
  exit 1 ; \
fi

# Determine if there's a recognizable date in the po file
perl -ne "if (/msgid \"([1-2][0-9]{3})-([0-1][0-9])-([0-3][0-9])\"/) {
	print \"\\n\";
	print;
	print \"msgstr \\\"\";
	\$month['01'] = 'Januar';
	\$month['02'] = 'Februar';
	\$month['03'] = 'März';
	\$month['04'] = 'April';
	\$month['05'] = 'Mai';
	\$month['06'] = 'Juni';
	\$month['07'] = 'Juli';
	\$month['08'] = 'August';
	\$month['09'] = 'September';
	\$month['10'] = 'Oktober';
	\$month['11'] = 'November';
	\$month['12'] = 'Dezember';
	printf('%d', \$3);
	print '. ' . \$month[\$2] . ' ' . \$1;
	print '\"';
	print \"\\n\";
}" $1.po > tmp.po

# Create a custom compendium for this manpage
cat >> tmp.po <<END_COMPENDIUM

msgid "UPCASE"
msgstr "UPCASE"

msgid "Report PROGRAM bugs to bug-coreutils@gnu.org"
msgstr ""
"Berichten Sie Fehler in PROGRAM (auf Englisch) an bug-coreutils@gnu.org"

msgid ""
"Report PROGRAM translation bugs to E<lt>http://translationproject.org/team/E<gt>"
msgstr ""
"Berichten Sie Fehler in der Übersetzung von PROGRAM an "
"E<lt>http://translationproject.org/team/E<gt>"

msgid ""
"The full documentation for B<PROGRAM> is maintained as a Texinfo "
"manual.  If the B<info> and B<PROGRAM> programs are properly installed "
"at your site, the command"
msgstr ""
"Die vollständige Dokumentation für B<PROGRAM> wird als Texinfo-Handbuch "
"gepflegt. Wenn die Programme B<info> und B<PROGRAM> auf Ihrem Rechner "
"ordnungsgemäß installiert sind, können Sie mit dem Befehl"

msgid "B<info coreutils \\\\(aqPROGRAM invocation\\\\(aq>"
msgstr "B<info coreutils \\\\(aqPROGRAM invocation\\\\(aq>"
END_COMPENDIUM
# Replace PROGRAM with current program
upcase=`echo $program | tr [:lower:] [:upper:]`
sed -i -e "s/PROGRAM/"$program"/" tmp.po
sed -i -e "s/UPCASE/"$upcase"/" tmp.po

# Create uniform header
echo "# German translation of manpages" > header.po
echo "# This file is distributed under the same license as the manpages-de package." >> header.po
# Extract header entry for custom compendium (msgid line until first blank line)
sed -n "1,/^$/p" $1.po | grep -v "^#" >> header.po
# Create a custom compendium with the header from the translation
msgcat --use-first header.po compendium.po > tmp-compendium.po
cat tmp-compendium.po tmp.po > custom.po

# Update .po file from master file
po4a-updatepo -f man --option groff_code=verbatim \
	-m $original -M ISO-8859-1 \
	--msgmerge-opt "--backup=none --no-location --compendium custom.po --previous" \
	--po $1.po
# Remove obsolete strings
msgattrib --no-obsolete $1.po > tmp.po
# Prefer the translations from the compendium
msgmerge --compendium custom.po --no-fuzzy-matching /dev/null tmp.po > result.po
mv result.po $1.po

# Correct header data to satisfy msg* tools
date=`date +"%Y-%m-%d %H:%M%z"`
sed -i -e "s/^\"POT-Creation-Date: .*/\"POT-Creation-Date: $date\\\\n\"/" $1.po
sed -i -e "s/^\"PO-Revision-Date: .*/\"PO-Revision-Date: $date\\\\n\"/" $1.po
sed -i -e "s/Last-Translator: .*/Last-Translator: MEIN NAME <EMAIL>\\\\n\"/" $1.po
# Unfuzzy header entry
sed -i -e "1,3 { /^#, fuzzy/d }" $1.po

# Cleanup
rm -f header.po tmp.po tmp-compendium.po custom.po gettextization.failed.po
