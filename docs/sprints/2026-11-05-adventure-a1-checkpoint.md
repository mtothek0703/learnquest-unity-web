# LearnQuest Adventure A1 – Checkpoint und Fall-Rückkehr (05.11.2026, 23:11 CET)

## Ausgangslage
Primary-Konto mtothek0703 / michael_kohler1@yahoo.de, Repository mtothek0703/learnquest-unity-web, PR #146, Branch feature/adventure-a1-walk-arena-20261105-2111. Main SHA vor Änderungen: 0e01246620d33a9afcbb617152748adac4402993. Vier Pflichtdokumente auf main gelesen.

## Änderung
- Neue isolierte Area3D-Checkpoint-Logik in adventure_checkpoint.gd: nur der Walker kann einen neuen Respawn-Punkt aktivieren.
- Kollisionsbasierter Checkpoint in Neon City bei (-4, 0.15, -4).
- On-foot-Controller erhält set_checkpoint() und respawn_at_checkpoint(); beim Fall werden Velocity, Jump-Wunsch und Touch-Vektor zurückgesetzt.
- Headless-Physiktest um Checkpoint-Trigger und Fall-Rückkehr erweitert.
- Runner, Touch-Gesten des Rennmodus, bestehende Welten, Quiz, XP, Skyway-Versionen und Unity-Archiv unverändert.

## Akzeptanzkriterien
1. Walker betritt Checkpoint-Area und speichert sichere Rückkehrposition.
2. Nach Unterschreiten von respawn_height erscheint Walker beim zuletzt aktivierten Checkpoint, nicht am Levelstart.
3. Bewegungs-/Sprungzustand wird beim Respawn zurückgesetzt.
4. Kein Einfluss auf den Runner, da Adventure-Szene weiterhin isoliert und nicht in die Runde integriert ist.

## Tatsächlich ausgeführte Prüfungen
- GitHub: vier Richtlinien/Roadmap aus main gelesen; Repository und PR #146 geprüft; Code auf Feature-Branch committed.
- Lokale Verfügbarkeit: command -v godot / godot4 -> GODOT_UNAVAILABLE.
- **Nicht ausgeführt:** Godot-Import, Headless-Physiktest, Webexport, 16:9-/19,5:9-Renderbilder, Archiv-/Pages-Checks, iPhone-Safari-QA. Daher keine technische Freigabe und kein Release.
- Der neue Test ist ein Akzeptanztest im Quellcode, **kein bestandener Testlauf**.

## Commits / PR
PR #146: https://github.com/mtothek0703/learnquest-unity-web/pull/146
Checkpoint-Script 8323741e; Controller 47984b47; Szene bc0c091e; Test 59104e5b.

## Nächste Schritte
Godot 4.4.1 in CI ausführen, Checkpoint-Trigger/Fall-Rückkehr prüfen, Sichtbarkeit des Checkpoints und sichere Kamera testen. Anschließend erst die Integration des Adventure-Abschnitts in den Runner nach drei Eingangsfragen planen. Kein Merge/Release ohne grüne Gates.
