# LearnQuest Adventure – 07.11.2026, 07 Uhr – Arena-Respawn

## Ausgangslage
Primary-GitHub-Konto mtothek0703 (michael_kohler1@yahoo.de), Repository mtothek0703/learnquest-unity-web und bestehender DRAFT PR #157 geprüft. main beim Vergleich: 3117869390c6f3dff6409bfde1f64c2d184b0853; Branch 45 Commits voraus und einen hinter main. Alle vier Pflichtdokumente auf main gelesen.

## Änderung
In godot/adventure/neon_walk_player.gd wird der lokale spawn_point beim Respawn jetzt über den Parent in globale Koordinaten transformiert. Die in der echten Runner-Session weit verschobene Neon-Arena schickte den Spieler sonst beim Absturz an den Weltursprung statt zum lokalen Checkpoint. Kein Eingriff in Runner-Touch, Quiz, Power-ups, Bosse, Archive oder andere Welten.

## Akzeptanzkriterien
- Nach Unterschreiten der Fallgrenze steht die Spielfigur wieder beim lokalen Arena-Startpunkt, auch wenn die Arena weit vom Weltursprung platziert ist.
- Standalone-Arena am Ursprung bleibt kompatibel.
- Rückkehr-/Missions- und Robotertests bleiben unverändert ausführbar.

## Tatsächliche Prüfungen
- GitHub-Dateien und bestehende Bridge-Testfälle gelesen; neue Assertion für den realen verschobenen Arena-Ursprung in res://adventure/adventure_bridge_test.gd ergänzt.
- GitHub-Commit der Codeänderung: 4b710751b03ce806e72f8ea99591b6ddeff0c1be; Test-Commit: a9b17f03c2d4333a7fdf46d57a241e96783bee29.
- Godot-Import, Headless-Test, Webexport, reale Querformat-Renderbilder und iPhone-Safari-Test wurden in diesem Durchlauf nicht lokal ausgeführt. CI des neuen PR-Heads ist abzuwarten; Test ist hinzugefügt, nicht als bestanden behauptet.

## Releaseentscheidung
PR #157 bleibt DRAFT. Kein Merge, keine neue Skyway-Version; historische Releases und Unity-Archiv unverändert. Nächster Schritt: CI für neuen Head auswerten und bei Grün die sichtbare Gehfigur und Querformat-Render-QA angehen.
