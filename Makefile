# Do "make install" to copy the pages to their destination.
# Do "make gz" before "make install" if you use compressed source pages.
# Do "make remove" before "make gz" if you may have uncompressed
# source pages around.

prefix=/usr

MANDIR=$(prefix)/share/man/de

example: remove gz install

remove:
	for i in man?; do for j in $$i/*; do rm -f $(MANDIR)/$$j $(MANDIR)/$$j.gz; done; done

gz:
	for i in man?; do gzip $$i/*; done

install:
	test -d $(MANDIR) || install -d -m 755 $(MANDIR)
	for i in man?; do \
	  test -d $(MANDIR)/$$i || install -d -m 755 $(MANDIR)/$$i; \
	  for m in $$i/*; do \
	    test -f $(MANDIR)/$$m || install -m 644 $$m $(MANDIR)/$$i; \
	  done; \
	done
