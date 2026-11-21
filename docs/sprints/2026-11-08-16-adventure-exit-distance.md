# LearnQuest Adventure – 08.11.2026 16 Uhr: Wegführung zum Ausgang

## Ausgangslage und Prüfungen
- Primary-GitHub-Link `mtothek0703` / `michael_kohler1@yahoo.de`, Repository `mtothek0703/learnquest-unity-web`, bestehender DRAFT PR #157 bestätigt.
- Alle vier Pflichtdokumente auf `main` gelesen. `main`: `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; Adventure-Branch vor Änderung 126 voraus / 2 hinter main.
- Letzter PR-Head `dbcf674` hatte Godot-PR-Validation-Lauf `42488854943` mit Conclusion `success` (nur CI, keine Gerätefreigabe).

## Änderung
- Nach drei Kristallen, zwei Schaltern und Roboter-Sieg zeigt das mobile Missions-HUD nun die ungefähre Distanz zum Ausgangsportal und `AUFSTEIGEN` statt nur einer allgemeinen Aufforderung.
- Separater Regressionstest kontrolliert die Portal-Distanzanzeige nach dem Roboter-Sieg vor dem Rückwechsel in den Runner.
- Gameplay-Commit `2cfd33992efd9f90955fc6493a122665d06f93f8`; Test-Commit `2bc4c1ab310ca545e8befb4ebb99daedf6a4b2ff`.

## Akzeptanzkriterien und tatsächliche Tests
- [x] Code und Assertion im bestehenden Feature-Branch committed.
- [ ] Neue Godot-PR-CI für Test-Commit erfolgreich bestätigt (bei Dokumentation noch offen).
- [ ] Godot-Import, lokaler Headless-Gameplay-Test, Webexport und echte 16:9-/19,5:9-Renderbilder.
- [ ] iPhone-Safari-Querformat, Touch und Performance auf realem Gerät.
- [ ] Main-Merge/immutable Skyway-Release (bewusst nicht durchgeführt).

## Schutz
Runner, drei Englischfragen, vier Welten, Bosse, Power-ups, Touch-Gesten, alte Skyway-Builds, Unity-Archiv und experimenteller Charakter-PR #111 bleiben unberührt. PR #157 bleibt DRAFT. Nächster Schritt: CI für neuen Head prüfen und visuelle QA/isolierte lizenzierte Figur angehen.