# Makefile for manpages-de
#
# Copyright © 2012-2017 Dr. Tobias Quathamer <toddy@debian.org>
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

# Generate all localized manpages for given distribution
all-local:
	cd $(top_srcdir)/po ; \
	./generate-all-manpages.sh $(upstream)

# Remove generated manpages
clean-local:
	rm -rf $(top_srcdir)/po/localized

# Install localized manpages for given distribution
install-data-hook:
	for directory in $(top_srcdir)/po/localized/$(upstream)/man*; do \
		mansection=$$(basename $$directory) ; \
		$(mkinstalldirs) $(DESTDIR)$(mandir)/de/$$mansection ; \
		for manpage in $$directory/*; do \
			filename=$$(basename $$manpage) ; \
			$(INSTALL_DATA) $$manpage $(DESTDIR)$(mandir)/de/$$mansection ; \
			gzip --best $(DESTDIR)$(mandir)/de/$$mansection/$$filename ; \
		done \
	done
	perl $(top_srcdir)/create-links.pl $(DESTDIR)$(mandir)/de \
		$(top_srcdir)/upstream/$(upstream)/links.txt

# Uninstall localized manpages for given distribution
uninstall-hook:
	for link in $$(cut -d" " -f2 $(top_srcdir)/upstream/$(upstream)/links.txt); do \
		rm -f $(DESTDIR)$(mandir)/de/$$link ; \
	done
	for directory in $(top_srcdir)/po/localized/$(upstream)/man*; do \
		mansection=$$(basename $$directory) ; \
		for manpage in $$directory/*; do \
			filename=$$(basename $$manpage) ; \
			rm -f $(DESTDIR)$(mandir)/de/$$mansection/$$filename.gz ; \
		done \
	done

# Reformat all .po files and commit changes
.PHONY: reformat
reformat:
	cd $(top_srcdir)/po ; \
	./format-po.sh ; \
	git commit -m "Reformat .po files, no content changes" . || true

# Download and update all upstream manpages
.PHONY: update-upstream
update-upstream:
	cd $(top_srcdir)/upstream ; \
	./update-distribution-manpages.sh ; \
	git add . ; \
	git commit -m "Update upstream manpages" || true

# Update all template files from upstream manpages
.PHONY: update-templates
update-templates:
	cd $(top_srcdir)/templates ; \
	./update-templates.sh ; \
	cd $(top_srcdir)/templates ; \
	./create-common-templates.sh ; \
	git add . ; \
	git commit -m "Update common templates" || true

# Export the current git tree into the tarball directory
dist-hook:
	git archive --format=tar manpages-de-$(VERSION) | (cd $(distdir) && tar xf -)
