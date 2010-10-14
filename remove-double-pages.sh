#!/bin/sh

find man? -type f -exec basename {} \; > tmp.old-pages
find generated -type f -exec basename {} \; > tmp.generated-pages

cat tmp.old-pages tmp.generated-pages > tmp.all-pages
sort tmp.all-pages | uniq -d > tmp.double-pages

while read line; do
	section=`echo $line | sed -e "s/.\+\.//"`
	rm man$section/$line;
done < tmp.double-pages

rm -f tmp.old-pages tmp.generated-pages tmp.all-pages tmp.double-pages
