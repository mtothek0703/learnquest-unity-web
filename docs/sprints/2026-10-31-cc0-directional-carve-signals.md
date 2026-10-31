# LearnQuest 3D – 31.10.2026, 22:44 MEZ – zwei Spuren

## Vorgaben und Konto
- Vor den Änderungen `LEARNQUEST_SPRINTS.md` und `LEARNQUEST_RELEASE_POLICY.md` auf `main` gelesen.
- Verifiziert: GitHub Primary (`michael_kohler1@yahoo.de`), Eigentümer `mtothek0703`, Repository `mtothek0703/learnquest-unity-web`; kein Zugriff auf Grees Klimatechnik.
- Unveränderliche Skyway-URLs, Unity-Archiv, drei Englischfragen, vier Welten, vier Power-ups und Touch-Eingaben nicht geändert.

## Spur A – stabile V137 jetzt wirklich veröffentlicht
- Vorheriger Sprint hatte V137 wegen eines veralteten 8- statt 12-PNG-Release-Gates noch nicht freigegeben.
- Main-Revision `c4fee06c6c7e32ec9838403f72a85c75bb2792fd`; [Pages-Lauf 41243924984](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41243924984) **completed/success**. Release-Log bestätigt Godot-Import, Gameplay, Webexport, zwölf Querformatbilder, Deploy und `build.txt` mit exakter SHA. `index.html`, `index.js`, `index.wasm`, `index.pck` jeweils HTTP 200 unter [skyway-v137/](https://mtothek0703.github.io/learnquest-unity-web/skyway-v137/).
- [Archivschutz 41243924985](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41243924985) **success**. Die vorherige V136 und Unity bleiben erhalten.
- **Pages-Risiko verschärft:** Upload-Artefakt **1.380.128.683 Bytes**, GitHub meldet Warnung über 1 GB, trotz erfolgreichem Deployment. Das ist kein behobenes Infrastrukturproblem.
- In diesem Durchlauf **kein** V138 erzwungen: V137 ist die neue tatsächlich geprüfte spielbare Version; es gibt noch kein weiteres eigenständig fertiges stabiles Feature.

## Spur B – PR #111 DRAFT: richtungsabhängige Leuchtkanten an echten 3D-Carve-Finnen
- `godot/hoverboard_dynamic_carve_fins.gd`: Jede der zwei bestehenden geschlossenen, beweglichen Aerofoil-Finnen besitzt jetzt eine eigene Materialinstanz für ihre bereits vorhandene Leuchtkante. Bei Rechts-/Linkskurve wird nur die jeweils äußere Finne heller und violetter; Turbo verstärkt beide. Exponentielle zeitbasierte Glättung verhindert 30/60-FPS-Abweichungen. Keine neuen Meshes, Kollisionen, Touch-Aktionen oder Fremdassets.
- `godot/hoverboard_sculpted_hull_test.gd`: Regression prüft zwei unabhängige Materialien, umgekehrte Leuchtpriorität bei Links-/Rechtskurve, sichtbare Emissionsdifferenz und identische 30-/60-FPS-Antwort.
- Nach Commit: GitHub-Godot-CI, Webexport und 16:9/19,5:9-Bilder prüfen. Keine Behauptung einer bestandenen visuellen Abnahme vor tatsächlicher Betrachtung.
- **DRAFT/VISUAL HOLD bleibt verbindlich**; PR-Titel V124 reserviert keine Nummer, vor künftigem Merge aktuellen Main einbeziehen.
- Noch offen: hochwertige Gesamtfigur, echte iPhone-FPS, Clipping und vollständige Touch-Spielrunde nach den drei Englischaufgaben.
