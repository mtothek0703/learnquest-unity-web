# Adventure A3 – Robot attack telegraph pulse (08.11.2026, 21 Uhr)

## Ausgangslage
Primary-Konto mtothek0703 (michael_kohler1@yahoo.de), Repository mtothek0703/learnquest-unity-web, DRAFT PR #157, Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19` vor Änderung geprüft. Main-Basis laut PR: `b9010294fea1728212bea50d413c465d55706dd2`; PR-Head zuvor `4ceaa30d3b2d6dd4a6e0cbe4c283ddd35ea4f08b`. Die vier Pflichtdokumente auf main wurden gelesen. CI für bisherigen Head: Godot PR validation #42514469863, completed/success.

## Konkrete Änderung
- `godot/adventure/neon_walk_testbed.gd`: Robotermesh pulsiert während der angekündigten Attacke auf 114 % und kehrt danach auf 100 % zurück. Die Warnfarbe bleibt bestehen. Nur Mesh-Skalierung; keine Änderungen an Kampf-Reichweite, Kollisionskörper, Runner oder Skyway-Archiven.
- `godot/adventure/adventure_bridge_test.gd`: prüft Mesh-Skalierung während der Warnung und Rückkehr nach Ablauf.

## Akzeptanzkriterien
1. Aktiver Robot-Telegraph zeigt rote Farbe und 1,14-fache Mesh-Skalierung.
2. Nach Ablauf normale Farbe und 1,0-fache Skalierung.
3. Bestehender Runner, drei Pflichtfragen, vier Welten, XP und historisches Archiv bleiben unberührt.

## Tatsächlich durchgeführte Prüfungen und Grenzen
- Vorherigen CI-Lauf für alten PR-Head über GitHub abgefragt: success; **kein Nachweis für die neuen Änderungen**.
- Quelltext anhand der aktuellen GitHub-Dateien und vorhandenen Teststelle geprüft; **kein lokaler Godot-Import, kein neuer Headless-Test, kein Webexport, kein Renderbild, kein iPhone-Test** in diesem Durchlauf.
- Gameplay-Commit: `3612a2e7cc031be5c2fc566dd2794c8bccd7936f`; Test-Commit: `294147860caffccd9ffeb7c89cfa72a942e494cb`.
- PR #157 bleibt DRAFT; kein Merge, kein Release.

## Nächste Schritte
Neue Godot-CI für den dokumentierten Head abwarten und Fehler beheben. Anschließend echte 16:9-/19,5:9-Bilder und die lizenzierte Spielfigur im isolierten Gehmodus prüfen.
