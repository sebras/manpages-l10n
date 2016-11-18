# Makefile for manpages-de
#
# Copyright © 2012 Dr. Tobias Quathamer <toddy@debian.org>
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

SUBDIRS = links

EXTRA_DIST = packages.list download-packages.sh update-manpages.sh

all:
	if [ "x$(ac_enable_deprecated_download)" = "xyes" ]; then \
		echo -e "\033[31;1m" ; \
		echo "Warning: The option --enable-download is deprecated and will be removed in the future." ; \
		echo -e "\033[0m" ; \
		./download-packages.sh ; \
		./update-manpages.sh ; \
	fi
