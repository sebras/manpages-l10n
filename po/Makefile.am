SUBDIRS = man1 man2 man3 man4 man5 man6 man7 man8

EXTRA_DIST = generate-addendum.sh generate-manpage.sh

# Install the links here, because this is only needed once.
# In common.mk, it would be called once for every man directory
install-data-hook:
	for linkfile in `ls $(top_srcdir)/english/links/*`; do \
		perl $(top_srcdir)/create-links.pl $(DESTDIR)$(mandir)/de $$linkfile; \
	done
