# LearnQuest Adventure A3 – Roboter-Grundmechanik (07.11.2026, 00 Uhr)

## Ausgangslage und Kontoschutz
Primary-Konto mtothek0703 (michael_kohler1@yahoo.de), Repo mtothek0703/learnquest-unity-web, bestehender DRAFT PR #157. main bei Sprintbeginn: 3117869390c6f3dff6409bfde1f64c2d184b0853. Branch zu Beginn 22 Commits voraus, 1 Commit hinter main; kein neuer paralleler Branch. LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md und docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md auf main gelesen. Vorheriger PR-Head e8cde84, Godot-PR-CI 42303781778 erfolgreich.

## Gameplay
Neon-City-Arena hat einen sichtbaren Trainingsroboter. In 3m Reichweite löst er eine zeitlich begrenzte Angriffswarnung aus; danach folgt eine Pause, ohne bislang Schaden anzurichten. Die separate mobile ANGRIFF-Taste und Desktop F erlauben zwei Nahbereichstreffer, die den Roboter deaktivieren. Fernangriffe und wiederholtes Treffen eines deaktivierten Roboters sind gesperrt. reset_mission setzt auch den Gegner zurück. Bestehender Runner, drei Fragen, vier Welten, vier Power-ups, alte Builds und Unity-Archiv nicht geändert.

## Akzeptanzkriterien und Tests
- Robot existiert in der Arena und zeigt Warnung an; Warnung ist noch kein echter Schadensangriff.
- ANGRIFF nur in Reichweite, nach zwei Treffern deaktiviert; Reset reaktiviert ihn.
- adventure_bridge_test.gd prüft Fernangriff, zwei Treffer, Duplikatsperre und Reset zusätzlich zur bisherigen Übergangs-/Missionstestmatrix.
- Tatsächlich ausgeführt: GitHub-API-Leseprüfung der vier Main-Dokumente, PR-Metadaten, Branch-Vergleich, bisheriger CI-Lauf. Neue Godot-Tests wurden in diesem Lauf nicht lokal ausgeführt. Neuer CI-Lauf für die aktuellen Commits noch abzuwarten.
- Kein Webexport, keine Renderbilder, keine iPhone-Tests, kein Merge, kein Release.

## Ergebnis / nächste Schritte
PR #157: Gameplay-Commit 87d87aa, Cooldown-/Reset-Fix 992736a, Test-Commit 2b15a1a. Nächster Sprint: aktuellen CI-Lauf kontrollieren und eventuelle Parser-/Gameplay-Fehler beheben; danach echte ausweichbare Robot-Attacke mit sichtbarer Treffer-/Abwehrreaktion, gesonderter Touch-Qualität und vorhandener Spielfigur statt Kapsel. Bis zur Abnahme DRAFT.
