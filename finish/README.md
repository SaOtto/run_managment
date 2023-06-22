# Auswertung
Dieses Programm führt die erhobenen Zeiten und die Daten der Läufer zusammen und erstellt eine Altersklassenbasierte Auswertung.
Die Auswertung wird nach Strecken sortiert angezeigt und kann als csv-Datei gespeichert werden.
Außerdem lassen sich Urkunden erstellen.

## Konfiguration
Es kann folgendes eingestellt werden:
- Dateien, aus denen die Läuferdaten bezogeen werden
- Dateien, aus denen die Zeiten bezogen werden
- Datei, in der die Auswertung (csv) gespeichert werden soll
- Datei, in der die Urkunden (pdf) gespeichert werden sollen
- Name des Laufes

Die Konfiguration kann über die grafische Oberfläche (Menüpunkt 'Einstellungen') erfolgen oder durch direktes editieren der json-Datei [.config](./.config).
Wenn die Datei `.config` nicht existiert, startet das Programm mit der Einstellungs-Seite.


## Bilder auf den Urkunden
Auf den Urkunden befinden sich Bilder oben links und rechts. Die entsprechenden Bilddateien werden aus dem Ordner [images](./images) bezogen und tragen die Dateinamen picLeft.jpg und picRight.jpg . 