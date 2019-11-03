# Create header, using MET/MEST
timestamp=$(TZ='Europe/Paris' date "+%d.%m.%Y, %H:%M")

# Locale which should be passed to po4a
HOMELOCALE=fr_FR.UTF-8

# Name of Columns
cname_name="Nom"
cname_percent="Pourcentage"
cname_missing_strings="Traductions jusqu'à 80%"
cname_statistics="Statistiques"
cname_packet="Paquet"
cname_manpages="Pages de manuel"

cname_onepageuntranslated="1 fichier n'est pas complètement traduit."
cname_severalpagesuntranslated="fichiers ne sont pas complètement traduits."

cname_intotal1="Au total, "
cname_intotal2=" ne sont pas complètement traduits."

# The first part of the string printed in your locale with msgfmt -cv -o /dev/null
cname_msgftstring="messages traduits,"
