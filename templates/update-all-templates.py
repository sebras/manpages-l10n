#!/usr/bin/python3
#
# Copyright © 2020 Dr. Tobias Quathamer <toddy@debian.org>
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

from pathlib import Path
import subprocess

# Search all mandirs with translations and
# reduce them to mandir sections
mandirs = []
for directory in Path("../po").glob("*/man*"):
    if directory.name not in mandirs:
        mandirs.append(directory.name)
mandirs.sort()

for mandir in mandirs:
    print("Section", mandir)

    # Find all pofiles of the section in all languages
    # and reduce them to only one pofile
    translations = []
    pofiles = Path("../po").glob("*/{}/*".format(mandir))
    for pofile in pofiles:
        if pofile.stem not in translations:
            translations.append(pofile.stem)
    translations.sort()

    for translation in translations:
        subprocess.run(['./generate-one-template.sh', translation])
