# Do "make install" to copy the compressed pages to their destination.
# Do "make uninstall" to remove the installed pages.
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

prefix=/usr

MANDIR=$(prefix)/share/man/de

all:
	echo "Please choose a target (install or uninstall)"

install:
	test -d $(DESTDIR)/$(MANDIR) || install -d -m 755 $(DESTDIR)/$(MANDIR)
	# Install old manpages
	for i in man?; do \
	  test -d $(DESTDIR)/$(MANDIR)/$$i || install -d -m 755 $(DESTDIR)/$(MANDIR)/$$i; \
	  for m in $$i/*; do \
	    test -f $(DESTDIR)/$(MANDIR)/$$m || install -m 644 $$m $(DESTDIR)/$(MANDIR)/$$i; \
			# Compress manpages \
			gzip $(DESTDIR)/$(MANDIR)/$$m; \
	  done; \
	done
	# Install generated manpages
	for m in generated/man?/*; do \
		file=`basename $$m`; \
		section=`basename $$m | sed -e "s/.\+\.//"`; \
		test -d $(DESTDIR)/$(MANDIR)/man$$section || install -d -m 755 $(DESTDIR)/$(MANDIR)/man$$section; \
		test -f $(DESTDIR)/$(MANDIR)/man$$section/$$file || install -m 644 $$m $(DESTDIR)/$(MANDIR)/man$$section/$$file; \
		# Compress manpages \
		gzip $(DESTDIR)/$(MANDIR)/man$$section/$$file; \
	done
	# Install links
	for linkfile in `find links/ -type f`; do \
		perl create-links.pl $(DESTDIR)/$(MANDIR) $$linkfile; \
	done

uninstall:
	# Remove links
	for linkfile in `find links/ -type f`; do \
		perl remove-links.pl $(DESTDIR)/$(MANDIR) $$linkfile; \
	done
	# Remove old manpages
	for m in man?/*; do \
		rm -f $(DESTDIR)/$(MANDIR)/$$m.gz; \
	done
	# Remove generated manpages
	for m in generated/man?/*; do \
		file=`basename $$m`; \
		section=`basename $$m | sed -e "s/.\+\.//"`; \
		rm -f $(DESTDIR)/$(MANDIR)/man$$section/$$file.gz; \
	done

version=`perl -pe "" VERSION`

dist:
	rm -rf manpages-de-$(version)
	mkdir manpages-de-$(version)
	mkdir manpages-de-$(version)/links
	cp -R man?/ generated/ \
	CHANGES COPYRIGHT GPL-3 Makefile README VERSION \
	create-links.pl remove-links.pl \
	manpages-de-$(version)
	for linkfile in `find english/ -type f -name "*.links"`; do \
		cp $$linkfile manpages-de-$(version)/links/`basename $$linkfile .links`; \
	done
	tar cjf manpages-de-$(version).tar.bz2 manpages-de-$(version)
	rm -rf manpages-de-$(version)
