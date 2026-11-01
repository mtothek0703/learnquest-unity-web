# 2026-11-01 — Spur A: kompakter Renn-HUD für kurze Smartphone-Querformate (Kandidat)

## Ausgangslage
Pflichtdateien LEARNQUEST_SPRINTS.md und LEARNQUEST_RELEASE_POLICY.md auf main gelesen; GitHub Primary mtothek0703 verifiziert. Letzte nachgewiesene stabile Version beim Beginn dieses Sprints: Skyway V145 (main aa570902). Experimenteller 65-Bone-PR #111 bleibt DRAFT/VISUAL HOLD.

## Sichtbare Verbesserung
Das bisherige Renn-HUD konnte auf kurzen 19,5:9-Displays über vier bis sieben Zeilen wachsen und die Missionsfortschrittsleiste bei y=91 überdecken. Bei Touchscreen-Querformat mit Höhe bis einschließlich 720 Pixeln werden Renninformationen nun in exakt drei Zeilen verdichtet: (1) Leben/XP/Energie/Kombos/Distanz, (2) Welt/Runde/Ziel/Schild/Boost, (3) aktuelle Weltmission oder dringende Bosswarnung. Der bereits vorhandene ProgressBar bleibt bei y=91. Kein neuer Button und keine neue Touch-Totzone; Desktop und Portrait behalten das bisherige HUD.

## Regression
Der vorhandene Godot-Gameplay-Smoke-Test prüft alle vier Welten mit jeweils drei Textzeilen und einem Textbudget von höchstens 43 Zeichen pro Zeile, dazu die akute Neon-Bosswarnung SWEEP!. Touch-Gesten, drei Englischaufgaben, Boss- und Power-up-Regeln bleiben unverändert.

## Zusätzliche echte Renderprüfung
Der vorhandene `landscape_chase_visual_capture_test.gd` erzwingt jetzt Touchscreen-Querformat im tatsächlichen Spiel-SubViewport und prüft nach einem gerenderten Frame, ob die reale HUD-Panel-Unterkante mindestens 4 px oberhalb der Missionsleiste liegt. Die zwölf originalen Gameplay-/Kamerabilder bleiben erhalten. Dieser Test muss in der PR-CI erst erfolgreich abschließen; die Implementierung allein ist kein visueller Freigabenachweis.

## Release-Gate
- [ ] PR-Godot-Gameplay-Tests und Webexport erfolgreich
- [ ] Tatsächlich gerenderte 1280x720- und 1170x540-Bilder auf HUD/Progressbar-Überlappung geprüft
- [ ] Archivschutz grün
- [ ] Erst danach freie immutable Skyway-Version bestimmen, Release-Workflow aktualisieren und main mergen
- [ ] Main-CI, Pages und fünf HTTP-200-Builddateien sowie build.txt-SHA nachweisen

**Kein Release nur für die Versionsnummer.** Diese Änderung ist ein Kandidat, keine fertige Veröffentlichung. Alte Skyway-URLs und Unity-Archiv nicht verändern; PR #111 separat weiterführen.

## CI-Befund und Korrektur
- Erste vollständige Godot-PR-CI [41325519827](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41325519827) erfolgreich: Gameplay-Smoke und Webexport inklusive.
- Die neue echte Renderprüfung [41325682171](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41325682171) deckte einen echten verbleibenden Fehler auf: Bei **1280×720** wurde der alte lange Desktop-HUD gewählt, der die Missionsleiste überdeckte. Keine Freigabe.
- Korrektur: Touch-Querformat bis einschließlich 720px Höhe erhält jetzt das dreizeilige HUD. Erneute CI und echte Renderprüfung ausstehend.
