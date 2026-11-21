# LearnQuest Adventure A4 – Walking camera collision (2026-11-07, 19 Uhr)

## Ausgangslage / Identität
- Authentifiziertes Primary-Konto: `mtothek0703`, `michael_kohler1@yahoo.de` (Profil-ID 339490599); Repository `mtothek0703/learnquest-unity-web`.
- Alle vier Pflichtdateien vor Änderungen auf `main` gelesen: `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md`.
- `main` vor Änderung: `46bfea3ecbfa4db8cc755df8d7fab201706d8059`. Bestehender DRAFT PR #157, vorheriger Head `3a83ac38efd9ceb6da74ab506d99edc4a3f0d5d2`; 82 Commits ahead, 2 behind main. Kein neuer A1-Branch.

## Änderung
- `godot/adventure/neon_walk_testbed.gd`: Separater Gehmodus-Third-Person-Kamerapfad mit Physik-Ray vom Fokus zur Sollposition; Spieler-RID ausgeschlossen. Bei Dach-/Wandtreffer wird die Kamera mit 0,25 m Sicherheitsabstand vor die Oberfläche versetzt. Beim Wegfall des Hindernisses kehrt sie zur ursprünglichen Position zurück. Runner-Kamera unverändert.
- `godot/adventure/adventure_bridge_test.gd`: Regression erzeugt eine reale Kollisionswand hinter der Spielfigur, prüft verkürzten Kameraabstand und die Wiederherstellung nach Entfernen der Wand.

## Akzeptanzkriterien und Evidenz
1. Kamera bleibt vor einer kollidierenden Wand hinter der Gehfigur; nach Entfernen wieder normale Distanz: **als headless Regression implementiert, Ausführung noch offen**.
2. Bestehende 3-Fragen-/Runner-/Mission-/Roboter-/Touch-Regression bleibt erhalten: **nicht erneut ausgeführt bestätigt**.
3. Godot-Import, vollständige PR-CI, Webexport und 16:9-/19.5:9-Renderbilder: **für diese Commits noch nicht bestätigt**.
4. iPhone-Safari-QA, visuelle Gesamt-Abnahme und Archiv-/Pages-Release: **nicht erfolgt**.

## Commits / Ergebnis
- Gameplay `aa554423babe375c3df890ab0ffb4fa22722349a`.
- Regression `842b5ce2636f32b5e48216aba106597841f228d8`.
- Letzter vor Änderung abgefragter CI-Lauf für Head `3a83ac3`: `42395171584` abgeschlossen, success. Dies belegt **nicht** die neuen Commits.
- PR #157 bleibt DRAFT; kein Merge und kein neues `skyway-vN/`.

## Nächster Schritt
Neuen PR-CI-Lauf prüfen, insbesondere die Kamera-Regressionsprüfung; bei Fehlschlag korrigieren. Danach lizenzierte bestehende Figur statt Kapsel in Gehmodus integrieren, echte Renderbilder beider Querformate und iPhone-Touch-QA durchführen.
