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
  exit ; \
fi
cp $original .

translation=`find ../man?/ -type f -name "$1"`
if [ -z $translation ]; then \
  echo "Es gibt leider keine deutsche Übersetzung." ; \
else \
  cp $translation $program.$section.de.$section ; \
fi

echo "Sie können jetzt ./create-po.sh $1 aufrufen."
