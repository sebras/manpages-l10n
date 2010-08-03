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
	# Determine whether the manpage section is equal
	my @source_parts = split(/\//, $source);
	my @destination_parts = split(/\//, $destination);
	# If the manpages are in different sections, use a relative link
	if ($source_parts[0] ne $destination_parts[0]) {
		$source = '../' . $source;
	}
	else {
		# The sections are equal, remove them
		$source = $source_parts[1];
	}
	# Change directory to destination manpage for linking
	my $working_directory = $install_path . '/' . $destination_parts[0];
	# We always change the working directory to the destination manpage,
	# so remove the section directory
	$destination = $destination_parts[1];
	# Finally, make sure that the source file really exists.
	# As these are translated manpages, some translations might not
	# be available.
	if (-e $working_directory . '/' . $source) {
		system("( cd $working_directory ; ln -sf $source $destination )");
	}
}
