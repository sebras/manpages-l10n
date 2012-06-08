# Makefile for manpages-de
#
# Copyright © 2012 Tobias Quathamer <toddy@debian.org>
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

SUBDIRS = man1 man2 man3 man4 man5 man6 man7 man8

EXTRA_DIST = generate-addendum.sh generate-manpage.sh

# Install the links here, because this is only needed once.
# In common.mk, it would be called once for every man directory
install-data-hook:
	for linkfile in `ls $(top_srcdir)/english/links/*`; do \
		perl $(top_srcdir)/create-links.pl $(DESTDIR)$(mandir)/de $$linkfile; \
	done
