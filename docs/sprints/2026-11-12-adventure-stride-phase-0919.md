# LearnQuest Adventure sprint – 2026-11-12 09:19 CET

## Änderung
PR #157: Der skinned Blender-Held übernimmt beim Wechsel zwischen Walk und Sprint die normalisierte Schrittphase (0–1), statt bei jedem Geschwindigkeitswechsel die Animation auf das erste Bild zurückzusetzen. Reset beim Respawn bleibt erhalten. Nur die visuelle Animation wird verändert; Runner-Steuerung, Kollisionsphysik, Missionslogik und bestehende Builds bleiben unberührt.

## Akzeptanzkriterien
- Beim Umschalten Walk ↔ Sprint beginnt der neue Clipabschnitt mit der bisherigen Schrittphase.
- Bei Wechseln zu Jump/Fall/Land/Idle bleiben die bisherigen Zustandsstarts erhalten.
- Godot-Import, Headless-Regression, Webexport und beide echten Querformat-Aufnahmen prüfen; anschließend auf iPhone-Safari manuell Lauf-/Sprintwechsel und Clipping beurteilen.

## Tatsächlich ausgeführte Prüfungen
- GitHub Primary, Repository und main-Commit 92d49b100a022d8864112ba38494d3565fca2a4f geprüft; vier Pflichtdokumente auf main gelesen.
- PR #157 vor Änderung: 245 Commits voraus, fünf hinter main; vorherige PR-CI 42823860586 SUCCESS. PR #160 vorherige CI 42734105793 SUCCESS.
- Patch-Text und Zielstelle beim Schreiben kontrolliert. **Kein lokaler Godot-Import, keine neue Headless-Testausführung, kein Webexport, keine Renderbilder und kein iPhone-Test in diesem Sprint bestätigt.** Neuer PR-CI-Status nach Push separat abwarten.

## Commit / Status
Gameplay-Commit: 63b840e0b9b250d32cda760513a83f7558407276 auf bestehendem DRAFT PR #157. Kein Merge, kein Release. PR #160 bleibt separat DRAFT; Portal nicht als stabil veröffentlicht bestätigt. V154 und alte Archive nicht verändert.

## Nächste Arbeit
Neue CI prüfen; bei Fehler sofort korrigieren. Danach reale Godot-Spielkamera-Screenshots (1280×720 und 1170×540), Bein-/Arm-Clipping, Übergänge und Neon-City-Gesamtkomposition prüfen. Die Phasekontinuität reduziert nur eine Ursache des Foot-Snaps; echtes Pose-Blending ist noch nicht implementiert.
