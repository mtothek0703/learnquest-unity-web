# LearnQuest 3D — 01.11.2026 — experimentelle Aerofoil-Silhouette im Querformat

## Pflichtregeln und Kontozuordnung
Vor dem Sprint wurden `LEARNQUEST_SPRINTS.md` und `LEARNQUEST_RELEASE_POLICY.md` explizit von `main` gelesen. Verifiziert: GitHub-Primary `mtothek0703` (michael_kohler1@yahoo.de), Repository `mtothek0703/learnquest-unity-web`, Default-Branch `main`. Der separate Grees-Klimatechnik-Account wurde nicht verwendet.

## Spur A — stabile Releases
Der letzte belegte, unveränderliche Release ist Skyway V140 (main `3868b1df`): Godot-CI [41269000533](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41269000533), Archivschutz [41269000605](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41269000605) und Pages [41269000563](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41269000563) jeweils erfolgreich. Die neueste main-Revision `62d7e0f` ergänzt ausschließlich das V140-Protokoll. **Kein neues eigenständig fertiges Gameplay-Feature**, daher keine künstliche V141 und kein Eingriff in main oder historische Skyway-/Unity-Dateien.

## Spur B — DRAFT PR #111, sichtbare Aerofoil-Überarbeitung
**Ausgangsbefund:** Die tatsächliche 1280×720-Verfolger- und Dreiviertelansicht aus dem vorigen Sprint zeigte einen seitlich zu dunklen, paddelförmigen Carve-Stabilisator, trotz korrekter zweiachsiger Animation. Das ist ein visuelles Qualitätsproblem, das reine CI-Regressionen nicht lösen.

**Umgesetzt (nur experimenteller Branch):**
- Geschlossene, weiterhin analytisch glatt schattierte Aerofoil-Meshes von einer breiten, beinahe gleichmäßigen Schaufelform auf eine stark zugespitzte, längs geschwungene Tragflächenform umgestellt. Halbspannweite von `0.055 + 0.17*sin(PI*t)^0.85` auf `0.012 + 0.145*sin(PI*t)^1.35`; Volumendicke von `0.016 + 0.038*taper` auf `0.010 + 0.030*taper` reduziert.
- Satin-Verbundmaterial heller und matter: weniger metallischer Anteil, höhere Rauheit, besser erkennbare Unterseite in der schrägen Smartphone-Kamera. Leuchtkante, 30/60-FPS-Interpolation und zweiachsige Lenkbewegung bleiben erhalten.
- Neue Geometrie-Regression für beide gespiegelten Finnen: Der Mittelquerschnitt muss deutlich breiter sein als beide Spitzen. Bestehende Tests prüfen weiterhin Normalkontinuität, Sichtbarkeit, Touch-/Kollisionsfreiheit, Steuerreaktion und zeitbasierte Animation.
- Keine externen Assets, neuen Drawcalls, Shader-Pässe oder Spielregeländerungen.

**Commits:** [Aerofoil-Form](https://github.com/mtothek0703/learnquest-unity-web/commit/b5f12f6dcae6e4356a2b73d01191efe963a40863), [Regression](https://github.com/mtothek0703/learnquest-unity-web/commit/83a32ec0d2e68593da53b2afa58f8e3f027da092).

**Technische Prüfung:** [GitHub Actions 41276285234](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41276285234) nach dem Code-/Testcommit gestartet. Ergebnis und Bildartefakte erst nach Abschluss nachtragen; kein vorzeitiges Test-GO behaupten.

## Qualitäts-Gate und nächste Schritte
24 neue reproduzierbare OpenGL-Querformatbilder (1280×720 und 1170×540, Verfolger-/Dreiviertelkamera, links/rechts/neutral) sind für den CI-Lauf vorgesehen. Ihre tatsächliche Pixelwirkung muss gegen den letzten erfolgreichen Stand `41272848439` geprüft werden; der neue Stabilisator darf nicht erneut schwarz/paddelförmig wirken. **Gesamtcharakter und PR #111 bleiben DRAFT**, ohne Merge/Release. Offene Punkte: hochwertige Gesamtfigur, manuelle iPhone-Safari-FPS, Clipping, komplette Touch-Spielrunde. Die drei Englischaufgaben, vier Welten, Bosse, vier Power-ups und historische Builds bleiben unverändert.
