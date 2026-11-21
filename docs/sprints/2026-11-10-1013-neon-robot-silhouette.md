# LearnQuest 3D – 10.11.2026, 10:13 CET – A3 Neon City robot visual

## Ausgangslage und Kontoschutz
GitHub Primary mtothek0703 / michael_kohler1@yahoo.de, Repository mtothek0703/learnquest-unity-web, Branch feature/adventure-a1-walkable-neon-testbed-20261106-19 geprüft. Main 46e899a84c500243274badf71255bb2afec3186b, Adventure 236 ahead / 3 behind, Blender 34 ahead / 0 behind zum Prüfzeitpunkt. Alle vier Pflichtdokumente auf main gelesen. Vorherige Godot PR validation: #157 run 42767834099 SUCCESS, #160 run 42734105793 SUCCESS.

## Änderung
A3-Trainingsroboter in godot/adventure/neon_walk_testbed.gd erhält innerhalb seines bestehenden MeshInstance3D eine deutlich lesbare Silhouette: Kopf, leuchtendes Visier, Schultern, zwei Arme, zwei Beine und Brustlicht. Nur drei wiederverwendete Materialien, einfache mobile BoxMesh-Geometrie, keine zusätzlichen CollisionShape3D, keine Änderung an ROBOT_RANGE, Schaden, Warnring, Touch, Runner oder Quiz. Das bestehende Robotermesh bleibt Parent, sodass die vorhandene Angriffswarn-Skalierung weiter alle Teile erfasst. Der bereits vorhandene Blender-Held wird nicht verändert.

## Akzeptanzkriterien
- Alle neun benannten Roboterdetails sind in der tatsächlichen Arena instanziiert.
- Keine neuen Kollisionskörper am Roboter; 3-m-Warnring und Trefferlogik unverändert.
- Headless Adventure Bridge und übrige Godot-PR-CI bestehen.
- Echte Godot-Bilder 1280x720 und 1170x540 belegen lesbare Figur und Roboter im Zusammenhang; erst dann visuell abnehmen.
- iPhone Safari Querformat und FPS separat auf realem Gerät prüfen.

## Commits / Tests
Gameplay: 92d3904a07691a938d9eb1e8bad2ccc63b6585bc.
Headless-Regression erweitert: d3e59ccdcc19c6c8dfd0bca5d72273b24b240381.
Ausgeführt: Repo-/Branch-/Main-Vergleich, Datei-/Szenencodeinspektion, bestehende CI-Ergebnisse des vorherigen Heads abgefragt. **Neuer CI-Head noch nicht bestätigt**, keine lokale Godot-Ausführung, keine neuen Renderbilder, kein Webexport, kein iPhone-Test. Keine Releasefreigabe.

## Blender-Spur
PR #160 bleibt unabhängig DRAFT auf dc5be9f, vorherige vollständige CI erfolgreich. Bonusportal nicht als live bestätigt; kein Merge, kein Release. PR #111 bleibt unabhängig.

## Nächster Schritt
Neue CI für diesen Head prüfen; reale 16:9-/19.5:9-Spielkameraaufnahmen mit Held, Roboter und Portal vergleichen. Falls die Silhouette zu grob oder übergroß ist, in diesem bestehenden PR mit echten Godot-Bildern verbessern. Danach Blender-Assets und Mission/Portal als kohärente Neon-City-Szene abstimmen; alte Skyway-Versionen und Unity-Archiv unangetastet lassen.
