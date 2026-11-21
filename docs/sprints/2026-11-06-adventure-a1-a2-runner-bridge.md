# LearnQuest 3D – Neon City A1/A2: integrierter, opt-in Gehmodus (06.11.2026)

## Identität, Ziel und Basis
- **GitHub-Konto:** Primary `mtothek0703`, `michael_kohler1@yahoo.de`; **Repo:** `mtothek0703/learnquest-unity-web` (geprüft vor den Änderungen).
- Änderung in **bestehendem DRAFT PR #157** `feature/adventure-a1-walkable-neon-testbed-20261106-19`, kein neuer konkurrierender A1-Branch, kein direkter Main-Merge.
- Bei Sprintbeginn main `3117869390c6f3dff6409bfde1f64c2d184b0853`; PR #157 basierte auf `b9010294...`, aktuell technisch synchronisierbar prüfen. Repo-Release-Policies und `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md` gelesen.

## Neu programmierte Spielmechanik
- Das bestehende `godot/world.gd` bietet im **Menü** außerhalb des bisherigen Quizpanels einen Schalter `ABENTEUER: AUS/AN`. Standard ist **AUS**; bewährte Rennrunde bleibt der Default.
- Nur **Neon City**: nach den bisherigen **drei verbindlichen Englischaufgaben** und mindestens **100 realen Rennmetern** erscheint beim Opt-in ein `ABSTEIGEN`-Button.
- Beim Absteigen stoppt die bestehende Session durch `phase = adventure`; der normale Runner/HUD und die Track-Input-Gesten sind ausgeblendet, die separate A1-Geharena wird physisch entfernt von der Rennstrecke instanziiert. Ihre eigene Third-Person-Kamera, `CharacterBody3D`-Kollisionen, Schwerkraft, Sprung und Touch-Richtungstasten übernehmen die Steuerung.
- Neues `AUFSTEIGEN` in der Geh-UI löst ein eigenes `return_requested`-Signal aus. Der Runner wird mit ursprünglicher Kamera, seinem HUD, seinem Inputmodus und denselben `xp`, `power`, `lives`, `distance` wiederaufgenommen – **ohne neue Quizfragen oder Bonus-Exploits**. Nur ein Besuch pro Rennrunde.
- Arena-Follow-Kamera wird intern referenziert (nicht über zufällig aktuelle andere Viewport-Kamera), um Kamerawechsel sauber zu isolieren. Fokusverlust beendet bestehende Walking-Inputs wie zuvor.
- Der Schritt verwendet bewusst noch eine **vorläufige Kapsel-Figur**. Die eigentliche Charakter-/Board-Optik, 3 Kristalle, 2 Schalter, Robot-Gegner, Übergangsanimationen und ein konsolidiertes Missionsziel **sind noch nicht integriert**. Kein Release nur wegen dieses technischen Gerüsts.

## Automatische Regression
- Neuer echter Godot-Test `godot/adventure/adventure_bridge_test.gd` startet die existierende Main-Szene, prüft **Default-AUS**, Sperre vor drei Fragen, drei richtige Quizantworten, Distanzsperre, Entry, echten `CharacterBody3D`-Bodenkontakt und Bewegung, Kamera-/UI-Wechsel, Signal-Rückkehr, Erhalt von XP, Energie, Leben und Streckenfortschritt sowie Einmal-Gate und Reset beim Neustart.
- `.github/workflows/godot-pr-check.yml` führt den neuen Test **in der PR-CI** unmittelbar nach dem bestehenden Smoke-Test aus, nur wenn der Test den Erfolgsmarker ausgibt. Die übrigen Tests und der Webexport bleiben bestehen.
- **Stand bei Erstellung:** CI dieses neuen Bridge-Sprints gerade gestartet; noch **kein bestandenes Bridge-Testergebnis** nachgewiesen, kein manueller Safari-Lauf, kein reeller FPS-/Clipping-Check. Vorheriger PR #157 Originaltest war erfolgreich, testete aber die neue Integration noch nicht.

## Nächste zusammenhängende Schritte
1. GitHub-PR-CI `Godot PR validation` des neuen Heads prüfen, alle neuen Parse-/Physics-/Kamera- oder UI-Fehler beheben.
2. Die reale bestehende Spielerfigur in den Laufmodus übertragen, ohne Hoverboard-Körperteile fälschlich als laufenden Charakter darzustellen.
3. In derselben Szene Kristalle, Schalter und Portal mit einmaliger Missionsbelohnung implementieren; optionales Verlassen bis Missionsende ersetzen durch echten Questabschluss.
4. Die bereits separaten A2-Missions- und A3-Roboterprototypen gezielt **in diesen einen integrierten Branch** übernehmen oder zusammenführen, keine weiteren isolierten DRAFTs erzeugen.
5. Tatsächliche 16:9/19,5:9-Renderbilder und iPhone-Safari-Bedienung prüfen. Erst mit grüner Gesamt-CI, Webexport, Archivschutz und exaktem unveränderlichem Pages-Deployment veröffentlichen. V154 bleibt erhalten; Versionsnummer erst bei Release vergeben.
