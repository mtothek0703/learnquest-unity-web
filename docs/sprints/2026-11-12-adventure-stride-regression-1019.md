# LearnQuest Sprint – 12.11.2026 10:19 CET – Blender stride regression

## Ausgangslage und Schutz
Primary GitHub `mtothek0703` / `michael_kohler1@yahoo.de`; Repo `mtothek0703/learnquest-unity-web`; main `92d49b100a022d8864112ba38494d3565fca2a4f`. Vor Änderung alle vier Pflichtdokumente direkt von main gelesen. Adventure DRAFT PR #157; Blender-Portal DRAFT PR #160 separat, kein Merge. Vorheriger PR-Head `39f3932a9c5022f1157d793645ca38f9f505d606`, PR-CI #43182082496 erfolgreich.

## Konkrete Änderung
`godot/adventure/adventure_bridge_test.gd`: Headless-Regression auf der tatsächlich importierten Blender-Animation prüft, dass ein mitten im Schritt ausgelöster Wechsel WALK → SPRINT → WALK die normierte Schrittphase bewahrt. Dies sichert den vorherigen Gameplay-Fix `63b840e` gegen spätere Regressionen ab. Keine Änderungen an Runner, Missionen, Kollision, 3-Fragen-Gate, vier Welten, alten Builds oder Unity-Archiv.

## Akzeptanzkriterien
1. Test setzt eine echte mittlere Walk-Phase und sampelt den AnimationPlayer.
2. Beide Geschwindigkeitswechsel erhalten die normierte Schrittphase mit maximal 0.001 Abweichung.
3. Vollständige Godot-PR-CI inklusive Import, Gameplay und Webexport grün, bevor Qualitätsverbesserung als validiert bezeichnet wird.
4. Reale Godot-Renderbilder 1280×720 / 1170×540 und iPhone-Safari-FPS/Touch/Clipping bleiben eigenständige offene Gates.

## Tests und Ergebnis
Vor Änderung: GitHub Actions PR #43182082496 = success für vorherigen Head. In diesem Sprint: Testcode committed, **neue CI noch nicht als bestanden bestätigt**; CI des neuen Heads nachprüfen. Keine lokalen Godot-Tests ausgeführt. Commit `a4bdfc3899891904b803d3b4e08e46b2880a7f37` in PR #157. Kein Release, kein Merge. PR #160 bleibt DRAFT und nicht als stabil live bestätigt.

## Nächster Schritt
CI des neuen Heads auswerten und eventuelle Testfehler im selben PR beheben; anschließend echte In-Game-Aufnahmen und visuelle Übergangsqualität prüfen. Bei Bedarf erst danach kontrolliertes Pose-Blending implementieren.
