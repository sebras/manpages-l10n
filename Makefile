# Do "make install" to copy the compressed pages to their destination.
# Do "make uninstall" to remove the installed pages.

prefix=/usr

MANDIR=$(prefix)/share/man/de

all:
	echo Please choose a target (install or uninstall)

install:
	test -d $(DESTDIR)/$(MANDIR) || install -d -m 755 $(DESTDIR)/$(MANDIR)
	# Install old manpages
	for i in man?; do \
	  test -d $(DESTDIR)/$(MANDIR)/$$i || install -d -m 755 $(DESTDIR)/$(MANDIR)/$$i; \
	  for m in $$i/*; do \
	    test -f $(DESTDIR)/$(MANDIR)/$$m || install -m 644 $$m $(DESTDIR)/$(MANDIR)/$$i; \
			# Add a warning about possibly outdated manpages \
			perl add-outdated-warning.pl $(DESTDIR)/$(MANDIR)/$$m > manpage.tmp; \
			mv manpage.tmp $(DESTDIR)/$(MANDIR)/$$m; \
			# Compress manpages \
			gzip $(DESTDIR)/$(MANDIR)/$$m; \
	  done; \
	done
	# Install coreutils manpages
	for m in coreutils/*; do \
		file=`basename $$m`; \
		section=`basename $$m | sed -e "s/.\+\.//"`; \
    test -d $(DESTDIR)/$(MANDIR)/man$$section || install -d -m 755 $(DESTDIR)/$(MANDIR)/man$$section; \
    test -f $(DESTDIR)/$(MANDIR)/man$$section/$$file || install -m 644 $$m $(DESTDIR)/$(MANDIR)/man$$section/$$file; \
		# Compress manpages \
		gzip $(DESTDIR)/$(MANDIR)/man$$section/$$file; \
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
	for linkfile in `find -type f -name "*.links"`; do \
		perl create-links.pl $(DESTDIR)/$(MANDIR) $$linkfile; \
	done

uninstall:
	# Remove links
	for linkfile in `find -type f -name "*.links"`; do \
		perl remove-links.pl $(DESTDIR)/$(MANDIR) $$linkfile; \
	done
	# Remove old manpages
	for m in man?/*; do \
		rm -f $(DESTDIR)/$(MANDIR)/$$m.gz; \
	done
	# Remove coreutils manpages
	for m in coreutils/*; do \
		file=`basename $$m`; \
		section=`basename $$m | sed -e "s/.\+\.//"`; \
		rm -f $(DESTDIR)/$(MANDIR)/man$$section/$$file.gz; \
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
	cp -R english/ man?/ coreutils/ generated/ \
	CHANGES COPYRIGHT GPL-3 Makefile README VERSION \
	add-outdated-warning.pl coreutils.links create-links.pl remove-links.pl \
	manpages-de-$(version)
	tar cjf manpages-de-$(version).tar.bz2 manpages-de-$(version)
	rm -rf manpages-de-$(version)
