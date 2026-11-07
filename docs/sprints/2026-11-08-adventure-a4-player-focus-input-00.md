# LearnQuest A4 – Walking CharacterBody focus-input guard (2026-11-08 00:00 CET)

## Basis und Schutz
Primary GitHub mtothek0703 / michael_kohler1@yahoo.de, Repository mtothek0703/learnquest-unity-web, DRAFT PR #157, Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`. Main-Basis `46bfea3ecbfa4db8cc755df8d7fab201706d8059` (Branch 94 ahead, 2 behind vor Änderung). Die vier Pflichtdokumente wurden auf main gelesen. Keine Änderung am Runner, Quiz, bestehenden Skyway-Builds, Unity-Archiv oder Charakter-PR #111.

## Implementierung
`godot/adventure/neon_walk_player.gd`: Eigener Fokus-Input-Schutz des CharacterBody3D. Während Safari-/Fenster-Fokusverlust werden verspätete SPACE-Tasten, mobile Sprungaufrufe und Bewegungsachsen ignoriert; beim Fokusgewinn werden Eingaben neutralisiert. Ergänzt den bereits vorhandenen Schutz der Arena/HUD-Ebene.

## Akzeptanzkriterien
- Keine wartende Sprungaktion oder mobile Bewegungsachse nach Fokuswechsel.
- Normale Eingaben bleiben nach Rückkehr möglich.
- Runner-Touch und Race-Quiz bleiben unverändert.

## Tests und Nachweis
Regression in `res://adventure/adventure_bridge_test.gd` erweitert: Fokusverlust am CharacterBody, SPACE, mobile_jump und set_mobile_move, danach Fokusgewinn und Nullzustand. Der Testcode wurde committed, **nicht lokal ausgeführt**; neuer GitHub-CI-Erfolg ist vor einer Freigabe separat zu prüfen. Keine Aussagen zu realen iPhone-Tests, Webexport, FPS oder Renderabnahme.

Gameplay-Commit: `825b93776584c46949467069987ce6b139a72689`; Test-Commit: `c8e27f724827875fffbbb628874965b7fbb4c1ca`. PR #157 bleibt DRAFT; kein Merge oder Release.

## Nächster Schritt
PR-CI des neuen Heads prüfen, ggf. Fehler korrigieren, dann lizenziertes vorhandenes Rider-Asset für die Laufansicht untersuchen und sicher einbinden. 16:9-/19.5:9-Renderbilder und echte iPhone-Safari-QA bleiben offen.
