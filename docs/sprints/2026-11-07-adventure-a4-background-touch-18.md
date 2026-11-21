# LearnQuest Adventure A4 – queued Safari touch events (07.11.2026, 18 Uhr)

## Ausgangslage
Primary GitHub: mtothek0703 / michael_kohler1@yahoo.de; Repository mtothek0703/learnquest-unity-web; bestehender DRAFT PR #157, Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`. Main `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; Vergleich vor dem Sprint: 79 voraus / 2 hinter main. Alle vier Pflichtdokumente auf main gelesen. Vorheriger PR-Head `f131a3d71744140962548e34e936b9d071c2612e`: Godot PR validation Actions #42390493786 erfolgreich.

## Tatsächliche Änderung
- `godot/adventure/neon_walk_testbed.gd`: Mobile SPRUNG-Schaltfläche ruft einen Fokus-geprüften Handler auf. `_sync_axis()` verwirft nach Fokusverlust nachträgliche Touch-Richtungseingaben, statt sie beim Wiederaufnehmen des Spiels zu übernehmen.
- `godot/adventure/adventure_bridge_test.gd`: Integrationstest simuliert nach Fokusverlust reale Button-Signale für RECHTS und SPRUNG; verlangt weiterhin Null-Bewegung und keinen wartenden Sprung.
- Gameplay-Commit `473eb8d1f857e069b32aee1b60505b14e25231d2`; Test-Commit `331e9deeb3ff9be687d1281281ee76dfa158f0dc`.

## Akzeptanzkriterien
1. Touch-Richtung und Sprung nach Fokusverlust bleiben verworfen; bei Fokuswiederkehr kein verzögerter Sprung.
2. Normale mobile Bewegung/Sprung vor Fokusverlust bleiben erhalten.
3. Drei Pflichtfragen, Runner-Touch-Gesten, 3 Kristalle, 2 Schalter, Roboter, Portal und einmalige XP-Vergabe unverändert.
4. Godot-Import und Headless-Bridge-Test müssen für neuen Head in CI erfolgreich sein.

## Tatsächlich ausgeführte Prüfungen / Grenzen
- GitHub Primary-Kontozuordnung, Branch, main und Pflichtdokumente über GitHub-Connector gelesen.
- CI-Erfolg ausschließlich für den vorherigen Head `f131a3d` geprüft (Actions #42390493786).
- Neue Testlogik committed, **nicht lokal mit Godot ausgeführt**; neuer CI-Erfolg noch nicht nachgewiesen.
- Kein echter Godot-Render, kein 16:9-/19.5:9-Bildvergleich, kein iPhone-Safari-Gerätetest, kein Webexport, kein Merge, kein Release.
- DRAFT #157 bleibt DRAFT; PR #111, #133, #144, Skyway-Archive und Unity-Archiv unangetastet.

## Nächster sicherer Schritt
CI des neuen PR-Heads prüfen und ggf. reparieren. Danach lizenzierte Bestandsfigur statt Kapsel im Gehmodus verwenden und reale Querformat-Renderbilder/Device-QA durchführen; keine Freigabe ohne die Release-Gates.
