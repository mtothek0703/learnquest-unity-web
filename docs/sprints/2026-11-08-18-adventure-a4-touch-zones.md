# LearnQuest A4 – compact landscape touch zones (08.11.2026, 18 Uhr)

## Vorprüfung
Primary GitHub `mtothek0703` (michael_kohler1@yahoo.de), Repository `mtothek0703/learnquest-unity-web`, bestehender DRAFT-Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19` geprüft. Alle vier Pflichtdokumente auf main gelesen. Main `46bfea3ecbfa4db8cc755df8d7fab201706d8059`, vorheriger PR-Head `a0bf79bf6af43f611e50c9f9de7a7181814991fd`, 132 Commits voraus, zwei hinter main. Vorheriger Head: GitHub PR-CI 42499010133 erfolgreich.

## Konkrete Änderung
Rechte Touch-Aktionen in Neon City auf kleinen Querformat-Höhen entzerrt: ANGRIFF in linke Aktionsspalte (-255 bis -117 px vom rechten Rand), ABWEHR tiefer bei 86% Bildschirmhöhe, SPRUNG in rechter Spalte. INTERAKTION bleibt oben rechts. Keine Änderung an Runner-Gesten, Mission, drei Eingangsfragen, vier Welten, Power-ups oder historischen Builds.

## Akzeptanzkriterien
Vier Aktionsbuttons vorhanden und am rechten Rand verankert. Bei 390px Querformat-Höhe überschneiden sich ihre Touch-Rechtecke nicht und ragen nicht unten aus dem Bild. Andere Runner-Eingaben bleiben unverändert.

## Tatsächlich ausgeführte Tests
Quellcode und Anker/Offsets überprüft; Regression in `godot/adventure/adventure_bridge_test.gd` erweitert, die bei 390px Höhe alle vier Rechtecke auf Überlappung und vertikale Grenzen prüft. **Die neue Godot-Regression wurde in diesem Durchlauf nicht lokal ausgeführt.** CI für neuen Head steht zur Prüfung aus. Keine echten Renderbilder, iPhone-Safari-QA, FPS-Messung, Godot-Webexport oder Pages-Release.

## GitHub / Ergebnis
Gameplay `9e7a8e417f9470e186525545216da7aa83853dee`, Regression `c623ed8836b2b42a30b7f1fd96d05c41ddbe85e5`, PR #157 bleibt DRAFT. Keine Merge-/Release-Freigabe. Nächster Schritt: CI für neuen Head prüfen und reale 16:9-/19.5:9-HUD-Renderbilder erstellen; danach bestehendes Rider-Asset isoliert prüfen, ohne den Runner zu verändern.
