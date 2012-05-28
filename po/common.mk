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
