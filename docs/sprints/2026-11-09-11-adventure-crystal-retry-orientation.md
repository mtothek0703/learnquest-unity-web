# Adventure A4 – Kristall-Rotation beim Neustart zurücksetzen (09.11.2026, 11 Uhr)

## Änderung
Im bestehenden DRAFT PR #157 wird bei `reset_mission()` die Rotation der `PickupVisual`-Meshes zurückgesetzt. Nach einem lokalen Missionsneustart beginnen alle Kristalle wieder in ihrer Ausgangsausrichtung; die vorhandene Animation während der laufenden Mission bleibt bestehen. Runner, Quiz, historische Releases und Character-DRAFT bleiben unangetastet.

## Akzeptanzkriterien
- Ein gedrehter Kristall hat nach `reset_mission()` wieder `Vector3.ZERO` als Rotation.
- Kristall- und Schalter-Zähler sowie bestehende Retry-/Runner-Regressionsbedingungen bleiben erhalten.
- Godot PR-CI und echter Webexport müssen vor einer Freigabe erfolgreich sein.

## Verifikation
- GitHub Primary `mtothek0703` / `michael_kohler1@yahoo.de`, Repository `mtothek0703/learnquest-unity-web`, Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19` vor Änderungen geprüft.
- Pflichtdokumente auf `main` gelesen. Main `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; Vergleich meldete 171 ahead / 2 behind, Merge-Basis `b901029`.
- Letzter zuvor überprüfter CI-Lauf zu `80338ac`: `42592272722`, conclusion `success`. Er deckt die neuen Commits **nicht** ab.
- Codeänderung `ef7f4ec35380657063ca36316e7b0673b4f47f09`; Regressionstest `69fc845bdab3c1406894bbf25bd92f7ad4357142`.
- Tatsächlich ausgeführte Prüfungen: GitHub-Dateien/Branch/Main/Commit-Vergleich und vorheriger CI-Status. **Kein lokaler Godot-Import, kein ausgeführter neuer Headless-Test, kein Webexport, keine echten Renderbilder, kein iPhone-Test.** Neuer CI-Head noch ausstehend.

## Ergebnis
Implementiert und Regressionstest ergänzt, aber noch **nicht** als erfolgreich getestet oder releasefähig eingestuft. PR #157 bleibt DRAFT. Kein Merge/Release. Nächster Schritt: CI für den neuen Head prüfen, anschließend visuelle Querformat-QA und iPhone-Safari-Abnahme.
