# Adventure A1 – isolierter Neon-City-Laufprototyp (05.11.2026, 21:11 CET)

## Ausgangslage
Primary GitHub mtothek0703 / michael_kohler1@yahoo.de, Repo mtothek0703/learnquest-unity-web; main 0e01246620d33a9afcbb617152748adac4402993. Vier verbindliche Richtlinien/Roadmap von main gelesen. Frischer Branch feature/adventure-a1-walk-arena-20261105-2111. A0 PR #145 ist DRAFT und nicht in main; dieser Prototyp hängt nicht davon ab.

## Änderung
Neue isolierte res://adventure/adventure_area.tscn mit sichtbarem Boden, Kollisionsboden, CharacterBody3D samt Kapselkollision und sichtbarem Platzhaltermesh, provisorischer Third-Person-Kamera und eigenständigem Touch-Drag-Feld plus Sprungtaste. Bewegung über Pfeiltasten, Beschleunigung, Gravitation, Springen, Respawn unter -8 m. Kein Runner-Script geändert, keine Session-/Quiz-Integration. Die sichtbare Figur ist ausdrücklich noch ein Platzhalter, nicht die bestehende lizenzierte Figur.

## Akzeptanzkriterien
- Szene lädt unter Godot 4.4.1 und Walker kollidiert mit Boden.
- Bewegung mit Pfeiltasten und linkem Touch-Drag; rechts SPRUNG; Touch-Ende stoppt Bewegung.
- Walker springt und landet; fällt er unter die Arena, wird er zurückgesetzt.
- Keine Regression im Runner, da neue Szene nur separat gestartet wird.
- Weitere A1-Arbeit: bestehende Figur einbinden, echte Third-Person-Kamerakollision, Plattformen, iPhone-Querformat-QA, Steuerungsprüfung.

## Tests und Grenzen
Strukturtest hinzugefügt: godot --headless --path godot --script res://adventure/adventure_walk_test.gd.
**Nicht ausgeführt**: Godot-Binary in dieser Laufzeit nicht installiert; daher kein erfolgreicher Import-/Gameplay-/Webexport-Nachweis. Kein echter 16:9/19.5:9-Render, keine iPhone-FPS-/Touch-Abnahme, keine Archivschutz-/Pages-Abnahme. Noch kein vollständiger spielbarer Vertical Slice. Keine Merge- oder Release-Freigabe.

## Spur B
PR #111 bleibt DRAFT; visuelle 65-Bone-Abnahme fehlt. Kamera-PRs #133/#144 nicht übernommen.
