#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;

# Get the installation path from Makefile
my $install_path = $ARGV[0] || die "Please specify the installation path.";

# Read the whole file
while (<>) {
	# Remove trailing newline
	chop();
	# Format is source, destination with their corresponding manpage section
	# e.g. man1/access.1.gz or man5/complex.5.gz
	(my $source, my $destination) = split(/ /);
	if (-e $install_path . '/' . $source) {
		system("rm -f $install_path/$destination");
	}
}
