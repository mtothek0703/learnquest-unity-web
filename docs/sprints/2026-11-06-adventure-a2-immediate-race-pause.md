# Adventure A2 – Rennkulisse beim Absteigen stoppen (06.11.2026, 15 Uhr)

## Prüfung vor Änderung
Primary GitHub: mtothek0703 / michael_kohler1@yahoo.de. Repository: mtothek0703/learnquest-unity-web; main: 0e01246620d33a9afcbb617152748adac4402993. Vier Pflichtdokumente auf main gelesen. Ziel: bestehender DRAFT-Integrationsbranch aus PR #146; kein main-Merge.

## Fehler und Änderung
Die Runner-Funktion _process() kehrt bei phase == "on_foot" früh zurück. Die zuvor im Rennen auf true gesetzten running-Flags der vier Kulissen werden deshalb nicht mehr aktualisiert. Beim Eintritt werden jetzt alle vier running-Flags explizit auf false gesetzt, bevor die Phase auf on_foot wechselt. Bei Rückkehr setzt der normale Runner-_process() die Flags entsprechend der aktiven Welt erneut. Keine Änderungen an Quiz, Bossen, Power-ups, Runner-Gesten oder Alt-Releases.

## Akzeptanzkriterien
- Alle vier Scenery-Controller erhalten running=false beim Eintritt in die Arena.
- Keine weiterlaufende Rennkulisse im Gehmodus; Rückkehr aktiviert nur die ausgewählte Welt.
- Drei Englischaufgaben, Runner-Touch und Fortschritt bleiben unverändert.

## Tatsächliche Tests und Grenzen
Quellcodeprüfung: _enter_neon_adventure und _process auf PR #146 gelesen; Early-Return-Fehler nachgewiesen. Struktureller Godot-Regressionstest adventure_race_pause_test.gd hinzugefügt, **nicht ausgeführt**. Kein verfügbarer Godot-4.4.1-Import, Headless-Gameplay, Webexport, 16:9/19.5:9-Bilder oder iPhone-Test. Laufende Szene/Physik weiterhin nicht abgenommen. Kein Release.

## Commits / PR
Code: 413d9fdf50229ac2cac56d21a001a93422824d0b. Test und dieses Protokoll: separate Folgecommits im DRAFT PR #146. Kein Merge. Nächster Schritt: Godot-Laufzeittest des vollständigen Übergangs mit Rennobjekten, dann sichere Integration der Robot- und Touch-Komponenten.
