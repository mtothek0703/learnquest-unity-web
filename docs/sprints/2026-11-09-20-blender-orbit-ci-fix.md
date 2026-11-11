# LearnQuest Blender CI regression – 2026-11-09 20:13 CET

## Ausgangslage
Primary-Konto mtothek0703 (michael_kohler1@yahoo.de), Repository mtothek0703/learnquest-unity-web. Die vier Pflichtdokumente wurden auf main gelesen; main `46e899a84c500243274badf71255bb2afec3186b`. Adventure PR #157 Head `2232ad47ae4980c69b592fb8cfe6388657747d04` mit erfolgreichem Godot-PR-Lauf `42678211656`. Blender PR #160 Head vor Änderung `c2ab59c0d05f0dc10d6fa659f35f7e10d911a854`, Godot-Lauf `42681196329` fehlgeschlagen.

## Fehler und Änderung
Job `129375853350` meldete `BLENDER PORTAL TEST FAILED: keyframed orbit did not visibly move` im Test `res://blender_portal_test.gd`. Der Test prüfte die Position nach genau 1.0 Sekunde; dies kann bei einer periodischen GLB-Animation auf den Ausgangspunkt fallen. Der Test wertet nun vier Zwischenpunkte bei 20/40/60/80 % der tatsächlichen importierten Clip-Länge aus und prüft die maximale Verschiebung. Fehlende Clips, fehlende Shards und echte fehlende Bewegung bleiben Fehler. Commit `6db7020dc11dc5e441bdd512484a3ea09e530bcd`.

## Akzeptanz und tatsächliche Tests
Akzeptanz: Importierter Clip mit tatsächlicher räumlicher Bewegung besteht den Regressionstest, statische Animation nicht; übrige Runner-Mechanik bleibt unverändert. Ausgeführt: GitHub-CI-Logdiagnose des fehlgeschlagenen Laufs; kein lokaler Godot-Test, keine neue CI-Bestätigung für den Fix, keine visuellen Bilder geprüft. Godot-Import/Webexport und reale 16:9-/19.5:9-Renderabnahme für neuen Head offen. iPhone-Safari-Touch/FPS weiterhin offen.

## Release
PR #160 bleibt DRAFT; nicht in Live-Spiel veröffentlicht. PR #157 unverändert DRAFT. Keine historischen Skyway-Builds, Unity-Dateien oder main verändert. Nächster Schritt: CI auf Fix-Head prüfen; falls weiter fehlgeschlagen, importierte Animations-Tracks und echte Shard-Transforms untersuchen. Danach tatsächliche Vorher-Nachher-Bilder bewerten, bevor irgendeine Freigabe erwogen wird.
