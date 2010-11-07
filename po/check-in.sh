#!/bin/sh
set -e

# Make sure there is an argument
if [ -z "$1" ]; then \
	echo "Geben Sie die .po-Datei an." ; \
	exit ; \
fi

pofile="$1"
# If shell completion is used, there might be the extension "po" missing.
if [ ! -f "$pofile" ]; then \
	pofile="$pofile"po
fi

program=`basename "$pofile" .po | sed -e "s/\.[0-9]//"`
section=`basename "$pofile" .po | sed -e "s/.\+\.//"`

# Get translator
translator=`grep ^\"Last-Translator: "$program.$section.po" |
	sed -e "s/.\+Last-Translator:\s\+\(.\+\)\s\+\(<[^>]\+>\).\+/\1 \2/"`

# Get statistics
stats=`LC_ALL=C msgfmt -cv -o /dev/null "$pofile" 2>&1 |
	sed -e "s/\s*translated messages\?/t/;
		s/\s*fuzzy translations\?/f/;
		s/\s*untranslated messages\?/u/;
		s/\.//"`

# Reformat file to use the correct width
tmpname=`mktemp`
msgcat "$pofile" > "$tmpname"
mv "$tmpname" "$pofile"

git add "$pofile" "$program.$section.add"
git commit --author "$translator" -m "$program.$section: $stats"
