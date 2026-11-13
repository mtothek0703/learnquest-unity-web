# LearnQuest Adventure A3/A4 – sichtbares Portal-Gate (07.11.2026, 10 Uhr)

## Änderung
Im bestehenden DRAFT PR #157 ist das Ausgangsportal im 3D-Raum jetzt rot, solange Kristalle, Schalter oder Roboterkampf offen sind. Nach drei Kristallen, zwei Schaltern und Roboter-Deaktivierung wird es mintgrün. Die Transparenz bleibt bei 0,35. Missionsreset aktualisiert den Portalzustand über die bestehende Label-Update-Funktion. Kein Eingriff in Runner, Touch-Gesten, Alt-Builds oder experimentellen Charakter PR #111.

## Akzeptanz
- Portal rot bei unvollständiger Mission.
- Portal bleibt rot, wenn nur fünf Sammel-/Schalterziele abgeschlossen sind.
- Portal wird erst nach Roboterkampf grün; Rückkehrbedingungen bleiben unverändert.
- Missionsreset sperrt Portal wieder.

## Tatsächliche Prüfungen und Grenzen
- Primary-GitHub-Konto mtothek0703 / michael_kohler1@yahoo.de, Repository und Branch geprüft. main: 3117869390c6f3dff6409bfde1f64c2d184b0853, Branch vor Änderungen 54 voraus / 1 hinter main.
- LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md auf main gelesen.
- Vorheriger PR-Head 4457d45: Godot PR validation Lauf 42354510857 conclusion success.
- Bestehenden headless Integrationstest res://adventure/adventure_bridge_test.gd um Portal-Material-Assertions erweitert; Testcode committed, **für neue Commits noch kein erfolgreich ausgeführter CI-Test bestätigt**.
- Godot-Import, Webexport, 16:9/19.5:9 echte Renderbilder, iPhone-Safari-Touch und FPS **nicht lokal ausgeführt**. Kein Merge oder Release.

## Commits
- Gameplay 7914b02e2d7e662a2c0102a75f9b127a31a737fc
- Test febaa1d95f168942f6d4bd3df31fe4bd6fed5c9b
- PR #157 bleibt DRAFT.

## Nächster Schritt
Godot-CI des neuen Heads prüfen und Fehler beheben. Anschließend die bestehende lizenzierte Spielfigur im Gehmodus wiederverwenden und echte Querformat-Renderbilder erstellen, ohne PR #111 zu mergen.
