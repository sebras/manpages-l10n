# Create header, using MET/MEST
timestamp=$(TZ='Europe/Amsterdam' date "+%d.%m.%Y, %H:%M")

# Locale which should be passed to po4a
HOMELOCALE=nl_NL.UTF-8

# Name of Columns
cname_name="Naam"
cname_percent="Percentage"
cname_missing_strings="Vertalingen tot 80%"
cname_statistics="Statistiek"
cname_packet="Pakket"
cname_manpages="Man Pagina's"

cname_onepageuntranslated="1 bestand is niet volledig vertaald."
cname_severalpagesuntranslated="bestanden zijn niet volledig vertaald."

cname_intotal1="Totaal zijn "
cname_intotal2=" bestanden niet volledig vertaald."

# The first part of the string printed in your locale with msgfmt -cv -o /dev/null
cname_msgftstring="vertaalde berichten,"
