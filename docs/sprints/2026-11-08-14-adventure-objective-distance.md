# LearnQuest Adventure A4 – Entfernung zum nächsten Missionsziel (08.11.2026, 14 Uhr)

## Änderung
Im bestehenden DRAFT PR #157 zeigt die Neon-City-Missionszeile außerhalb der Interaktionsreichweite jetzt den Typ und die aufgerundete Entfernung des nächsten sichtbaren Kristalls/Schalters in Metern. In Reichweite bleibt die bestehende INTERAKTION-Aufforderung; nach Abschluss bleiben Roboter- und Portalhinweise unverändert. Keine Änderungen an Runner, Touch-Gesten, Quiz, XP, Welten, Bossen oder Archiv.

## Akzeptanzkriterien
- Nicht erreichbares Missionsziel: Entfernungshinweis in Metern.
- In Reichweite: bisheriger Interaktionshinweis.
- Keine zusätzlichen Pflichtlernfenster und keine neue Release-Version.
- Bestehende Bridge-Regression prüft die neue Distanzanzeige.

## Nachweise und Einschränkungen
- Primary-GitHub-Konto mtothek0703 (michael_kohler1@yahoo.de), Repository und bestehender PR-Branch geprüft.
- Alle vier Pflichtdokumente auf main gelesen; main 46bfea3ecbfa4db8cc755df8d7fab201706d8059, ursprünglicher PR-Head b8528986f0852e6382ce6f49fe34a07266515655.
- Vorherige Godot-PR-CI für b852898: GitHub Actions #42479082781 erfolgreich.
- Code-Commit 3d2bf9e6e65efcccc54602b2ecdcbf8db3fd9960; Test-Commit 189ea0d7f95d9973516a382f21d21b059af90700.
- Neuer Test nur committed; keine lokale Godot-Ausführung, kein bestätigter CI-Erfolg für neue Commits, kein Webexport, keine echten 16:9-/19.5:9-Renderbilder, keine iPhone-QA. PR bleibt DRAFT. Kein Merge/Release.

## Nächster Schritt
Neuen CI-Lauf prüfen, echte Querformat-HUD-Renderbilder und Touchzonen testen; danach die vorhandene lizenzierte Spielfigur isoliert im Gehmodus integrieren, ohne Runner-Abhängigkeiten zu verändern.
