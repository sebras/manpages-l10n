# Configuration for manpages-de
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

AC_INIT(manpages-de, [1.22])

AM_INIT_AUTOMAKE([foreign dist-xz no-dist-gzip])

# Check that po4a is available on the system
AC_PATH_PROG([po4a], [po4a], [no])
if test "x$po4a" = "xno"; then
    AC_MSG_ERROR([You need to install po4a])
fi

AC_CONFIG_FILES([
    Makefile
])

AC_OUTPUT
