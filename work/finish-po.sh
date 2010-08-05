#!/bin/sh

set -e

if [ -z $1 ]; then \
  echo "Geben Sie die Handbuchseite an." ; \
  exit ; \
fi

program=`basename $1 | sed -e "s/\.[0-9]//"`
section=`basename $1 | sed -e "s/.\+\.//"`

mv $1.po ../po/man$section/
mv $1.add ../po/man$section/

# Remove source files.
rm -f $1 $program.$section.de.$section

git pull
git add ../po/man$section/$1.po
git add ../po/man$section/$1.add
git commit -m "Initial conversion of $1"

echo "Denken Sie daran, git push aufzurufen."
