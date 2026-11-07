# LearnQuest Adventure A4 – Desktop mission retry (07.11.2026, 22 Uhr)

## Ausgangslage und Schutz
- Authentifiziertes GitHub Primary: mtothek0703 / michael_kohler1@yahoo.de; Repository mtothek0703/learnquest-unity-web.
- Vor Änderung alle vier Pflichtdokumente auf main gelesen.
- Main vor Änderung: 46bfea3ecbfa4db8cc755df8d7fab201706d8059; bestehender DRAFT PR #157 / feature/adventure-a1-walkable-neon-testbed-20261106-19; Vergleich vor Änderung: 88 voraus, 2 hinter main.
- Vorheriger PR-Head a9b68f4: Godot PR validation Run 42410242883 completed/success.
- Keine Änderungen an Runner, Quiz, Bossen, Power-ups, Skyway-Archiv, Unity-Archiv oder experimentellem Charakter.

## Spielbare Änderung
- Tastaturtaste R setzt die lokale Neon-City-Abenteuermission zurück, genau wie der bestehende mobile NEUSTART-Button.
- Die vorhandene Reset-Routine stellt Checkpoint, Roboterenergie, Missionsziele und Bewegung wieder her; Renn-Session und XP bleiben unverändert.
- Das Desktop-Kürzel greift nur in der aktiven begehbaren Szene; Fokusverlust sperrt die Eingabe.

## Akzeptanzkriterien und Prüfstand
- [x] Codepfad R -> _retry_from_ui -> reset_mission ergänzt.
- [x] Headless-Regression erweitert: R setzt Position, Geschwindigkeit und Roboterenergie zurück; Adventure-Phase und XP bleiben erhalten.
- [ ] Neuer Godot-Import und Headless-Test für Commit 5d3ec8b sind **noch nicht nachgewiesen** (GitHub CI abwarten).
- [ ] Webexport, reale 16:9-/19.5:9-Renderbilder und iPhone-Safari-Abnahme nicht ausgeführt.
- [ ] Kein Merge/Release, keine neue skyway-vN-URL.

## Commits und nächster Schritt
- Gameplay d5105e76e44879689a3da6341ee6776cf63d79c0
- Test 5d3ec8b7c6ee31156df228dbdb62f9720581ea38
- Nächstes: CI des neuen Heads prüfen und ggf. korrigieren. Anschließend sichere Integration des vorhandenen lizenzierten Rider-Assets in den Gehmodus vorbereiten; PR #111 getrennt halten.
