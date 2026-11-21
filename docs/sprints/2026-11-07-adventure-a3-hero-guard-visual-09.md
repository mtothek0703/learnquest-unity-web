# Adventure A3 – sichtbare Abwehr an der Spielfigur (07.11.2026, 09 Uhr)

## Änderung
Im bestehenden DRAFT PR #157 erhält die Kapsel-Spielfigur der Neon-City-Laufarena ein eigenes Material. Während der aktiven 0,8-Sekunden-Abwehr leuchtet die Figur mintgrün; danach und beim Missionsreset kehrt die neutrale hellblaue Farbe zurück. Die bestehenden Runner-Touch-Gesten, der Runner-Charakter und alte Releases wurden nicht geändert. Keine neuen Assets oder Kosten.

## Akzeptanzkriterien
- Erfolgreiche Abwehr ist im 3D-Bereich sichtbar, unabhängig vom HUD.
- Abwehr-Farbe endet mit dem tatsächlichen Guard-Fenster, nicht erst beim nächsten Angriff.
- Missionsreset entfernt die Guard-Farbe; bestehende Roboterschaden-/Abklingzeitregeln bleiben erhalten.

## Prüfungen und Grenzen
- Vor Änderung: Primary-GitHub-Konto mtothek0703, Repository und bestehender Branch geprüft; main 3117869390c6f3dff6409bfde1f64c2d184b0853; Branch 51 Commits voraus, 1 hinter main. Alle vier Pflichtdokumente auf main gelesen.
- Vorheriger PR-Head baf173c: GitHub Actions 42350535301 abgeschlossen, conclusion success.
- Integrationstest res://adventure/adventure_bridge_test.gd um Materialfarbe bei Abwehr, Ablauf und Reset erweitert (Commit 39302a9aa09ffb0709fc67d8624e626e8b6bd087).
- **Nicht lokal ausgeführt:** Godot-Import, Headless-Test, Webexport, echte 16:9-/19,5:9-Bilder und iPhone-Safari-QA. Für die neuen Commits noch kein bestätigter CI-Erfolg. Die Assertions sind implementiert, nicht als bestanden ausgegeben.

## PR und Ergebnis
- PR #157 bleibt DRAFT, kein Merge, kein Release.
- Gameplay-Commit 3b2434b6a2168e0a479218ac2528c539736dcda4.
- Test-Commit 39302a9aa09ffb0709fc67d8624e626e8b6bd087.
- Nächster Schritt: aktuellen CI-Lauf prüfen, dann reale Querformat-Renderbilder und Figurendarstellung untersuchen. Die provisorische Kapsel muss später durch das bestehende lizenzierte Rider-Modell ersetzt werden, ohne PR #111 vorzeitig zu mergen.
