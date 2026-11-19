# Adventure A2 – Neon City: drei Kristalle (06.11.2026, 01:18 CET)

## Änderung
- Eigenständiger Mission-State unter `godot/adventure/adventure_mission.gd` mit drei eindeutig identifizierten Kristallen, doppelter Sammlungssperre, Abschluss-Signal und Reset.
- Drei sichtbare `Area3D`-Kristalle mit Kollisionsformen in der bestehenden begehbaren Arena, darunter einer auf der erhöhten Plattform.
- Die Kristalle werden ausschließlich durch Berührung des Walker-`CharacterBody3D` eingesammelt; nach Sammlung deaktiviert. Kein Eingriff in Runner, Quiz, XP, Boss oder historische Releases.
- Regression `godot/adventure/adventure_crystal_test.gd` für genau drei unterschiedliche Kristalle, doppelte Sammlung, Abschluss und Reset.

## Akzeptanzkriterien
1. Drei unterschiedliche Kristalle sind in der Neon-City-Arena erreichbar, einer erfordert die Plattform.
2. Jeder Kristall zählt nur einmal; bei drei Sammlungen wird genau einmal abgeschlossen.
3. Reset entfernt den Missionsfortschritt; die künftige Integration muss zusätzlich `reset_crystal()` auf allen drei Szenenobjekten aufrufen.
4. Der bestehende Runner und seine Touch-Gesten bleiben unverändert.

## Tatsächliche Prüfung
- GitHub-Dateien über Primary-Konto auf `feature/adventure-a1-walk-arena-20261105-2111` erstellt/geändert.
- Vorher `main` auf `0e01246620d33a9afcbb617152748adac4402993` geprüft, Branch 17 Commits voraus und 0 zurück.
- Vier Pflichtdokumente auf `main` gelesen.
- **Nicht ausgeführt:** Godot 4.4.1 Import, Headless-Test, echte Renderaufnahmen, Webexport, Safari-Test, Archivschutz und Pages. Der Test ist nur hinzugefügt, nicht als bestanden bestätigt.
- **Kein Merge/Release**. Das A2-Feature bleibt experimentell im DRAFT PR #146; die eigentliche Runner-Integration und XP-Vergabe sind ausdrücklich noch nicht vorhanden.

## Nächster Schritt
Godot-Test und echte Arena-Bilder ausführen; danach zwei Schalter, Portal und sicheren Session-Wechsel mit Feature-Schalter implementieren. PR #111 bleibt getrennt DRAFT.
