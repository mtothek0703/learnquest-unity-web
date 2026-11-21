# LearnQuest 3D – Adventure A4: Ausgangsportal-Puls (09.11.2026, 14 Uhr)

## Ausgangslage und Sicherheit
Primary GitHub mtothek0703 (michael_kohler1@yahoo.de), Repository mtothek0703/learnquest-unity-web, bestehender DRAFT PR #157 und Feature-Branch bestätigt. Vier Pflichtdokumente auf main gelesen. Main: `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; PR-Head vor Sprint `42640e0dab285bae0cd2838dca1d93cb287cb319`, 181 Commits voraus, 2 hinter main. Vorheriger Godot-PR-Workflow #42615077892 erfolgreich. Keine Änderungen an Runner, Unity-Archiv, Skyway-URLs oder Release-Workflow.

## Gameplay-Änderung
Das vollständig freigeschaltete Neon-City-Ausgangsportal pulsiert jetzt im 3D-Raum sanft horizontal (Skalierung 1.0 bis 1.08), an Simulationszeit statt Wanduhr gekoppelt. Gesperrtes Portal bleibt unbewegt. Missions-Neustart setzt Phase und Skalierung zurück. Die tatsächliche Portalposition und Interaktionsreichweite bleiben unverändert. Kein neues Asset, keine Kosten.

## Akzeptanz und Tests
- Bei gesperrtem Portal keine Animation; bei abgeschlossener Mission und besiegtem Roboter sichtbare 3D-Pulsierung.
- Reset setzt Skala auf (1,1,1) und Animationsphase auf 0; keine Änderung an XP, Runner-Touch oder Einstieg.
- Regression im vorhandenen `res://adventure/adventure_bridge_test.gd` ergänzt: Pulsskalierung und Reset; anschließende Rückkehr-Fixture wiederhergestellt.
- **Tatsächlich ausgeführt:** GitHub-Konto-/Repo-/Main-/PR-Prüfung, Pflichtdokumente gelesen, vorherigen CI-Status für Commit `42640e0` geprüft (success), Code und Regression auf PR-Branch committed.
- **Nicht ausgeführt / nicht belegt:** lokaler Godot-Import, neuer Headless-Test, neuer PR-CI-Abschluss, Webexport, 16:9/19.5:9 Renderbilder, iPhone-Safari-QA und Pages-Deployment. Deshalb kein Merge/Release.

## Commits und nächster Schritt
Gameplay `ba9a644437428fbb8585ba0536f9bb82716ea77b`, Regression `bf33d784a6e8229d7e68b0409ff8bcbfd0c949d8`, DRAFT PR #157. Nächster Sprint: neuen CI-Lauf prüfen, Fehler beheben, reale Querformat-Bilder des Portals und Gehmodus erzeugen; DRAFT bis zu vollständiger QA beibehalten.
