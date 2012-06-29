#!/bin/sh

# Get the head of the file until first msgid line
# and filter out all comment lines without year information
for i in `find man? -name "*.po" | sort`; do
	sed -n "1,/^msgid/p" "$i" |
	grep -v "^# German translation of manpages" |
	grep -v "^# This file is distributed under the same license as the manpages-de package." |
	grep -v "^# Copyright © of this file:" |
	grep -v "^#\s*$" > tmp-header.po
	sed -e "1,/^msgid/d" "$i" > tmp-tail.po
	echo "# German translation of manpages" > tmp-result.po
	echo "# This file is distributed under the same license as the manpages-de package." >> tmp-result.po
	echo "# Copyright © of this file:" >> tmp-result.po
	cat tmp-result.po tmp-header.po tmp-tail.po > "$i"
	# Now remove location information, which is not needed in our case
	sed -i -e "/^#: /d" "$i"
	# Reformat manpage to wrap lines
	msgcat "$i" > tmp-result.po
	mv tmp-result.po "$i"
done
rm -f tmp-result.po tmp-header.po tmp-tail.po
