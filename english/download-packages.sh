#!/bin/sh
packages=`find -maxdepth 1 -type d | grep -v "^\.$" | cut -d/ -f2 | sort`

for package in $packages; do
	echo -n "Checking package $package ... "
  # Download HTML page and discover the correct link
  url=`wget --quiet -O - "http://packages.debian.org/sid/amd64/$package/download" |
  grep "http://ftp.de.debian.org/debian/pool/" |
  sed -e "s,.*\(http://ftp.de.debian.org/debian/pool/[^\"]*\).*,\1,"`
  deb_version=`basename $url`
  if [ -f "$package/$deb_version" ]; then
    echo "current"
  else
    echo "downloading"
    wget --quiet --directory-prefix="$package" "$url"
  fi
done
