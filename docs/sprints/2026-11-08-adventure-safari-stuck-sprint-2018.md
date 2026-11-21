# LearnQuest Adventure – Safari-Fokusverlust: Sprint-Touch zurücksetzen (08.11.2026, 20:18)

## Änderung
In `godot/adventure/neon_walk_testbed.gd` setzt Fokusverlust zusätzlich `player.set_mobile_sprint(false)`; damit bleibt nach Tabwechsel kein gehaltenes SPRINT aktiv, wenn Safari kein `button_up` mehr sendet. Der Runner und seine Gesten bleiben unangetastet. `adventure_bridge_test.gd` aktiviert vor dem Fokusverlust Sprint und prüft anschließend das Zurücksetzen.

## Akzeptanzkriterien
- Beim Fokusverlust wird ein aktiver Sprint-Hold gelöscht.
- Keine Bewegung oder Sprint-Wiederaufnahme durch verlorenes Touch-Release.
- Kein Eingriff in die Runner-Steuerung, Quizfragen, Welten, alte Builds oder Unity-Archiv.

## Nachweise und Grenzen
- Primary-Konto `mtothek0703` und Repo geprüft; die vier Pflichtdokumente von `main` gelesen.
- PR #157 war DRAFT; Head vor Änderung `76520fb6e2b91dc3aef4e7a12967022df631ea4d`, PR-Basis `b9010294fea1728212bea50d413c465d55706dd2`. Die Compare-Abfrage meldete `main` `46bfea3ecbfa4db8cc755df8d7fab201706d8059` und 2 Commits Rückstand; deshalb kein Rebase/Merge.
- Vorheriger CI-Lauf 42508759146 für `76520fb` war erfolgreich.
- Gameplay-Fix Commit `aad6079542b34d9fb1cf41bc3a6c0754581abaa4`; Regressionstest Commit `729e27cfdb576330fa1511f1d8d9266cf7e63815`.
- **Neu hinzugefügter Test nicht ausgeführt oder als bestanden bestätigt**; kein lokaler Godot-Import, Headless-Run, Webexport, echter 16:9-/19.5:9-Render, iPhone-Safari-Test oder Release in diesem Sprint.
- Nächster Schritt: CI für neuen PR-Head auswerten und echte mobile Querformat-QA durchführen; erst danach Charakteradapter prüfen.
