# LearnQuest 3D — 01.11.2026 — experimentelle zweiachsige Hoverboard-Finnen

## Vorgaben und getrennte Spuren
Vor Beginn wurden `LEARNQUEST_SPRINTS.md` und `LEARNQUEST_RELEASE_POLICY.md` erneut auf `main` gelesen; das Repository und das GitHub-Primary-Konto (`mtothek0703`) wurden verifiziert. Die stabile Hauptspur bleibt unabhängig vom experimentellen DRAFT-PR #111. Der Titel V124 reserviert keine Versionsnummer.

### Spur A — stabil
Letzte vor diesem Sprint bestätigte unveränderliche Veröffentlichung: `skyway-v140/` (main `3868b1df`). Der Main-Godot-Lauf `41269000533`, der Archivschutz `41269000605` und das Pages-Deployment `41269000563` waren erfolgreich. Dieser Sprint enthält **keinen** neuen stabilen Gameplay-Mehrwert; daher **kein** V141-Release und keine Änderung an main oder alten Releases.

### Spur B — DRAFT PR #111
**Problem:** Die aus echten geschlossenen 3D-Meshes aufgebauten Hoverboard-Seitenfinnen klappten nur um die Z-Achse. Beim Richtungswechsel sprang ihre Signalfarbe unmittelbar von Cyan zu Violett, während Geometrie und Leuchtstärke bereits zeitbasiert geglättet wurden.

**Implementierung:**
- Die äußere Finne wird beim Lenken nicht nur um Z geschwenkt, sondern hebt sich um bis zu 0,14 Welteinheiten, verschiebt sich bis zu 0,065 Einheiten nach außen und neigt sich um X in die Luftströmung. Boost erhöht den gemeinsamen Grundanstellwinkel. Die inneren Finnen bleiben zurückhaltender.
- Exponentielle Zeitglättung (`1-exp(-9*delta)`) für Position, zweite Rotationsachse und Farbe, passend zu bestehendem Finnenlicht und 30/60/120-FPS-Ziel.
- Keine neuen Render-Meshes, Texturen, Shader-Pässe, Kollisionen, Input-Belegungen oder Gameplay-Regeln; ursprüngliches Hoverboard und 65-Knochen-Skin bleiben unangetastet.
- Regression in `hoverboard_sculpted_hull_test.gd`: asymmetrische Höhe/Ausladung/Neigung, sichtbare Farbinterpolation, Gleichheit bei 30 und 60 FPS und Rückkehr in die Neutralstellung.

**Qualitäts-Gate:** Die tatsächliche Pixelwirkung der neuen Bewegung muss noch anhand der CI-Querformat-Aufnahmen geprüft werden. Automatisch bestandene Tests allein sind keine Freigabe der Gesamtfigur. PR #111 bleibt DRAFT. Reale iPhone-Safari-FPS, Clipping und manuelle Touch-Spielrunde sind weiterhin offen.

**CI:** Letzter Testlauf nach der Implementierung: https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41272457696 (bei Anlage dieses Protokolls noch in Bearbeitung; Ergebnis nach Abschluss nachtragen). Kein Merge, keine Veröffentlichung ohne visuelle Qualitätsabnahme.
