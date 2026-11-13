# LearnQuest Adventure A3 – Roboter-Feedback (07.11.2026, 03 Uhr)

## Ausgangsprüfung
- Primary GitHub: mtothek0703 (michael_kohler1@yahoo.de); Repo: mtothek0703/learnquest-unity-web.
- Main: 3117869390c6f3dff6409bfde1f64c2d184b0853; bestehender DRAFT PR #157, Head vor Änderung e83bbeb0c92755d43a2a2b974ea067addc74437c.
- Alle vier Pflichtdateien auf main gelesen: LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md.
- Vorheriger Head: GitHub Actions PR-Run 42323418878 completed/success. Das ist kein Beleg für die neuen Änderungen.

## Implementierung
- Der Roboter meldet nach Angriff sichtbar TREFFER, nach erlittenem Schlag TREFFER ERHALTEN, nach rechtzeitiger Abwehr ABGEWEHRT und nach Distanz-Ausweichen AUSGEWICHEN.
- Bei Energieverlust bis null zeigt die Arena ENERGIE LEER – CHECKPOINT. Beim Missionsreset wird das Feedback geleert.
- Kein Eingriff in Runner-Gesten, Quiz, Welt-/Bosslogik, Power-ups, alte Builds oder experimentellen Charakter-PR.

## Akzeptanzkriterien
1. Ein Treffer in Reichweite, Abwehr während des Warnfensters und Ausweichen außerhalb der Reichweite erzeugen unterscheidbare Meldungen.
2. Retry löscht das alte Feedback.
3. Bestehende Brücken-Regression (Quiz, Runner-Übergänge, Mission, Portal, XP) bleibt grün.
4. Kein Merge/Release vor Godot-Import, Headless-Gameplay, Webexport, echten Querformat-Renderbildern, Archivschutz und iPhone-QA.

## Tests und Ergebnis
- Neue Assertions im `res://adventure/adventure_bridge_test.gd` ergänzt; nicht lokal ausgeführt (keine bestätigte Godot-Laufzeit in diesem Durchlauf).
- Bestehender PR-CI-Run 42323418878 war vor den Änderungen grün. Neue CI muss separat geprüft werden.
- Code-Commit: 7594962622297978eb3f96b8d01730781e9cb3d5; Test-Commit: 08e2011aa94c04bd16fbfafe030b765037a548ef.
- PR #157 bleibt DRAFT. Keine neuen Skyway-Versionen, kein Merge und kein iPhone-Test behauptet.

## Nächster Schritt
Neuen PR-CI-Lauf prüfen und ggf. Fehler beheben; danach mobile 16:9/19.5:9 HUD-Kollisionen anhand echter Renderbilder und die bestehende lizenzierte Figur statt Testkapsel integrieren.
