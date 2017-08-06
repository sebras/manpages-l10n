# Makefile for manpages-de
#
# Copyright © 2017 Dr. Tobias Quathamer <toddy@debian.org>
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

# Use only primary and secondary with [ps] selection,
# in order to filter out the common-* directories
pofiles = $(sort $(wildcard $(srcdir)/[ps]*/man*/*.po))
manpages = $(patsubst %.po,%, $(pofiles))

current_pofiles = $(sort $(wildcard $(srcdir)/$(upstream)/man*/*.po))
current_manpages = $(patsubst %.po,%, $(current_pofiles))

MOSTLYCLEANFILES = $(manpages)

# Common rules for all manpage sections
%: %.po
	$(srcdir)/generate-manpage.sh $@

# Generate all localized manpages for given distribution
all-local: $(current_manpages)

# Generate all manpages for every distribution
all-manpages: $(manpages)

# Install localized manpages for given distribution
install-data-hook: $(current_manpages)
	for directory in $(srcdir)/$(upstream)/man*; do \
		mansection=$$(basename $$directory) ; \
		$(mkinstalldirs) $(DESTDIR)$(mandir)/de/$$mansection ; \
	done
	for manpage in $(current_manpages); do \
		filename=$$(basename $$manpage) ; \
		mansection=$$(basename $$(dirname $$manpage)) ; \
		$(INSTALL_DATA) $$manpage $(DESTDIR)$(mandir)/de/$$mansection ; \
		gzip --best $(DESTDIR)$(mandir)/de/$$mansection/$$filename ; \
	done
	perl $(top_srcdir)/create-links.pl $(DESTDIR)$(mandir)/de \
		$(top_srcdir)/upstream/$(upstream)/links.txt

# Uninstall localized manpages for given distribution
uninstall-hook:
	for link in $$(cut -d" " -f2 $(top_srcdir)/upstream/$(upstream)/links.txt); do \
		rm -f $(DESTDIR)$(mandir)/de/$$link ; \
	done
	for manpage in $(current_manpages); do \
		filename=$$(basename $$manpage) ; \
		mansection=$$(basename $$(dirname $$manpage)) ; \
		rm -f $(DESTDIR)$(mandir)/de/$$mansection/$$filename.gz ; \
	done
