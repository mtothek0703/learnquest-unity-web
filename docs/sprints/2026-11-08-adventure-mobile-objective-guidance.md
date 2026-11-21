# LearnQuest Adventure Sprint – 2026-11-08, 13 Uhr

## Ausgangsstand
Primary GitHub `mtothek0703` / `michael_kohler1@yahoo.de`; Repository `mtothek0703/learnquest-unity-web`; DRAFT PR #157; vor der Änderung Head `17afe86e19b3ab6c4062bf79272b45364b2e00ca`; main `46bfea3ecbfa4db8cc755df8d7fab201706d8059` (Branch 116 ahead, 2 behind). Alle vier Pflichtdokumente wurden auf main gelesen.

## Spielbarer Schritt / Akzeptanz
Im vorhandenen Neon-City-Adventure-Vertical-Slice erhält die Laufmission eine **sichtbare zweizeilige HUD-Hilfe**: solange Ziele fehlen, Hinweise auf Kristalle/Schalter; im Interaktionsradius den konkreten nächsten Zieltyp; nach Missionsabschluss Hinweis auf Roboter oder grünes Ausgangsportal. Das HUD wird in der laufenden Arena aktualisiert. Robot-Warntext erhält eine separate Zeile. Keine Änderung an Runner-Gesten, Englischfragen, Archiv, Bossen, Power-ups oder vorhandenen Releases.

Akzeptanz: Missionshinweis ist sichtbarer Label-Text (nicht nur Mouseover-Tooltip), unabhängig vom Runner-HUD; Robot-Hinweis liegt unterhalb des Missionsbereichs; bestehende Missions- und Rückkehr-Gates bleiben unverändert.

## Tatsächlich ausgeführte Prüfung
GitHub-Dateien und Zielbranch über Primary gelesen; Änderungen an `godot/adventure/neon_walk_testbed.gd` committed. `godot/adventure/adventure_bridge_test.gd` um Regression für sichtbaren Missionshinweis erweitert. **Kein lokaler Godot-Import, kein ausgeführter Headless-Test, kein Webexport, keine echten Renderbilder und keine iPhone-QA in diesem Lauf**. GitHub Actions für den neuen Head nach Commit prüfen; Teststatus bis dahin offen.

## Commits und Status
PR #157 bleibt DRAFT. Gameplay/HUD: `0dbd25a`, `a505d25`, `d73e7fa`; Test: `4ddd4db`. Kein Merge und kein Release. Nächster Schritt: neue PR-CI prüfen; HUD bei 16:9/19.5:9 visuell abnehmen und bestehende lizenzierte Spielfigur über isolierten Adapter statt Kapsel verwenden.
