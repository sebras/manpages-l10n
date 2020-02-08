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

import json
import os
import re
import shutil
import subprocess
import sys
import urllib.request


# Read package information from a JSON file, if available
package_data = {}
if os.path.exists("downloads/packages.json"):
    with open("downloads/packages.json") as input_file:
        package_data = json.loads(input_file.read())

# Get current package information
download_page = urllib.request.urlopen("https://ftp-stud.hs-esslingen.de/pub/Mirrors/Mageia/distrib/cauldron/x86_64/media/core/release/")
contents = download_page.read().decode()
download_page.close()

# Read all packages names
with open("packages.txt") as input_file:
    for line in input_file:
        package = line.strip()

        # Download HTML page and discover the correct link
        print("Checking package '{}' ... ".format(package), end="")

        package_url = re.findall(r"\"({}-[0-9].*?\.rpm)\"".format(package), contents)
        if len(package_url) != 1:
            print("Error: Could not find URL for '{}'.".format(package), file=sys.stderr)
            # sys.exit(1)
        else:
            package_url = package_url[0]

        package_url = "https://ftp-stud.hs-esslingen.de/pub/Mirrors/Mageia/distrib/cauldron/x86_64/media/core/release/{}".format(package_url)
        package_filename = re.split(r"/", package_url)[-1]

        # If the latest download is already available, skip this package
        if package in package_data:
            if package_data[package]['filename'] == package_filename:
                print("current.")
                continue

        # Store information about downloaded package
        package_data[package] = {
            'filename': package_filename,
            'needs_update': True,
        }

        # Prepare for downloading the file
        package_dir = "downloads/{}".format(package)
        local_filename = "downloads/{}/{}".format(package, package_filename)

        # Ensure there are no leftovers of previous packages
        os.makedirs(package_dir, exist_ok=True)
        shutil.rmtree(package_dir)
        os.makedirs(package_dir, exist_ok=True)

        # Download new package
        urllib.request.urlretrieve(package_url, local_filename)
        print("downloaded.")

        # Get the exact filename of data.tar with the extension
        os.makedirs("{}/tmp".format(package_dir), exist_ok=True)

        # Extract the package into a temporary file
        with open("{}/tmp/tmpcpio".format(package_dir), "w") as outfile:
            subprocess.run(["rpm2cpio", local_filename], stdout=outfile)
        with open("{}/tmp/tmpcpio".format(package_dir), "r") as infile:
            subprocess.run(["bsdcpio", "--quiet", "-i", "--make-directories"], cwd="{}/tmp".format(package_dir), stdin=infile)

        # Move the manpages up
        manpath = "{}/tmp/usr/share/man".format(package_dir)
        for mandir in os.listdir(manpath):
            if not mandir.startswith("man"):
                continue
            # Make sure the directory exists
            os.makedirs(mandir, exist_ok=True)
            shutil.move(
                "{}/{}".format(manpath, mandir),
                "{}".format(package_dir)
            )

        # Cleanups
        shutil.rmtree("downloads/{}/tmp".format(package))
        os.remove(local_filename)

# Save package information in a JSON file
with open("downloads/packages.json", "w") as output_file:
    output_file.write(json.dumps(package_data, sort_keys=True, indent=4))
