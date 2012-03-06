#!/bin/sh

# Require one argument
if [ -z "$1" ]; then
	echo "Specify the manpage."
	exit 1
fi

# If only the name without path has been provided,
# try to find the original manpage
if [ ! -f "$1" ]; then
	original=`find ../english/ -type f -name "$1"`
	if [ -z "$original" ]; then
		echo "The file $1 could not be found."
		exit 1
	fi
else
	original="$1"
fi

name=`basename "$original" | sed -e "s/\.[0-9]//"`
section=`basename "$original" | sed -e "s/.\+\.//"`
output=`mktemp`

# Create .po file with po4a
po4a-gettextize -f man \
 --option groff_code=verbatim \
 --option generated \
 --option untranslated="a.RE,\|" \
 --option unknown_macros=untranslated \
 --master "$original" \
 --po "$output"

# Stop here if po4a fails
if [ $? -ne 0 ]; then
	echo "Fehler bei der Ausführung von po4a."
	rm "$output"
	exit 1
fi

# Remove location information
sed -i -e "/^#: /d" "$output"

# Specify encoding
sed -i -e "s/^\"Content-Type: text\/plain; charset=CHARSET\\\\n\"$/\"Content-Type: text\/plain; charset=UTF-8\\\\n\"/" "$output"

mv "$output" "man$section/$name.$section.po"
./update-po.sh "man$section/$name.$section.po" CREATE_HEADER
echo "Created man$section/$name.$section.po"
