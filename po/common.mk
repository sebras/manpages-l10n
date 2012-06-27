# Common rules for all manpage sections

pofiles = $(wildcard $(srcdir)/*.po)
addendums = $(patsubst $(srcdir)/%.po,%.add, $(pofiles))
manpages = $(patsubst $(srcdir)/%.po,%, $(pofiles))

EXTRA_DIST = $(pofiles)
MOSTLYCLEANFILES = $(addendums) $(manpages)

%.add: %.po
	$(top_srcdir)/po/generate-addendum.sh $<

%.$(MANPAGE_SECTION): %.$(MANPAGE_SECTION).add %.$(MANPAGE_SECTION).po
	$(top_srcdir)/po/generate-manpage.sh $(top_srcdir) $@

all: $(manpages)

install-data-hook: $(manpages)
	$(mkinstalldirs) $(DESTDIR)$(mandir)/de/man$(MANPAGE_SECTION)
	for manpage in `ls *.$(MANPAGE_SECTION)`; do \
		$(INSTALL_DATA) $$manpage $(DESTDIR)$(mandir)/de/man$(MANPAGE_SECTION) ;\
		gzip --best $(DESTDIR)$(mandir)/de/man$(MANPAGE_SECTION)/$$manpage ;\
	done

uninstall-hook: $(manpages)
	for linkfile in `ls $(top_srcdir)/english/links/*.links`; do \
		perl $(top_srcdir)/remove-links.pl $(DESTDIR)$(mandir)/de $$linkfile; \
	done
	for manpage in `ls *.$(MANPAGE_SECTION)`; do \
		rm -f $(DESTDIR)$(mandir)/de/man$(MANPAGE_SECTION)/$$manpage.gz ;\
	done
