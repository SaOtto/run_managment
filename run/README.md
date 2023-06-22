# Zeiten stoppen

## Konfiguration
Für dieses Programm kann folgendes eingestellt werden:
- Datein(en), aus denen die Läuferdaten (Startnummer + Streckenlänge) bezogen werden sollen. (Dies ist normalerweise eine der Dateien, die das Anmelde-Programm erstellt)
- Datei, in der die Zeiten gespeichert werden
- Name der Veranstaltung

Die Konfiguration kann über die grafische Oberfläche (Menüpunkt 'Einstellungen') erfolgen oder durch direktes editieren der json-Datei [.config](./.config).
Wenn die Datei `.config` nicht existiert, startet das Programm mit der Einstellungs-Seite.

## Daten
Die Zeiten werden in der eingestellten Datei gespeichert. Dabei wird in der ersten Zeile der UNIX-Zeitstempel hinterlegt, zu dem der Lauf gestartet wurde.
Die folgenden Zeilen sind prinzipiell im CSV-Format (mit Semikolon getrennt).
Es stehen folgende Spalten zur Verfügung:
- Startnummer
- Strecke
- Zeit in ms
