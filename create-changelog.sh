#!/bin/sh
set -e

git checkout CHANGES
./collect-changes.sh > tmp-changes
sed -i -e "s/ $//" tmp-changes
cat tmp-changes CHANGES > new-changes
mv new-changes CHANGES
rm tmp-changes
