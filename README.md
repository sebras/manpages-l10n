Note to Linux distributions
===========================

Starting from version 1.0, manpages-de tries to download the
original manpages used for generating the translation from
a Debian server. If the building machine does not have internet
access, this will fail.

The new approach, starting with version 1.1, is now to first
use the already installed manpages from the local system.
Therefore, if you're building the package yourself, you need
to make sure that all corresponding manpages are installed.
Alternatively, you can revert to the previous behaviour by
using the configure option --enable-download.

                          Tobias (toddy@debian.org), Hamburg, 27.06.2012


Dieses ist die aktuelle Distribution deutscher Manpages für Linux.

Dieses Projekt wurde von Andries Brouwer ins Leben gerufen, der das
Manpages-Paket für Linux verwaltet, da er neben englischen Seiten auch
deutsche Übersetzungen geschickt bekommen hat. Es wurde später von
Martin Schulze <joey@infodrom.org> übernommen. Seit 2010 wird das
Projekt von Dr. Tobias Quathamer <toddy@debian.org> weitergeführt.

Die Manualseiten werden üblicherweise in »/usr/share/man/de«
installiert. Um sie innerhalb des Programms »man« bekannt zu machen,
muss die Variable LC_MESSAGES oder LANG die Sprache Deutsch (»de«)
enthalten, also z. B. »de_DE@euro«, »de_AT« oder auch nur »de«.
Zusätzlich muss das Verzeichnis »/usr/share/man/de« zu den MANDB_MAPs
in »/etc/manpath.conf« hinzugefügt werden. Dies passiert allerdings
in der Regel automatisch, wenn Sie das entsprechende Paket
Ihrer Distribution verwenden. Der verwendete Pager (PAGER) muss
in der Lage sein, Umlaute anzuzeigen. Wird »less« verwendet, dann
muss »LESSCHARSET=utf-8« gesetzt werden. Weitere Informationen hierzu
stehen in man(1).

Informationen zum aktuellen Status des Projekts stehen unter
folgender URL zur Verfügung:

        http://manpages-de.alioth.debian.org/

Wenn Du an diesem Projekt teilnehmen und ein paar Seiten übersetzen,
korrekturlesen oder sonst mithelfen möchtest, melde Dich einfach
auf der Mailing-Liste <debian-l10n-german@lists.debian.org>.


                              Andries (aeb@cwi.nl), Eindhoven, 12.02.1996
                              Joey (joey@linux.de), Oldenburg, 01.01.2002
                           Tobias (toddy@debian.org), Hamburg, 07.10.2010
