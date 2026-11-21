# LearnQuest Adventure A3 – Guard cooldown (07.11.2026, 04 Uhr)

## Ausgangslage
Primary-GitHub-Konto mtothek0703 (michael_kohler1@yahoo.de), Repository mtothek0703/learnquest-unity-web, vorhandener DRAFT-Branch feature/adventure-a1-walkable-neon-testbed-20261106-19 geprüft. Alle vier Pflichtdokumente auf main gelesen. Main SHA 3117869390c6f3dff6409bfde1f64c2d184b0853; Branch beim Vergleich 35 Commits voraus, 1 hinter main. Letzter vorheriger PR-Head 2b24dbb8a2f06e2dca0abcba2612ac8cdb9fda6c: Godot PR validation Run 42328213427 erfolgreich.

## Änderung und Akzeptanz
Vorher konnte wiederholtes Tippen auf ABWEHR den 0,8-Sekunden-Schutz unbegrenzt verlängern. Jetzt startet eine Abwehr nur ohne aktive Cooldown-Sperre; Schutz 0,8 Sekunden, erneute Abwehr erst nach 2,0 Sekunden. Der Roboter kann nach dem Warnfenster wieder treffen, wenn die Figur weder ausweicht noch im aktiven Schutzfenster ist. Mission, Portal, Runner-Energie und historische Builds bleiben unverändert.

## Tests
Codeprüfung: neue Cooldown-Variable wird in _physics_process heruntergezählt und bei reset_mission zurückgesetzt. Integrationstest adventure_bridge_test.gd erweitert: wiederholtes guard_robot während der Sperre darf das Schutzfenster nicht erneuern. Testcode committed, aber **für diese neuen Commits noch kein erfolgreicher CI-Lauf nachgewiesen**; Godot-/iPhone-/Webexport-Abnahme offen.

## Commits und Status
Gameplay 7eb87da45049455a6d6b7760737d21c1865d2215; Test 3c62122766c9f60c24c5414c6d1915ef26f3895d. DRAFT PR #157 bleibt offen. Kein Merge, kein Skyway-Release. Nächster Schritt: aktuelle PR-CI prüfen und mobile Querformat-Buttons auf echten Renderbildern überprüfen.
