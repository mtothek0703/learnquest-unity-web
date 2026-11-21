# LearnQuest Adventure Sprint — 2026-11-10 05:19 CET

## Ziel / sichtbare Änderung
Die echten Godot-Bilder des vorherigen Sprints zeigten den animierten 16-Bone-Held im begehbaren Neon-City-Level zu klein. Die ausschließlich für den Gehmodus verwendete Third-Person-Kamera folgt nun in einem Abstand von 5.2 statt 8.0 Metern und mit 2.9 statt 4.5 Metern Höhenversatz; Blickziel leicht auf 0.75 m erhöht. Die Figur soll dadurch deutlich mehr Bildschirmfläche erhalten. Runner-Kamera, Touch-Gesten, Missionen, Boss-/Quiz-Loop und Skyway-Archive bleiben unverändert.

## Akzeptanzkriterien
- Rigged-Held in der echten Spielkamera bei 1280x720 und 1170x540 besser lesbar, ohne dass HUD, Plattformen oder Missionsziele verdeckt werden.
- Raycast-Kameraschutz bei Hindernissen und geglättete Rückfahrt funktionieren mit dem neuen Abstand.
- Headless Adventure Bridge Test, Godot-Import, Webexport und Archivschutz bestehen.
- Manuelle iPhone-Safari-Querformat-/FPS-/Clipping-Prüfung separat; ohne sie kein Merge/Release.

## Code / Nachweise
- PR #157, Branch feature/adventure-a1-walkable-neon-testbed-20261106-19.
- Gameplay-Commit 0f2c5d00e8ca815cd81a21f56150089f4c6fab0d: godot/adventure/neon_walk_testbed.gd.
- Test-Commit d97c67e2ebbc7febc26ae004be2faec80a7cc8cf: godot/adventure/adventure_bridge_test.gd.
- Vor der Änderung Primary-Konto mtothek0703 (michael_kohler1@yahoo.de), Repository und main 46e899a84c500243274badf71255bb2afec3186b geprüft. Alle vier Pflichtdokumente auf main gelesen. Vorheriger vollständiger PR #157 Godot-CI #42741232770 SUCCESS; PR #160 #42734105793 SUCCESS.

## Tatsächlich ausgeführte Tests / Status
- Quellcode- und Regressionstest-Sichtprüfung; geänderte Kamerakonstanten und Testschwellen kontrolliert.
- Neuer Godot-Import, Headless-Test, Webexport, Bildvergleich und iPhone-Test wurden in diesem Durchlauf NICHT ausgeführt oder bestätigt; aktuelle PR-CI für den neuen Head separat prüfen. Keine Behauptung über FPS oder sichtbare Qualitätssteigerung ohne neue Screenshots.
- PR #160 (Blender-Bonusportal) unverändert DRAFT, kein bestätigtes Live-Release. PR #111 separat. Kein Merge, kein Release.

## Nächster Schritt
Nach grünem neuem CI echte 1280x720- und 1170x540-Spielbilder prüfen. Falls die Kamera Ziele/Touch-HUD abschneidet, Abstand/Framing im selben PR korrigieren. Anschließend Material-/Rig-/Laufkontaktqualität des Helden und Neon-City-Umgebung als zusammenhängenden vertikalen Slice verbessern.
