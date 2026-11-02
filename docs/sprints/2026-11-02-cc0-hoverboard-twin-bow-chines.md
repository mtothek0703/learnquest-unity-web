# 2026-11-02 — CC0 Hoverboard: zweifache modellierte Bug-Chines (DRAFT)

## Ausgangslage und Freigabe
- Verbindliche Dokumente auf `main` gelesen: `LEARNQUEST_SPRINTS.md`, `LEARNQUEST_RELEASE_POLICY.md`.
- Richtige Verbindung: GitHub Primary / `mtothek0703` (`michael_kohler1@yahoo.de`), Repository `mtothek0703/learnquest-unity-web`.
- Stabiler Kanal `main`: `16693217f9cc37b59329cb2e46ce090680b15e9b`, veröffentlichte V151; keine neue Versionsnummer ohne nachweisbaren neuen stabilen Mehrwert.
- Experiment: PR #111 auf `sprint-v124-quaternius-rigged-hero`; bleibt **DRAFT**, keine visuelle Freigabe und kein Merge.

## Geometrische Änderung
- Die zuvor gerundete, nahezu detailfreie Hoverboard-Bugoberfläche besitzt jetzt zwei spiegelbildliche, **in die vorhandene geschlossene 3D-Chassis-Geometrie integrierte** erhöhte Längschines und eine dazwischen liegende flache V-Rinne.
- Die Reliefhöhe wird mit einem glatten Übergang vor dem Mittel-/Fußbereich ausgeblendet; die existierenden Reifen-/Turbinenelemente, beweglichen Finnen und Leuchtkanten bleiben erhalten.
- Der vorhandene Satin-Vertexfarbverlauf betont die tatsächlich erhöhten Flächen; keine zusätzliche MeshInstance, Draw Calls, Assets, Kollisionen, Änderungen an Steuerung oder 65-Knochen-Rig.
- Änderungen in `godot/hoverboard_sculpted_hull.gd`; Regression in `godot/hoverboard_sculpted_hull_test.gd` prüft echte GPU-Vertices, bilaterale Symmetrie, Höhenunterschied zur mittigen Rinne und das Abklingen der Chines.

## Akzeptanz und Grenzen
- Godot-PR-CI: Gameplay/65-Bone-Regressionen, Webexport und Querformat-Render-Captures abwarten und Ergebnis nachtragen.
- Vorher/Nachher bei identischer Kamera und Pose vergleichen, insbesondere tatsächliche Sichtbarkeit im Chase-Bild. Geometrie-Tests allein beweisen **keinen** Premium-Grafiksprung.
- Keine neue Skyway-Version; Main, alte URLs, drei Englischaufgaben, vier Welten, Bosskämpfe, vier Power-ups und Unity-Archiv bleiben unberührt.
- Reale iPhone-FPS, Clipping und vollständige Touch-Spielrunde weiterhin offen.

## Änderungen
- Geometrie: `5bf9311d8228f4c0566dfd407c619b159d8a0047`
- Regression: `2c741027cfd7d0a8de45079c865742276bb15de1`
