# LearnQuest Adventure A0 — 2026-11-05

## Ausgangslage
Primary GitHub `mtothek0703`, Repository `mtothek0703/learnquest-unity-web`, main-Ausgangspunkt `0e01246620d33a9afcbb617152748adac4402993`. Vor Änderungen vier Pflichtdokumente aus main gelesen. Bestehender Runner `godot/world.gd`: `phase` menu/training/race/results, `quiz_active`, `TASKS_PER_ROUND = 3`, `world_choice`; Runner-Gesten in `touch_gestures.gd`. Vier Welten unverändert.

## Implementiert
Isolierte, standardmäßig deaktivierte `RefCounted`-Zustandsmaschine in `godot/adventure/adventure_session_gate.gd`. Erlaubt Neon-City-Abstieg nur in race nach drei ausdrücklich gezählten Aufgaben und ohne aktives Quiz. Einmaliger Wechsel RACE -> TRANSITION -> ON_FOOT -> TRANSITION -> RACE; Reset verlangt neue drei Aufgaben. Kein Zugriff auf Runner, Speicherstand, Touch oder alte Releases. Eine separate Godot-Testdatei prüft positive und negative Übergänge.

## Akzeptanzkriterien
- Default `enabled=false` lässt Runner unverändert.
- Zwei Fragen, falsche Welt, laufendes Quiz oder falsche Phase blockieren Abstieg.
- Einmaliger Übergang und Rückkehr; kein zweiter Abstieg; Retry setzt Gate zurück.
- Noch **nicht** integriert oder spielbar: Laufen, Springen, Kamera, Touch-Controller, Arena, Kristalle, Kampf, Übergang in `world.gd`.

## Testmatrix / tatsächlicher Status
- Godot-Test vorgesehen: `godot --headless --path godot --script res://adventure/adventure_session_gate_test.gd`.
- **Nicht ausgeführt**: Godot-Import, Headless-Gameplay, Webexport, echte Renderbilder, iPhone-Safari, Archivschutz, Pages. Es liegt keine grüne CI-Abnahme vor.
- Kein Merge und **kein Release**. Keine Skyway-Version reserviert.

## Nächster Schritt
Test in CI ausführen und Fehler beheben; danach A1: isolierte begehbare Neon-Arena mit CharacterBody3D, physischer Kollision, Sprung und getrennten Touchflächen. Integration in `world.gd` erst mit Tests der bestehenden drei Fragen und des Runner-Pfads.
