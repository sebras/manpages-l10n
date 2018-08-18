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

AC_INIT(manpages-de, [2.7])

AM_INIT_AUTOMAKE([foreign dist-xz no-dist-gzip])

# Add option for selection of distribution
AC_ARG_ENABLE([distribution],
  AS_HELP_STRING([--enable-distribution=DIST],
    [Enable translations for specific distribution. @<:@default=debian@:>@.]
  ),
  ,
  [enable_distribution="debian"]
)

# Handle the distribution and set up the upstream directory name
AS_IF([test "x$enable_distribution" = "xdebian"],
  dnl Special case: Debian uses the name "primary".
  [upstream="primary"],
  dnl All other cases: Prepend "secondary-" to the name.
  [upstream="secondary-$enable_distribution"]
)
AC_SUBST([upstream])

# Show the wanted distribution
AC_MSG_CHECKING([name of wanted distribution])
AC_MSG_RESULT([$enable_distribution])

# Check if the wanted distribution has
# own translations in an upstream directory
AC_MSG_CHECKING([that "$enable_distribution" has own translations])
AS_IF([test -d "upstream/$upstream"],
  [AC_MSG_RESULT([yes])],
  [
    AC_MSG_RESULT([no])
    AC_MSG_ERROR([there are no translations for "$enable_distribution".])
  ]
)

# Check that po4a is available on the system
AC_PATH_PROG([po4a], [po4a], [no])
AS_IF([test "x$po4a" = "xno"],
  [AC_MSG_ERROR([You need to install po4a])]
)

AC_CONFIG_FILES([
    Makefile
    po/Makefile
])

AC_OUTPUT
