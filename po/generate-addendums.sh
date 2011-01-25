for translation in `find -name *po | sort`; do
	# Use the header up until the first msgid
	# and remove the comment character
	translators=`sed '/msgid/q;s/^#\s\+//' "$translation" |
	# Throw away the common (non translator) lines
	grep -v "German translation of manpages" |
	grep -v "This file is distributed under the same license as the manpages-de package." |
	grep -v "Copyright © of this file:" |
	grep -v "msgid" |
	# Split lines to extract the name (and e-mail address)
	cut -f1 -d","`
	# Determine number of translators
	number_translators=`echo "$translators" | wc -l`
	
	# Output of common header
	echo "PO4A-HEADER:mode=after;position=^.TH;beginboundary=FakePo4aBoundary" > tmp.add
	echo >> tmp.add
	echo ".SH ÜBERSETZUNG" >> tmp.add
	echo "Die deutsche Übersetzung dieser Handbuchseite wurde von" >> tmp.add
	
	# Apply correct formatting, depending on the number of translators
	if [ $number_translators -eq 1 ]; then
		echo "$translators" >> tmp.add
	fi
	if [ $number_translators -eq 2 ]; then
		echo "$translators" | head -n1 >> tmp.add
		echo "und" >> tmp.add
		echo "$translators" | tail -n1 >> tmp.add
	fi
	if [ $number_translators -ge 3 ]; then
		echo "$translators" | head -n$(($number_translators - 2)) | perl -pe "s/$/,/" >> tmp.add
		echo "$translators" | tail -n2 | head -n1 >> tmp.add
		echo "und" >> tmp.add
		echo "$translators" | tail -n1 >> tmp.add
	fi
	
	# Output of common ending
	echo "erstellt." >> tmp.add
	mv tmp.add `dirname $translation`/`basename $translation .po`.add
done
