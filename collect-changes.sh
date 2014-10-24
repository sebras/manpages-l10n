#!/bin/sh
set -e

LAST_RELEASE=manpages-de-`git tag -l "manpages-de*" | cut -d- -f3 | sort --version-sort | tail -n1`

echo "Version X.X"
echo
echo "  "`LC_ALL=C date`
echo
echo "  * New translations:"
git diff --name-status $LAST_RELEASE po/man?/ |
grep "\.po" |
grep "^A" |
cut -f2 |
sort |
cut -d"/" -f3 |
sed -e "s/\.po$//" |
perl -e "my @a; while (<>) { chomp; push(@a, \$_); } print join(', ', @a); print \"\\n\";" |
fold --spaces --width=68 |
perl -ne "print '    '; print;"

echo "  * Updated translations:"
git diff --name-status $LAST_RELEASE po/man?/ |
grep "\.po" |
grep "^M" |
cut -f2 |
sort |
cut -d"/" -f3 |
sed -e "s/\.po$//" |
perl -e "my @a; while (<>) { chomp; push(@a, \$_); } print join(', ', @a); print \"\\n\";" |
fold --spaces --width=68 |
perl -ne "print '    '; print;"

echo "  * Removed translations:"
git diff --name-status $LAST_RELEASE po/man?/ |
grep "\.po" |
grep "^D" |
cut -f2 |
sort |
cut -d"/" -f3 |
sed -e "s/\.po$//" |
perl -e "my @a; while (<>) { chomp; push(@a, \$_); } print join(', ', @a); print \"\\n\";" |
fold --spaces --width=68 |
perl -ne "print '    '; print;"

echo
echo
