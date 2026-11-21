# LearnQuest Adventure Sprint – 2026-11-10 03:12 CET

## Ziel und sichtbarer Qualitätsnachweis
Die bisherige PR-CI lieferte zahlreiche Runner-Renderbilder, aber **keine tatsächlichen Spielkamera-Aufnahmen der begehbaren Neon-City-Arena mit dem 16-Bone-Blender-Helden**. Dieser Sprint ergänzt einen reproduzierbaren Capture-Test für den echten Adventure-Szenenbaum statt einen weiteren ungeprüften Grafik-Patch.

## Änderung
- `godot/adventure/adventure_visual_capture_test.gd` lädt `neon_walk_testbed.tscn`, prüft CharacterBody3D, echte Kamera, Skeleton3D und importierten AnimationPlayer.
- Erzeugt sechs **tatsächlich von Godot gerenderte** In-Game-Aufnahmen: Idle/Walk/Jump bei 1280×720 und 1170×540. Die Animationspositionen sind reproduzierbare Timeline-Samples, **keine** Abnahme der Übergangsanimationen.
- `.github/workflows/godot-pr-check.yml` erzwingt sechs PNGs und archiviert sie als `learnquest-adventure-walk-hero-in-game`. Kein Release, keine Änderungen an Runner, Gameplay oder alten Skyway-Archiven.

## Akzeptanzkriterien
1. CI-Import und bestehende Gameplay-/Adventure-/Rig-Tests grün.
2. Echter Adventure-SceneTree mit skinnierter Figur, Animation und Spielkamera lädt.
3. Sechs PNGs im GitHub-Actions-Artefakt, exakte Auflösungen und visuell auswertbare Idle-/Walk-/Jump-Ansichten.
4. Danach **manuelle visuelle Prüfung** von Silhouette, Proportionen, Mesh-Clipping, Beleuchtung, Kamera und HUD; erst dann modellieren/polieren. Echte iPhone-Safari-FPS/Touch-QA separat.

## Tatsächlich geprüft
- Primary-Konto `mtothek0703 / michael_kohler1@yahoo.de`, Repository und Branch geprüft.
- Main `46e899a84c500243274badf71255bb2afec3186b`; vier vorgeschriebene Dokumente auf main gelesen.
- PR #157 vor Änderung: `1e82f71`, vollständige CI #42718808092 SUCCESS; drei Commits hinter main.
- PR #160 vor Änderung: `dc5be9f`, vollständige CI #42734105793 SUCCESS; Blender-Portal noch **nicht** live.
- Neuer Capture-Code `c67fe358`, Workflow `f2c0ee48`. **Neue CI und echte PNG-Bildprüfung zum Zeitpunkt dieses Protokolls noch nicht bestätigt**. Keine lokal ausgeführten Godot-Tests, kein iPhone-Test.

## Risiko und nächste Schritte
Wenn der neue CI-Job scheitert, zuerst dessen Log/Rendering korrigieren. Danach Artefaktbilder öffnen, tatsächliche Mängel benennen und **eine** zusammenhängende, sichtbare Verbesserung in PR #157 vornehmen. PR #160 getrennt visuell kontrollieren; kein Merge/Release ohne Qualitätsgates.
