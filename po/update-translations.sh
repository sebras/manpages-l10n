#!/bin/sh

translations=`find man? -name "*.po" | sort`
for translation in $translations; do
	echo "$translation"
	./update-po.sh "$translation"
done
