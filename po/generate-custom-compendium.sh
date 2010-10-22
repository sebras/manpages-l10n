#!/bin/sh

original="$1"
if [ ! -e "$original" ]; then \
  echo "Die Datei $original wurde nicht gefunden." ; \
  exit ; \
fi

program=`basename "$original" | sed -e "s/\.[0-9]$//"`
section=`basename "$original" | sed -e "s/.\+\.\([0-9]\)$/\1/"`

# Determine if there's a recognizable date in the original file
perl -ne "if (/^\.TH.*(([1-2][0-9]{3})-([0-1][0-9])-([0-3][0-9])).*/) {
	print \"\\n\";
	print \"msgid \\\"\$1\\\"\\n\";
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
	printf('%d', \$4);
	print '. ' . \$month[\$3] . ' ' . \$2;
	print '\"';
	print \"\\n\";
}" "$original" > tmp.po

# Set up strings for coreutils
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
"E<lt>http://translationproject.org/team/de.htmlE<gt>"

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

msgid "should give you access to the complete manual."
msgstr "auf das vollständige Handbuch zugreifen."
END_COMPENDIUM
# Replace PROGRAM with current program
upcase=`echo "$program" | tr [:lower:] [:upper:]`
sed -i -e "s/PROGRAM/$program/g;s/UPCASE/$upcase/g" tmp.po

# If the header.po exists, reuse it (useful for generating a template header)
# Otherwise, extract the existing header
if [ ! -e header.po ]; then
	# Extract header entry for custom compendium (first line until first blank line)
	sed -n "1,/^$/p" "man$section/$program.$section.po" > header.po
fi
# Create a custom compendium with the header from the translation
msgcat --use-first header.po ../work/compendium.po > tmp-compendium.po
cat tmp-compendium.po tmp.po > custom.po
rm tmp-compendium.po header.po tmp.po
