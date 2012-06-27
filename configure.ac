# Configuration for manpages-de
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

AC_INIT(manpages-de, [1.0])

AM_INIT_AUTOMAKE([foreign dist-bzip2 no-dist-gzip])

# Support the downloading of manpages from Debian
AC_ARG_ENABLE(
    [download],
    [AS_HELP_STRING([--enable-download],
        [download manpages from Debian instead of using manpages installed on the system (default is no)])],
    [ac_enable_download=yes],
    [ac_enable_download=no]
)
AC_SUBST([ac_enable_download])

AC_CONFIG_FILES([
    Makefile
    english/Makefile
    english/links/Makefile
    po/Makefile
    po/man1/Makefile
    po/man2/Makefile
    po/man3/Makefile
    po/man4/Makefile
    po/man5/Makefile
    po/man6/Makefile
    po/man7/Makefile
    po/man8/Makefile
])

AC_OUTPUT
