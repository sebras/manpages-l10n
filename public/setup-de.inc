# Create header, using MET/MEST
timestamp=$(TZ='Europe/Berlin' date "+%d.%m.%Y, %H:%M Uhr")

# Locale which should be passed to po4a
HOMELOCALE=de_DE.UTF-8

# Name of Columns
cname_name="Name"
cname_percent="Prozent"
cname_missing_strings="Übersetzungen bis 80%"
cname_statistics="Statistik"
cname_packet="Paket"
cname_manpages="Handbuchseiten"

cname_onepageuntranslated="1 Datei ist nicht vollständig übersetzt."
cname_severalpagesuntranslated="Dateien sind nicht vollständig übersetzt."

cname_intotal1="Insgesamt sind "
cname_intotal2=" Dateien nicht übersetzt."

# The first part of the string printed in your locale with msgfmt -cv -o /dev/null
cname_msgftstring="übersetzte Meldungen,"
