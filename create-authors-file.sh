#!/bin/sh
#
# Copyright © 2012-2018 Dr. Tobias Quathamer <toddy@debian.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Generate AUTHORS file
echo "# Authors" > AUTHORS.md
echo >> AUTHORS.md
echo "The following people have contributed to the translation" >> AUTHORS.md
echo "of Linux manpages. The list is sorted alphabetically." >> AUTHORS.md

# Generate Brazilian Portuguese authors list
echo >> AUTHORS.md
echo >> AUTHORS.md
echo "## Brazilian Portuguese:" >> AUTHORS.md
echo >> AUTHORS.md

# Extract all Brazilian Portuguese translators from the copyright headers
files=$(find po/pt_BR/man? -name "*po" | sort)
# files="$files $(find po/secondary-*/man? -name "*po" | sort)"
for translation in $files; do
	# Use the header up until the first msgid
	# and remove the comment character
	translators=$(sed '/msgid/q;s/^#\s\+//' "$translation" |
	# Throw away the common (non translator) lines
	grep -v "Brazilian Portuguese translation of manpages" |
	grep -v "This file is distributed under the same license as the manpages-l10n package" |
	grep -v "Copyright © of this file:" |
	grep -v "FIXME:" |
	grep -v "msgid" |
	# Split lines to extract the name (and e-mail address)
	cut -f1 -d",")
	# Save a list of all translators in a temporary file for copyright determination
	echo "$translators" >> translators_pt_BR.list
done
# Sort, unique, remove blank lines from file, and indent with an asterisk
sort translators_pt_BR.list | uniq | sed -e "/^$/d; s/^/* /" > tmp_pt_BR.list
cat tmp_pt_BR.list >> AUTHORS.md

# Generate Dutch authors list
echo >> AUTHORS.md
echo >> AUTHORS.md
echo "## Dutch:" >> AUTHORS.md
echo >> AUTHORS.md

# Extract all Dutch translators from the copyright headers
files=$(find po/nl/man? -name "*po" | sort)
# files="$files $(find po/secondary-*/man? -name "*po" | sort)"
for translation in $files; do
	# Use the header up until the first msgid
	# and remove the comment character
	translators=$(sed '/msgid/q;s/^#\s\+//' "$translation" |
	# Throw away the common (non translator) lines
	grep -v "Dutch translation of manpages" |
	grep -v "This file is distributed under the same license as the manpages-l10n package" |
	grep -v "Copyright © of this file:" |
	grep -v "FIXME:" |
	grep -v "msgid" |
	# Split lines to extract the name (and e-mail address)
	cut -f1 -d",")
	# Save a list of all translators in a temporary file for copyright determination
	echo "$translators" >> translators_nl.list
done
# Sort, unique, remove blank lines from file, and indent with an asterisk
sort translators_nl.list | uniq | sed -e "/^$/d; s/^/* /" > tmp_nl.list
cat tmp_nl.list >> AUTHORS.md

# Generate French authors list
echo >> AUTHORS.md
echo >> AUTHORS.md
echo "## French:" >> AUTHORS.md
echo >> AUTHORS.md

# Extract all French translators from the copyright headers
files=$(find po/fr/man? -name "*po" | sort)
# files="$files $(find po/secondary-*/man? -name "*po" | sort)"
for translation in $files; do
	# Use the header up until the first msgid
	# and remove the comment character
	translators=$(sed '/msgid/q;s/^#\s\+//' "$translation" |
	# Throw away the common (non translator) lines
	grep -v "French translation of manpages" |
	grep -v "This file is distributed under the same license as the manpages-l10n package" |
	grep -v "Copyright © of this file:" |
	grep -v "FIXME:" |
	grep -v "msgid" |
	# Split lines to extract the name (and e-mail address)
	cut -f1 -d",")
	# Save a list of all translators in a temporary file for copyright determination
	echo "$translators" >> translators_fr.list
done
# Sort, unique, remove blank lines from file, and indent with an asterisk
sort translators_fr.list | uniq | sed -e "/^$/d; s/^/* /" > tmp_fr.list
cat tmp_fr.list >> AUTHORS.md

# Generate German authors list
echo >> AUTHORS.md
echo >> AUTHORS.md
echo "## German:" >> AUTHORS.md
echo >> AUTHORS.md

# Extract all German translators from the copyright headers
files=$(find po/de/man? -name "*po" | sort)
# files="$files $(find po/secondary-*/man? -name "*po" | sort)"
for translation in $files; do
	# Use the header up until the first msgid
	# and remove the comment character
	translators=$(sed '/msgid/q;s/^#\s\+//' "$translation" |
	# Throw away the common (non translator) lines
	grep -v "German translation of manpages" |
	grep -v "This file is distributed under the same license as the manpages-l10n package" |
    grep -v "This file is distributed under the same license as the manpages-de package" |
	grep -v "Copyright © of this file:" |
	grep -v "FIXME:" |
	grep -v "msgid" |
	# Split lines to extract the name (and e-mail address)
	cut -f1 -d",")
	# Save a list of all translators in a temporary file for copyright determination
	echo "$translators" >> translators_de.list
