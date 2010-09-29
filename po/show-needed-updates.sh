count=0
for translation in `find ../po -name "*.po" | sort`; do
	stats=`msgfmt -cv -o /dev/null $translation 2>&1`
	fuzzy_or_untranslated=`echo $stats | grep "[0-9]\+[^0-9]\+[0-9]\+"`
	if [ -n "$fuzzy_or_untranslated" ]; then
		echo `basename $translation`:
		echo $stats
		echo
		count=$(($count+1))
	fi
done
if [ $count -eq 0 ]; then
	echo "Alle Dateien sind vollständig übersetzt."
else
	if [ $count -eq 1 ]; then
		echo "1 Datei ist nicht vollständig übersetzt."
	else
		echo "$count Dateien sind nicht vollständig übersetzt."
	fi
fi
