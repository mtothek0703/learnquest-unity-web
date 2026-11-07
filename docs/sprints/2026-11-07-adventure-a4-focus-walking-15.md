# LearnQuest 3D — A4 Safari focus / walking physics (07.11.2026, 15 Uhr)

## Ausgangslage
Primary GitHub mtothek0703 (michael_kohler1@yahoo.de), Repo mtothek0703/learnquest-unity-web, bestehender DRAFT PR #157. main 46bfea3ecbfa4db8cc755df8d7fab201706d8059; PR-Branch vor Änderung 70 Commits voraus, 2 hinter main. Alle vier Pflichtdokumente auf main gelesen. Vorheriger PR-Head f304fbab96e3660b9f125ecfffc392593b1bf379: PR-CI 42376449765 success.

## Änderung
`godot/adventure/neon_walk_testbed.gd`: Bei Safari-/Fenster-Fokusverlust wird zusätzlich zur Arena-Logik die separate CharacterBody3D-Physik angehalten; bei Fokusgewinn wieder aktiviert. Ohne diese Änderung lief die Figur trotz angehaltener Roboterwarnung durch Schwerkraft oder Tastatureingaben weiter. Kein Eingriff in Runner-Touch-Gesten oder alte Releases.

## Akzeptanzkriterien
- Bei Fokusverlust bleibt die Weltposition der gehenden Figur während weiterer Physikframes konstant; Bewegungstasten sind freigegeben und Roboterwarnung bleibt erhalten.
- Bei Fokusgewinn werden Arena- und Spielfigur-Physik fortgesetzt.
- Bestehende drei Fragen, Missionsziele, Robotergate und XP-Integrationsprüfungen bleiben bestehen.

## Teststatus und Nachweise
- Regression in `res://adventure/adventure_bridge_test.gd` ergänzt: Position, `is_physics_processing()`, Fokuswiederaufnahme.
- Tatsächlich ausgeführter neuer Godot-Import / Headless-Test / Webexport: **noch keiner in diesem Durchlauf**; GitHub Actions für den neuen Commit abwarten und gegebenenfalls reparieren.
- Vorherige CI (f304fba): GitHub Actions 42376449765 erfolgreich; dies bestätigt ausdrücklich **nicht** die neuen Commits.
- Gameplay-Commit `9d61fbed155f729244999b45e85e46a913586b8b`; Test-Commit `2c7ebd5a6e88f5e7bf474279d1af2ea6c5afb4a6`.
- Kein Merge, keine echten 16:9/19.5:9-Renderbilder, keine iPhone-Safari-QA, kein Skyway-Release. PR bleibt DRAFT.

## Nächste Schritte
Neue CI prüfen und Fehler beheben; dann die lizenzierte bestehende Figur ohne Übernahme des experimentellen PR #111 für den Gehmodus verwenden, echte Renderbilder und Gerätetests durchführen. main-Synchronisierung kontrolliert und ohne Überschreiben anderer Arbeiten vorbereiten.
