# LearnQuest Adventure sprint – 2026-11-08 03:00 Europe/Berlin

## Ausgangslage
- Primary GitHub `mtothek0703` (`michael_kohler1@yahoo.de`), Repo `mtothek0703/learnquest-unity-web`, bestehender DRAFT PR #157 und Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19` verifiziert.
- `main` vor Änderung: `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; PR-Head vorher: `cf3a03ab09fc7c22699b6972b1955a142bc75e6d`.
- Alle vier Pflichtdateien auf `main` gelesen. Vorheriger Godot PR validation Run `42433824195` erfolgreich für vorherigen Head.

## Änderung
- Lauf-Visual dreht sich jetzt weich zur tatsächlichen mobilen/Tastatur-Bewegungsrichtung. Rotation ist nur am separaten `WalkingVisual`, nicht am `CharacterBody3D` mit Kollision.
- Keine Änderung an Runner-Touch, Englischfragen, Mission, Robot, Skyway-Archiv oder Unity.
- Commits: `e08e0f4`, `fd6baa0`, `f3c227a`.

## Akzeptanzkriterien
- Bewegung nach rechts dreht die Laufdarstellung sichtbar nach rechts; Collider bleibt unverändert ausgerichtet.
- Runner und übrige Adventure-Mechanik bleiben unbeeinflusst.

## Tatsächlich ausgeführte Tests und Grenzen
- Vorheriger Head: GitHub Actions Godot PR validation `42433824195` erfolgreich; gilt **nicht** als Test des neuen Codes.
- Neuer Head: Regression in `godot/adventure/adventure_bridge_test.gd` ergänzt (visuelle Ausrichtung und Kollisionskörper). Beim Commit noch **kein** Godot-Import, Headless-Test, Webexport, Rendervergleich oder iPhone-Test des neuen Heads ausgeführt/bestätigt.
- PR bleibt DRAFT, kein Merge, keine neue Skyway-Version.

## Nächster Schritt
- CI für neuen Head prüfen und Fehler beheben. Danach echte vorhandene lizenzierte Figur statt provisorischer Kapsel integrieren, mit visuellen 16:9/19.5:9-Render- und iPhone-Tests.
