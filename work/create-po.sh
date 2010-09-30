#!/bin/sh

if [ -z $1 ]; then \
  echo "Geben Sie die Handbuchseite an." ; \
  exit ; \
fi

program=`basename $1 | sed -e "s/\.[0-9]//"`
section=`basename $1 | sed -e "s/.\+\.//"`

translation=`find -name $program.$section.de.$section`
if [ -z $translation ]; then \
  echo "Es gibt leider keine deutsche Übersetzung." ; \
else \
  translation="-l $translation -L UTF-8" ; \
fi

# Generate with po4a
po4a-gettextize -f man --option groff_code=verbatim -m $1 $translation -p $program.$section.po

# Stop here if po4a fails
if [ $? -ne 0 ]; then \
  exit 1; \
fi

# Remove location information
sed -i -e "/^#: /d" $program.$section.po

# Create addendum to be added at the end of manpages
cat > $program.$section.add <<END_ADDENDUM
PO4A-HEADER:mode=after;position=^.TH;beginboundary=FakePo4aBoundary

.SH ÜBERSETZUNG
Die deutsche Übersetzung dieser Handbuchseite wurde von
MEIN NAME <EMAIL>
erstellt.
END_ADDENDUM
