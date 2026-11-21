# LearnQuest 3D – Neon City skyline integration (2026-11-10 00:13 CET)

## Ausgangslage / verifizierte Kontozuordnung
- GitHub-Verbindung: Primary, Login `mtothek0703`, Repository `mtothek0703/learnquest-unity-web`, Zielbranch `feature/adventure-a1-walkable-neon-testbed-20261106-19`.
- `main`: `46e899a84c500243274badf71255bb2afec3186b`; Adventure-Branch vor Änderungen 222 Commits voraus, drei hinter main. Kein Merge/Rebase ohne Konfliktprüfung.
- Auf `main` gelesen: `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md`.
- Vorheriger Adventure-Head `c01c380`: vollständige PR-CI #42700273925 erfolgreich. Blender-Portal-PR #160 `7d5fd8c`: vollständige PR-CI #42681487769 erfolgreich, getrennt DRAFT, nicht live bestätigt.

## Eine zusammenhängende sichtbare Verbesserung
Im tatsächlichen begehbaren Neon-City-Testbed wird jetzt eine leichte, sechsteilige Dach-Skyline gebaut: gestaffelte Türme mit verschiedenen Höhen, je drei emissiven Fassadenbändern und einer Dachantenne. Die Geometrie liegt außerhalb des begehbaren Rooftops, fügt keine PhysicsBodies hinzu und verändert weder Runner, Missionen, Touch-Steuerung noch die vier Welten. Kein zusätzliches Asset, keine Lizenzkosten, keine Blender-Cloud-Minuten verbraucht. Das ist **eine erste Levelkompositionsverbesserung**, kein fertiger hochwertiger City-Look.

## Akzeptanzkriterien
1. Sechs sichtbare Architektur-Landmarks werden in der realen Adventure-Szene erzeugt, je mit Fassade, Lichtbändern und Beacon.
2. Die Skyline führt keine neuen Kollisionen auf dem Laufweg ein; bestehender Adventure-Bridge-Test prüft das.
3. Runner- und alte Skyway-/Unity-Dateien bleiben unverändert.
4. Vor Freigabe: Godot-Import, vollständige Headless-Gameplay-CI, Webexport, echte Godot-Kamerabilder bei 1280×720 und 1170×540, iPhone-Safari-FPS/Touch/Clipping prüfen.

## Tatsächlich ausgeführte Prüfungen
- GitHub-Konto, Repository, Main-Stand, PR-Metadaten, Pflichtdokumente und vorherige Commit-CI per Connector geprüft.
- Vorherige CI: Adventure #42700273925 SUCCESS; Blender #42681487769 SUCCESS.
- Neuer Code und Bridge-Regression committed; **neue Godot-Tests nicht lokal ausgeführt**, keine bestätigte CI für diesen Head, keine echten Vorher/Nachher-Renderbilder ausgewertet, kein iPhone-Test.
- Blender-Portal: Artefakt `learnquest-blender-race-before-after` in #42681487769 vorhanden (Artifact ID 13703016629); tatsächliche visuelle Beurteilung weiterhin offen. Portal nicht als Live-Version bestätigt.

## Commits und Ergebnis
- `836601fe63ac88c9c6f99e5ece6fdeb7fc6bb10d`: spielbare Adventure-Szene um leichte Neon-City-Skyline erweitert.
- `8cb100b57b8103c4aa27cdc262acf25783cd1168`: bestehende Adventure-Bridge-Regression prüft Skyline-Knoten und kollisionsfreie Deko.
- Ergebnis: Code committed, **CI für neuen Head ausstehend**. PR #157 und #160 bleiben DRAFT. Kein Merge, kein Webexport-Release, keine neue Skyway-URL.

## Nächster Schritt
Zuerst CI auf neuem Head prüfen und echte Fehler beheben; danach die echte Spielkamera in beiden Querformaten rendern und Figur, Skyline, Beleuchtung, Animation, Clipping und mobile HUD-Komposition visuell bewerten. Nur nach bestandenem Qualitätsgate weitere Modellpolitur/Blender-Integration.
