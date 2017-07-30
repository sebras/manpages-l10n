# Upstream directory

In this directory, all upstream manpages are collected. For historical
reasons, the *primary* directory is updated from the Debian unstable
manpages. All other directories are considered secondary and can be
created ad libitum.

## How to create a new secondary directory

Every directory name needs to start with "*secondary-*".
It might make sense to use the distribution's name
and (if applicable) codename for the given release.

Examples:

* *secondary-debian-stretch*
* *secondary-ubuntu-artful*
* *secondary-netbsd-7.1*
* *secondary-opensuse-leap-42.2*
* *secondary-gentoo*
* *secondary-fedora-26*

There is only one mandatory script in each secondary directory,
which must be called "*update-manpages.sh*".

This script is responsible for creating all "man" directories
needed for the distribution's manpages as well as a file called
"*links.txt*". In that file, every manpage which is a link to
another manpage is listed on a single line in the format:

```
destination link_name
```

In the "man" directories, every translatable manpage must
be available in an uncompressed format.
