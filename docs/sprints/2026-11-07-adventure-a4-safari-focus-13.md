# LearnQuest 3D – Adventure A4: Safari focus-safe robot telegraph (2026-11-07, 13 Uhr)

## Verbindliche Basis
- Primary GitHub: mtothek0703 / michael_kohler1@yahoo.de, Repository mtothek0703/learnquest-unity-web; bestehender DRAFT PR #157, Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19` (kein neuer paralleler A1-Branch).
- Main vor Änderung: `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; Branch 64 Commits voraus, 2 hinter main. Alle vier Pflichtdateien `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md` auf main gelesen.
- Vorheriger PR-Head `6eef12a266e92fc4a141823b61cdc88e4c8ee4b7`: Godot PR validation GitHub Actions Run 42367393090 **success**. Das bestätigt ausdrücklich nicht die neuen Änderungen.

## Konkrete Änderung
- Beim Fokusverlust (z.B. Safari-App-/Tabwechsel) pausiert die Adventure-Arena ihre Kampf-Timer einschließlich laufender Roboter-Angriffswarnung; sie löscht gleichzeitig gehaltene mobile Bewegungstasten und überträgt Nullbewegung an den Gehcontroller.
- Bei Fokus-Rückkehr läuft der bestehende Encounter ab der verbleibenden Warnzeit weiter. Kein heimlicher Treffer durch eine abgelaufene Warnung während einer inaktiven Seite.
- Runner-Eingaben, drei Quizfragen, vier Welten, Mission, XP, Bosskämpfe, Power-ups, alte Skyway-Builds und Unity-Archiv nicht geändert.

## Akzeptanzkriterien und Prüfungen
- [x] Fokusverlust setzt Pause und löscht mobile Bewegungsachse (Codeänderung committed).
- [x] Regressionstest im `res://adventure/adventure_bridge_test.gd` ergänzt: Fokusverlust, eingefrorener Warning-Timer, Fokus-Rückkehr.
- [ ] Neuer Godot-4.4.1-CI-Lauf für aktuellen Head erfolgreich; **noch nicht nachgewiesen**.
- [ ] Echte iPhone-Safari-Tabwechsel und Touch-Gesten geprüft; nicht ausgeführt.
- [ ] Godot-Renderbilder 16:9/19.5:9, Webexport, Archivschutz, Pages HTTP-200; nicht ausgeführt, kein Merge/Release.

## Commits
- `97951c8743461298d8ac4eae8ee5410f19c54f30`: Focus-safe Gameplay.
- `7834e703c20347f804b89ded32afbb5889b7efef`: Bridge-Regression.

## Nächste Schritte
Neue CI für diesen Head prüfen und bei Fehlschlag reparieren; danach bestehende lizenzierte Figur ohne Board in den Gehmodus integrieren und echte Querformatbilder/Touch auf Gerät abnehmen. Main-Divergenz vor Merge sauber auflösen. PR #157 bleibt DRAFT; Charakter-PR #111 bleibt unabhängig.
