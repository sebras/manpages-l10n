# Do "make install" to copy the pages to their destination.
# Do "make gz" before "make install" if you use compressed source pages.
# Do "make remove" before "make gz" if you may have uncompressed
# source pages around.

prefix=/usr

MANDIR=$(prefix)/man/de

example: remove gz install

remove:
	for i in man?; do for j in $$i/*; do rm -f $(MANDIR)/$$i/$$j; done; done

gz:
	for i in man?; do gzip $$i/*; done

install:
	test ! -d $(MANDIR) || install -d -m 755 $(MANDIR)
	for i in man?; do \
		test ! -d $(MANDIR)/$$i || install -d -m 755 $(MANDIR)/$$i; \
		install -m 644 $$i/* $(MANDIR)/$$i; \
	done
