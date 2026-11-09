# LearnQuest Adventure – 09.11.2026 21:13 CET

## Ziel und Änderung
Neon-City-Gehkamera in PR #157: Die Follow-Kamera interpoliert bei freier Sicht auf das Ziel (9/s), statt bei jedem Physiktick unmittelbar an die neue Zielposition zu springen. Bei einem Raycast-Treffer wird die sichere Kameraposition **sofort** gesetzt, damit die Glättung nicht durch Gebäude hindurchführt. Runner-Kamera und Runner-Gesten bleiben unverändert. Gameplay-Commit: `394207a823887c9fbe1f9d9abbdc99c62de94b71`.

## Verifizierte Ausgangslage
Primary GitHub `mtothek0703` / `michael_kohler1@yahoo.de`; Repo `mtothek0703/learnquest-unity-web`; bestehender Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`. Vier Pflichtdokumente auf main gelesen. Main `46e899a84c500243274badf71255bb2afec3186b`, PR #157 vor Änderung `8066454e78f4d9788da7aa48b8cabd3a17feb420`, 218 ahead / 3 behind. Dessen PR-Godot-CI `42685084577` erfolgreich. Blender-Portal PR #160 Head `7d5fd8cfe0f0eb65d42bd2dd11bd876551a73906`, Godot-CI `42681487769` erfolgreich; **nicht live bestätigt**.

## Akzeptanzkriterien
- Freie Kamerafahrt ohne abrupte Positionssprünge; Hindernisse weiterhin unmittelbar berücksichtigt.
- Spieler bleibt im Bild; keine Geometrie-Clips oder Kamera-Ruckler beim Sprung/Respawn.
- Reale Godot-Spielkamera-Screenshots 1280x720 und 1170x540; manuelle iPhone-Safari-FPS/Touch-QA.
- Kein Runner-/Archiv-/Release-Eingriff.

## Tatsächliche Prüfungen und offene Punkte
GitHub-API: Account, Branch, Main-Vergleich, PR-Head und bisherige CI-Ergebnisse geprüft; Quelltext der Kamera gelesen. **Keine** lokale Godot-Ausführung, keine neuen Screenshots, keine manuelle iPhone-Prüfung und noch kein neuer CI-Erfolg für diesen Commit. Die visuelle Qualität ist damit **nicht abgenommen**. PR bleibt DRAFT, kein Merge/Release. Nächster Schritt: neue CI prüfen, Godot-Kamerabilder beider Querformate tatsächlich vergleichen und bei Clipping/Respawn-Rucklern korrigieren; danach Rig-/Animation-Gesamtbild des Blender-Hero prüfen. PR #160 unabhängig halten.