done
# Sort, unique, remove blank lines from file, and indent with an asterisk
sort translators_de.list | uniq | sed -e "/^$/d; s/^/* /" > tmp_de.list
cat tmp_de.list >> AUTHORS.md

# Generate Italian authors list
echo >> AUTHORS.md
echo >> AUTHORS.md
echo "## Italian:" >> AUTHORS.md
echo >> AUTHORS.md

# Extract all Italian translators from the copyright headers
files=$(find po/it/man? -name "*po" | sort)
# files="$files $(find po/secondary-*/man? -name "*po" | sort)"
for translation in $files; do
	# Use the header up until the first msgid
	# and remove the comment character
	translators=$(sed '/msgid/q;s/^#\s\+//' "$translation" |
	# Throw away the common (non translator) lines
	grep -v "Italian translation of manpages" |
	grep -v "This file is distributed under the same license as the manpages-l10n package" |
    grep -v "This file is distributed under the same license as the manpages-de package" |
	grep -v "Copyright © of this file:" |
	grep -v "FIXME:" |
	grep -v "msgid" |
	# Split lines to extract the name (and e-mail address)
	cut -f1 -d",")
	# Save a list of all translators in a temporary file for copyright determination
	echo "$translators" >> translators_it.list
done
# Sort, unique, remove blank lines from file, and indent with an asterisk
sort translators_it.list | uniq | sed -e "/^$/d; s/^/* /" > tmp_it.list
cat tmp_it.list >> AUTHORS.md

# Generate Polish authors list
echo >> AUTHORS.md
echo >> AUTHORS.md
echo "## Polish:" >> AUTHORS.md
echo >> AUTHORS.md

# Extract all Polish translators from the copyright headers
files=$(find po/pl/man? -name "*po" | sort)
# files="$files $(find po/secondary-*/man? -name "*po" | sort)"
for translation in $files; do
	# Use the header up until the first msgid
	# and remove the comment character
	translators=$(sed '/msgid/q;s/^#\s\+//' "$translation" |
	# Throw away the common (non translator) lines
	grep -v "Polish translation of manpages" |
	grep -v "This file is distributed under the same license as the manpages-l10n package" |
	grep -v "Copyright © of this file:" |
	grep -v "FIXME:" |
	grep -v "msgid" |
	# Split lines to extract the name (and e-mail address)
	cut -f1 -d",")
	# Save a list of all translators in a temporary file for copyright determination
	echo "$translators" >> translators_pl.list
done
# Sort, unique, remove blank lines from file, and indent with an asterisk
sort translators_pl.list | uniq | sed -e "/^$/d; s/^/* /" > tmp_pl.list
cat tmp_pl.list >> AUTHORS.md

# Generate Romanian authors list
echo >> AUTHORS.md
echo >> AUTHORS.md
echo "## Romanian:" >> AUTHORS.md
echo >> AUTHORS.md

# Extract all Romanian translators from the copyright headers
files=$(find po/ro/man? -name "*po" | sort)
# files="$files $(find po/secondary-*/man? -name "*po" | sort)"
for translation in $files; do
	# Use the header up until the first msgid
	# and remove the comment character
	translators=$(sed '/msgid/q;s/^#\s\+//' "$translation" |
	# Throw away the common (non translator) lines
	grep -v "Romanian translation of manpages" |
	grep -v "This file is distributed under the same license as the manpages-l10n package" |
	grep -v "Copyright © of this file:" |
	grep -v "FIXME:" |
	grep -v "msgid" |
	# Split lines to extract the name (and e-mail address)
	cut -f1 -d",")
	# Save a list of all translators in a temporary file for copyright determination
	echo "$translators" >> translators_ro.list
done
# Sort, unique, remove blank lines from file, and indent with an asterisk
sort translators_ro.list | uniq | sed -e "/^$/d; s/^/* /" > tmp_ro.list
cat tmp_ro.list >> AUTHORS.md

# Generate Spanish authors list
echo >> AUTHORS.md
echo >> AUTHORS.md
echo "## Spanish:" >> AUTHORS.md
echo >> AUTHORS.md

# Extract all Spanish translators from the copyright headers
files=$(find po/es/man? -name "*po" | sort)
# files="$files $(find po/secondary-*/man? -name "*po" | sort)"
for translation in $files; do
	# Use the header up until the first msgid
	# and remove the comment character
	translators=$(sed '/msgid/q;s/^#\s\+//' "$translation" |
	# Throw away the common (non translator) lines
	grep -v "Spanish translation of manpages" |
	grep -v "This file is distributed under the same license as the manpages-l10n package" |
	grep -v "Copyright © of this file:" |
	grep -v "FIXME:" |
	grep -v "msgid" |
	# Split lines to extract the name (and e-mail address)
	cut -f1 -d",")
	# Save a list of all translators in a temporary file for copyright determination
	echo "$translators" >> translators_es.list
done
# Sort, unique, remove blank lines from file, and indent with an asterisk
sort translators_es.list | uniq | sed -e "/^$/d; s/^/* /" > tmp_es.list
cat tmp_es.list >> AUTHORS.md

# Finally, delete all temporary lists
rm tmp*.list translators*.list
