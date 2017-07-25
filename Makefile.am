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

# Generate all localized manpages
all-local:
	cd po && \
	./generate-all-manpages.sh

# Reformat all .po files and commit changes
.PHONY: reformat
reformat:
	cd po && \
	./format-po.sh && \
	git commit -m "Reformat .po files, no content changes" . || true

# Export the current git tree into the tarball directory
dist-hook:
	git archive --format=tar manpages-de-$(VERSION) | (cd $(distdir) && tar xf -)
