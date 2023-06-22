# Anmeldung

## Konfiguration
Bei diesem Programm ist folgendes einstellbar:
- Name des Laufes
- verfügbare Streckenlängen
- Speicherort der Daten-Dateien
- ob die automatische Zählung der Startnummern aufsteigend ('asc') oder absteigend ('desc') sein soll

Diese Einstellungen können über den Menü-Punkt 'Einstellungen' im Programm auf einer grafischen Oberfläche getätigt werden oder durch direktes editieren der Datei [.config](./.config). 
Dabei handelt es sich um eine `json`-Datei.

Existiert die `.config` nicht, nutzt das Programm folgende Default-Werte:
- Strecken: 2,5km; 5km; 10km
- Speichertort: `./data`
- absteigende Zählung

## Daten
Im eingestellten Daten-Ordner wird pro Streckenlänge eine Datei mit den angemeldeten Teilnehmern angelegt.
Dabei handelt es sich um CSV-Dateien, in denen ein Semikolon als Spaltentrenner verwendet wird.
Es stehen folgede Spalten (in dieser Reihenfolge) zur Verfügung:
- Startnummer
- Strecke
- Altersklasse
- Nachname
- Vorname
- Laufgruppe (kann leer sein)
- Geburtsjahr
