# LearnQuest A4 — Safari-Hintergrundaktionen sperren (07.11.2026, 16 Uhr)

## Basis und Ziel
Primary-GitHub-Konto mtothek0703 / michael_kohler1@yahoo.de; Repository mtothek0703/learnquest-unity-web; bestehender DRAFT PR #157, Branch feature/adventure-a1-walkable-neon-testbed-20261106-19. Vor Änderungen vier Pflichtdokumente auf main gelesen. Main beim Vergleich: 46bfea3ecbfa4db8cc755df8d7fab201706d8059, Branch 73 Commits voraus und 2 hinter main. Vorheriger PR-Head 4e05e2f5f52ebad137fa2c5eeac9a95d802dcbc1 hatte Godot-PR-Validation 42380718978 = success.

## Spielbare Korrektur
Während Safari bzw. das Fenster keinen Fokus hat, können ANGRIFF/ABWEHR, Kristall-/Schalter-Interaktionen, Portal-Rückkehr und Tastaturaktionen keinen Zustand mehr verändern. Die bisherige Fokus-Pause der Figur und der Roboterwarnung bleibt bestehen. Kein Eingriff in Runner-Gesten, drei Englischfragen, vier Welten, Boss-/Power-up-Logik oder archivierte Releases.

## Akzeptanz und Tests
- Unfokussierte Arena ignoriert Kampf, Abwehr, Mission, Portal und E-Taste; nach Fokusgewinn ist Bedienung wieder möglich.
- Headless-Regression in `res://adventure/adventure_bridge_test.gd` erweitert: pausierte Eingaben dürfen Treffer, Schild, Kristalle und Phase nicht verändern.
- Gameplay-Commit aea5f3d3b27efc18320973ad6814af1c0d9f1589; Test-Commit 4f78e2b7e88e6a1a93540a733d437cbd9b28fa03.
- **Tatsächlich ausgeführte neue Tests:** Noch keine; neuer PR-CI-Head muss abgewartet werden. Die erfolgreiche CI 42380718978 gilt nur für den vorherigen Head.
- Keine Godot-Renderbilder 16:9/19.5:9, kein Webexport-/Pages-Nachweis, keine iPhone-QA, kein Merge oder Release. DRAFT beibehalten.

## Nächster Schritt
CI des neuen Heads prüfen, bei Fehlern reparieren. Anschließend lizenzierte Bestandsfigur im Gehmodus und echte Querformat-Bildabnahme priorisieren; PR #111 und alte Skyway-Versionen isoliert halten.
