# Adventure A1 – Plattform und Kamera-Kollisionsschutz (2026-11-05, 22:13 CET)

## Ausgangslage und Änderungen
Primary-Konto mtothek0703 / michael_kohler1@yahoo.de bestätigt. Repository mtothek0703/learnquest-unity-web; main vor Änderung: `0e01246620d33a9afcbb617152748adac4402993`. Alle vier verpflichtenden Richtlinien/Roadmap-Dateien auf main gelesen. Weiterarbeit ausschließlich auf dem bereits von diesem main abgeleiteten DRAFT-Branch `feature/adventure-a1-walk-arena-20261105-2111` (PR #146), nicht auf main.

Die isolierte Neon-City-Arena erhält eine erhöhte, tatsächlich kollidierende Sprungplattform (StaticBody3D, BoxShape3D, Mesh) und statt der starren Kamera einen SpringArm3D mit Kollisionsabstand. Die unabhängige Lauf-/Touch-Steuerung und alle Runner-Dateien bleiben unverändert. Ein neuer Headless-Test lädt die Szene, prüft Bodenlandung, Plattformkollision, SpringArm, Sprunggeschwindigkeit und Touch-Bewegung.

## Akzeptanzkriterien
- Die Plattform besitzt eine reale Kollisionsform und ist in der Arena sichtbar.
- Kamera folgt dem CharacterBody3D mit SpringArm3D statt starrer Distanz.
- Laufkörper landet, springt und reagiert auf die separate Touch-Bewegung.
- Kein Eingriff in `world.gd`, `touch_gestures.gd`, Runner-Quiz, vier Welten, Bosse, Power-ups, Archive.
- Erst nach erfolgreichem Godot-Import, Test, Webexport, Render- und Geräte-QA integrations-/releasefähig.

## Tatsächliche Prüfung
GitHub-Quelltext auf dem A1-Branch gelesen und Änderungen erfolgreich committed. Neuer Test: `godot --headless --path godot --script res://adventure/adventure_a1_physics_test.gd`. **Nicht ausgeführt:** Godot-Import, Headless-Physiktest, 16:9-/19.5:9-Renderbilder, Webexport, Pages, iPhone-Safari. Der Test ist ein Prüfauftrag, kein behaupteter Erfolg. Ohne diese Abnahmen kein Merge und kein Skyway-Release.

## Änderungen
- `c3fb8069256650ed59c0f23f42787b1c3dd4ff77`: Plattform und SpringArm-Kamera
- `3ae54903fc2f0dd2b6abcfe105716aa9c51c0651`: Headless-Physiktest
- PR #146: https://github.com/mtothek0703/learnquest-unity-web/pull/146

## Nächster Schritt
Godot 4.4.1 Test/Import tatsächlich ausführen, eventuell auftretende Szene-/Physikfehler beheben, Kamera auf Smartphone-Querformat rendern, dann Checkpoint und kontrollierten Race-Übergang integrieren. Experimentelle Figur PR #111 bleibt getrennt.
