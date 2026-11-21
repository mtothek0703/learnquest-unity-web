# LearnQuest 3D – Adventure A3 Checkpoint, 07.11.2026 14 Uhr

## Ausgangslage und Identität
Primary GitHub `mtothek0703` (`michael_kohler1@yahoo.de`), Repository `mtothek0703/learnquest-unity-web`, bestehender DRAFT PR #157, Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`. Vier Pflichtdokumente auf main vor Änderung gelesen. Main und PR vor Änderung geprüft. Vorheriger Head `f0d0c3d4b68373cdb04141cf5371f043d0c432f8`; dessen PR-CI-Lauf 42371977864 erfolgreich.

## Änderung
Beim Verbrauch der letzten lokalen Roboterenergie wurde der Spieler bisher nur teleportiert; seine Fall-/Seitwärtsgeschwindigkeit und gehaltene mobile Eingaben blieben aktiv. Nun wird die vorhandene `player.respawn()`-Routine aufgerufen und zusätzlich die Touch-Pressed-Map sowie `mobile_axis` gelöscht. Dadurch beginnt der Checkpoint ohne alte Bewegung. Keine Änderungen an Runner, Quiz, Welten, Bossen, Power-ups oder Skyway-Archiv.

## Akzeptanzkriterien und Tests
- Checkpoint liegt am lokalen Arena-Spawn; Geschwindigkeit = 0 und mobile Achse = 0; lokale Energie = 3.
- Regression in `res://adventure/adventure_bridge_test.gd` ergänzt: simuliert Restenergie 1, Treffer, Bewegungsimpuls und aktive Touch-Eingabe, prüft Checkpoint-Reset.
- Code-Commit `72521bb9364eab9d486676c61e0e7e2203b8db9f`; Test-Commit `afe1c840209de7297a9b618e5d55bb4bfd749f3b`.
- Tatsächlich ausgeführte Tests für diese Änderung: **keine lokalen Godot-Tests**; neue PR-CI muss nach diesem Commit erst überprüft werden. Der erfolgreiche CI-Lauf 42371977864 gehört ausschließlich zum vorherigen Head.
- Echte 16:9/19.5:9-Renderbilder, iPhone-Safari-QA und Webexport/Release-Abnahme weiterhin offen. PR bleibt DRAFT; kein Merge oder Release.

## Nächster Schritt
CI auf neuem Head auswerten, bei Fehlern reparieren; anschließend lizenzierte Spielfigur/Board-Trennung untersuchen und reale Querformat-Renderbilder erstellen.
