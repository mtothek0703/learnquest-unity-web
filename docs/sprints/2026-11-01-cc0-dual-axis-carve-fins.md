# LearnQuest 3D — 01.11.2026 — experimentelle zweiachsige Hoverboard-Finnen

## Vorgaben und getrennte Spuren
Vor Beginn wurden `LEARNQUEST_SPRINTS.md` und `LEARNQUEST_RELEASE_POLICY.md` erneut auf `main` gelesen; das Repository und das GitHub-Primary-Konto (`mtothek0703`) wurden verifiziert. Die stabile Hauptspur bleibt unabhängig vom experimentellen DRAFT-PR #111. Der Titel V124 reserviert keine Versionsnummer.

### Spur A — stabil
Letzte vor diesem Sprint bestätigte unveränderliche Veröffentlichung: `skyway-v140/` (main `3868b1df`). Der Main-Godot-Lauf `41269000533`, der Archivschutz `41269000605` und das Pages-Deployment `41269000563` waren erfolgreich. Dieser Sprint enthält **keinen** neuen stabilen Gameplay-Mehrwert; daher **kein** V141-Release und keine Änderung an main oder alten Releases.

### Spur B — DRAFT PR #111
**Problem:** Die aus echten geschlossenen 3D-Meshes aufgebauten Hoverboard-Seitenfinnen klappten nur um die Z-Achse. Beim Richtungswechsel sprang ihre Signalfarbe unmittelbar von Cyan zu Violett, während Geometrie und Leuchtstärke bereits zeitbasiert geglättet wurden.

**Implementierung:**
- Die äußere Finne wird beim Lenken nicht nur um Z geschwenkt, sondern hebt sich um bis zu 0,10 Welteinheiten, verschiebt sich bis zu 0,045 Einheiten nach außen und neigt sich um X in die Luftströmung. Boost erhöht den gemeinsamen Grundanstellwinkel. Die inneren Finnen bleiben zurückhaltender.
- Exponentielle Zeitglättung (`1-exp(-9*delta)`) für Position, zweite Rotationsachse und Farbe, passend zu bestehendem Finnenlicht und 30/60/120-FPS-Ziel.
- Keine neuen Render-Meshes, Texturen, Shader-Pässe, Kollisionen, Input-Belegungen oder Gameplay-Regeln; ursprüngliches Hoverboard und 65-Knochen-Skin bleiben unangetastet.
- Regression in `hoverboard_sculpted_hull_test.gd`: asymmetrische Höhe/Ausladung/Neigung, sichtbare Farbinterpolation, Gleichheit bei 30 und 60 FPS und Rückkehr in die Neutralstellung.

**Qualitäts-Gate:** Die tatsächliche Pixelwirkung der neuen Bewegung muss noch anhand der CI-Querformat-Aufnahmen geprüft werden. Automatisch bestandene Tests allein sind keine Freigabe der Gesamtfigur. PR #111 bleibt DRAFT. Reale iPhone-Safari-FPS, Clipping und manuelle Touch-Spielrunde sind weiterhin offen.

**CI:** Letzter Testlauf nach der Implementierung: https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41272457696 (bei Anlage dieses Protokolls noch in Bearbeitung; Ergebnis nach Abschluss nachtragen). Kein Merge, keine Veröffentlichung ohne visuelle Qualitätsabnahme.

## Echte visuelle Zwischenabnahme und Korrekturschleife
- Die erste vollständige CI `41272457696` bestand **52/52 Schritte**, inklusive Godot-Regression, Webexport und 24 Querformat-Renderbildern. Das Artifact `13070311034` wurde tatsächlich heruntergeladen und die Bilder mit dem vorherigen erfolgreichen Lauf `41269139463` / Artifact `13068577267` bei identischer Kamera verglichen.
- Ergebnis der ersten Bildprüfung: Die Finne war in der Dreiviertelansicht bei Rechtskurven **zu groß und zu dunkel**; sie wirkte wie eine schwarze Schaufel vor Fuß/Deck. Der technische Test allein hätte das nicht erkannt. Die Qualitätsabnahme der ersten Ausführung wurde deshalb **nicht** erteilt.
- Nachkorrektur: X-Neigung von maximal 0,307 auf 0,197 rad, Hub von 0,14 auf 0,10, zusätzliche Außenverschiebung von 0,065 auf 0,045 Einheiten reduziert. Satinmaterial aufgehellt, metallische Reflexion verringert und Rauheit erhöht. Die Regression wurde entsprechend angepasst, bleibt auf echte Bewegung, 30/60-FPS-Gleichheit und Rückkehr zum neutralen Board fokussiert.
- Neue CI und neue 16:9-/19,5:9-Bildprüfung sind erforderlich, bevor dieser Stand technisch/visuell bewertet werden darf. Auch bei Erfolg bleibt die Gesamtfigur im DRAFT-Status.

## Abschließende technische und visuelle Prüfung
- Korrigierter Code-/Teststand `5aaad7e8`: [GitHub Actions #41272848439](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41272848439) **erfolgreich, 52/52 Schritte**, einschließlich Godot-Import/Gameplay-Regression, Webexport, zwei Querformatgrößen und 24 reproduzierbaren Carve-Fin-Aufnahmen.
- [24 Originalframes des korrigierten Stands](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41272848439/artifacts/13069714372) wurden heruntergeladen und gegen die vorigen [24 Frames](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41269139463/artifacts/13068577267) verglichen. Bei 1280×720 und identischer Kamera unterscheiden sich im Rechtskurven-Bild 7.486 Pixel (0,812 %) der Verfolgerkamera und 10.078 Pixel (1,094 %) der Dreiviertelansicht mit maximaler RGB-Kanaldifferenz über 25/255.
- Die Nachkorrektur verkleinert die schwarze Paddelwirkung gegenüber dem ersten Versuch (Dreiviertel-Rechtskurve: 11.876 auf 10.078 gegenüber Vorversion veränderte Pixel). Die Finne bleibt jedoch im schrägen Blickwinkel noch zu dunkel und wirkt wie ein flaches Paddel; **kein visuelles Gesamtqualitäts-GO**. Weitere Material-/Silhouettenarbeit ist nötig.
- Alle vier Welten, drei Englischfragen vor einer Runde, Bosskämpfe, vier Power-ups, Touch-Gesten, historische Skyway-URLs und Unity-Archiv wurden im experimentellen Änderungssatz nicht bearbeitet.
- **Keine Veröffentlichung**: main bleibt auf dem zuvor belegten V140-Spielstand, DRAFT PR #111 bleibt offen. Keine echten iPhone-FPS-/Clipping-/Touch-Spielrunden nachgewiesen.
