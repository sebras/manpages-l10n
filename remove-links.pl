#!/usr/bin/perl
#
# Copyright © 2010-2012 Tobias Quathamer <toddy@debian.org>
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
