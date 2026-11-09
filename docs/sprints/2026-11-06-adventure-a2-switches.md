# Adventure A2 – Neon City: zwei Schalter (06.11.2026, 02:14 CET)

## Ausgangslage
Primary-GitHub-Konto `mtothek0703 / michael_kohler1@yahoo.de` bestätigt. Repository `mtothek0703/learnquest-unity-web`; `main` auf `0e01246620d33a9afcbb617152748adac4402993`. Die vier verbindlichen Richtlinien/Roadmap-Dateien wurden auf `main` gelesen. Adventure-Branch `feature/adventure-a1-walk-arena-20261105-2111` war 22 Commits vor und 0 hinter main. PR #146 bleibt DRAFT.

## Code
- Zwei eigenständige `Area3D`-Schalter im Neon-City-Prototyp, einer auf der erhöhten Plattform.
- Nur explizite Interaktion über Taste E oder getrennten mobilen AKTION-Button; Reichweitenprüfung (2,2 m), einmalige Aktivierung pro Schalter.
- `adventure_mission.gd` speichert Schalter-IDs und schaltet die Portal-Voraussetzung erst bei drei Kristallen **und** zwei Schaltern frei. Belohnungen/XP und Runner unverändert.
- Godot-Regression `adventure_switch_test.gd` für Duplikate, Voraussetzungen und Reset.
- Ressourcenblöcke der Arena vor Szenenknoten sortiert und `load_steps` angepasst.

## Akzeptanzkriterien
1. E/AKTION aktiviert nur einen Schalter in Reichweite, nicht wiederholt.
2. Zweiter Schalter erfordert Erreichen der Plattform.
3. Portal-Voraussetzung bleibt gesperrt bis 3/3 Kristalle und 2/2 Schalter.
4. Reset löscht alle Missionsziele; Runner-Touchsteuerung bleibt unabhängig.

## Tatsächlich ausgeführte Tests
- GitHub-Branch-Vergleich und Quelltextprüfung durchgeführt.
- **Kein Godot-Import, kein Headless-Test, kein Webexport, keine echten 16:9/19.5:9-Renderbilder, kein iPhone-Safari-Test.** Code daher noch nicht abgenommen.
- Noch **kein funktionales Portal**, keine XP-Integration, keine Runner-Übergänge. Kein Merge/Release und keine Skyway-URL erzeugt.

## Nächste Schritte
Godot 4.4.1 Import und `adventure_switch_test.gd`, `adventure_crystal_test.gd`, Physiktests ausführen; visuell Schalter und Touchflächen überprüfen, gegebenenfalls korrigieren; dann sichtbares, bedingt öffnendes Portal implementieren. PR #111 bleibt separat DRAFT.
