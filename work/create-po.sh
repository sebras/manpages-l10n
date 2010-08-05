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
po4a-gettextize -f man -m $1 $translation -p $1.po

# Stop here if po4a fails
if [ $? -ne 0 ]; then \
  exit ; \
fi

# Correct header data to satisfy msg* tools
date=`date +"%Y-%m-%d %H:%M%z"`
sed -i -e "s/^\"Project-Id-Version: PACKAGE VERSION.*/\"Project-Id-Version: manpages-de\\\\n\"/" $1.po
sed -i -e "s/^\"POT-Creation-Date: .*/\"POT-Creation-Date: $date\\\\n\"/" $1.po
sed -i -e "s/^\"PO-Revision-Date: .*/\"PO-Revision-Date: $date\\\\n\"/" $1.po
sed -i -e "s/^\"Language-Team: LANGUAGE <LL@li.org>.*/\"Language-Team: German <debian-l10n-german@lists.debian.org>\\\\n\"/" $1.po
sed -i -e "s/^\"Content-Type: text\/plain; charset=CHARSET.*/\"Content-Type: text\/plain; charset=UTF-8\\\\n\"/" $1.po
sed -i -e "s/^\"Content-Transfer-Encoding: ENCODING.*/\"Content-Transfer-Encoding: 8bit\\\\n\"/" $1.po

# Create addendum to be added at the end of manpages
cat > $1.add <<END_ADDENDUM
PO4A-HEADER:mode=after;position=^.TH;beginboundary=FakePo4aBoundary

.SH ÜBERSETZUNG
Deutsche Übersetzung dieser Handbuchseite von
MEIN NAME.
END_ADDENDUM
