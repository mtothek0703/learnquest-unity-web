# LearnQuest Adventure A2 – echtes Ausgangsportal (06.11.2026, 22 Uhr)

## Identität und Basis
Primary GitHub: mtothek0703 / michael_kohler1@yahoo.de. Repository: mtothek0703/learnquest-unity-web. Bestehender DRAFT PR #157, Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`. Main bei Beginn: `3117869390c6f3dff6409bfde1f64c2d184b0853`; Branch 17 Commits voraus, 1 Commit hinter main. Vor Änderung alle vier Pflichtdokumente auf main gelesen. Kein neuer A1-Branch.

## Gameplay-Änderung
Die bisher von überall bedienbare AUFSTEIGEN-Schaltfläche gibt das Rennen nach Missionsabschluss nur noch frei, wenn die gehende Figur höchstens 2 m vom sichtbaren grünen Ausgangsportal an Position (0,1,6) entfernt steht. Das Portal liegt auf dem Startdach. Die 3 Kristalle, 2 Schalter, Quiz-Gate, XP-Einmalbelohnung und Runner bleiben unverändert. Die Portalmarkierung verwendet ausschließlich Godot-Primitiven, keine neuen Assets.

## Akzeptanzkriterien
- Vor 3 Kristallen + 2 Schaltern keine Rückkehr.
- Nach Mission, aber außerhalb des Portalradius keine Rückkehr.
- Innerhalb des Portalradius Rückkehr zum gleichen Runner und genau einmal 75 XP.
- Kein Runner-/Touch-/Archiv-Eingriff.

## Tests und Grenzen
Vor Änderung: PR-Head `dc4b27af94410dfa25ac014107531fb275924991`, Godot PR validation Run 42286140700: GitHub conclusion success. Das ist **nicht** die Abnahme der neuen Änderung. Der existierende `godot/adventure/adventure_bridge_test.gd` wurde um Negativtest für Fern-Aufstieg und anschließende Portal-Rückkehr erweitert. Tests der neuen Commits beim Schreiben dieser Dokumentation noch nicht als erfolgreich verifiziert. Godot-Import, Webexport, reale 16:9-/19.5:9-Renderbilder und iPhone-Safari-QA weiterhin als separate Gates offen. Kein Merge/Release.

## Commits
- `6b290535ff97800b0f32277d57622fc39b689dd4`: sichtbares Portal und Reichweitenprüfung.
- `e8f159dd403ca6c5dfae5ac974b3101bb4c1d2f2`: Headless-Regressionstest angepasst.

## Nächster Schritt
Aktuelle CI für den neuen PR-Head prüfen, eventuelle Fehler beheben. Danach A3-Roboter mit Telegraph, Abwehr und gesonderter mobiler Angriffstaste in **denselben** Adventure-Vertikalschnitt integrieren; PR #157 DRAFT belassen, bis echte Geräte-/Export-Gates bestanden sind.
