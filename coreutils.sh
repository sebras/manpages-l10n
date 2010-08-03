#!/bin/sh

# coreutils are Priority: required and Essential: yes,
# so they are already installed. However, we need the
# german locale for help2man to work.
apt-get install -y locales help2man
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

# Get the list of manpages
MANPAGES=`dpkg -L coreutils | grep "/usr/share/man/.*gz"`

# Get the date and source of the original manpages
TH_LINE=`zcat /usr/share/man/man1/arch.1.gz | grep "^\.TH"`
DATE=`echo $TH_LINE | cut -d" " -f4,5 | sed -e "s/\"//g"`
MONTH=`echo $DATE | cut -d" " -f1`
YEAR=`echo $DATE | cut -d" " -f2`
SOURCE=`echo $TH_LINE | cut -d" " -f6-8 | sed -e "s/\"//g"`

# Translate the month name
case $MONTH in
	January)
		TRANSLATION="Januar"
		;;
	February)
		TRANSLATION="Februar"
		;;
	March)
		TRANSLATION="März"
		;;
	April)
		TRANSLATION="April"
		;;
	May)
		TRANSLATION="Mai"
		;;
	June)
		TRANSLATION="Juni"
		;;
	July)
		TRANSLATION="Juli"
		;;
	August)
		TRANSLATION="August"
		;;
	September)
		TRANSLATION="September"
		;;
	October)
		TRANSLATION="Oktober"
		;;
	November)
		TRANSLATION="November"
		;;
	December)
		TRANSLATION="Dezember"
		;;
	*)
		echo "Error: Unknown month name: $MONTH"
		exit 1
		;;
esac

# Clean up
rm -rf coreutils.manpages coreutils.links

# Extract the symbolic links
for MANPAGE in $MANPAGES ; do \
	LINK=`readlink $MANPAGE` ; \
	if [ -z $LINK ] ; then \
		echo `basename $MANPAGE .gz` >> coreutils.manpages ; \
	else \
		# Save this link as SOURCE, DESTINATION
		destination=`basename $MANPAGE .gz`
		section=`echo $destination | sed -e "s/.\+\.//"` ; \
		echo man$section/$LINK man$section/$destination.gz >> coreutils.tmp.links ; \
	fi ; \
done
# Sort links file
LC_ALL=C sort coreutils.tmp.links > coreutils.links
rm coreutils.tmp.links

# Extract and update all english NAME texts
while read MANPAGE ; do \
	program=`echo $MANPAGE | sed -e "s/\.[0-9]//"` ; \
	section=`echo $MANPAGE | sed -e "s/.\+\.//"` ; \
	english=`zcat /usr/share/man/man$section/$program.$section.gz | sed -ne "/^.SH NAME/ { n; p; q }" | cut -d"-" -f2- | sed -e "s/^\s\+//"`
	echo $program.$section":original:"$english >> tmp.original; \
done < coreutils.manpages

grep -v ":original:" coreutils.translations > tmp.translations
cat tmp.original tmp.translations > tmp.merge
sort tmp.merge > coreutils.translations
rm -f tmp.merge tmp.original tmp.translations

# Generate all manpages
while read MANPAGE ; do \
	program=`echo $MANPAGE | sed -e "s/\.[0-9]//"` ; \
	section=`echo $MANPAGE | sed -e "s/.\+\.//"` ; \
	description=`grep "$program.$section:translation:" coreutils.translations | cut -d":" -f3` ; \
	if [ -z "$description" ] ; then \
		description=`grep "$program.$section:original:" coreutils.translations | cut -d":" -f3` ; \
	fi ; \
	help2man --locale=de_DE.UTF-8 --source="$SOURCE" --name="$description" --output=coreutils/$program.$section $program ; 
done < coreutils.manpages

# Replace the current date with the date from coreutils
for MANPAGE in coreutils/* ; do \
	sed -i -e "/^\.TH/ s/\(\"[1-8]\"\) \"[A-Za-z]\+ $YEAR\"/\1 \"$TRANSLATION $YEAR\"/g" $MANPAGE ; \
done

# Cleanup
rm -r coreutils.manpages
