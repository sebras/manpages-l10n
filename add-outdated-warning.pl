#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;

my $filename = fileparse($ARGV[0]);
(my $program, my $section) = split(/\./, $filename);

# Set up warning text
my $warning = <<WARNING;
.PP
Diese Handbuchseite ist eventuell veraltet. Im Zweifelsfall ziehen Sie
die englischsprachige Handbuchseite zu Rate, indem Sie
.IP
man -LC $section $program
.PP
eingeben.
WARNING

# Insert only once per file
my $inserted = 0;

# Read the whole file
while (<>) {
	# Match the first .SH section header
	if (!$inserted and /^\.SH\s+/) {
		# Print this section header
		print;
		# Read until next section header
		while (<>) {
			if (/^\.SH\s+/) {
				# Prepend the warning
				print $warning;
				# Remember that the warning is now inserted
				$inserted = 1;
				# Leave this inner loop and process rest of file
				last;
			}
			# Print lines for inner loop
			print;
		}
	}
	# Print non-matching lines
	print;
}
