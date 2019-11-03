# Create header, using MET/MEST
timestamp=$(TZ='Europe/Amsterdam' date "+%d.%m.%Y, %H:%M Uhr")

# Locale which should be passed to po4a
HOMELOCALE=nl_NL.UTF-8

# Name of Columns
cname_name="Name"
cname_percent="Percent"
cname_missing_strings="Translations until 80%"
cname_statistics="Statistics"
cname_packet="Packet"
cname_manpages="Man pages"

cname_onepageuntranslated="1 file is incompletely translated."
cname_severalpagesuntranslated="files are incompletely translated."

cname_intotal1="In total "
cname_intotal2=" files are not translated."

# The first part of the string printed in your locale with msgfmt -cv -o /dev/null
cname_msgftstring="vertaalde berichten,"
