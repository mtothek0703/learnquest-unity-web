# LearnQuest 3D — CC0 portrait proportion trial (2026-11-01, Spur B)

## Kontext und Freigaberegel
- Repository und Konto vor dem Schreiben geprüft: `mtothek0703/learnquest-unity-web`, GitHub Primary `mtothek0703` / `michael_kohler1@yahoo.de`.
- Verbindlich auf `main` gelesen: `LEARNQUEST_SPRINTS.md` und `LEARNQUEST_RELEASE_POLICY.md`.
- Stabile Spur A zuletzt nachweislich `skyway-v141/` (main `9a6187d1`, Pages `41280907588`); diese Arbeit verändert `main`, Unity-Archiv und historische Skyway-URLs **nicht**.
- DRAFT PR #111 bleibt **VISUAL HOLD**; Titel V124 reserviert keine Release-Nummer.

## Änderung / sichtbares Ziel
Die Kopf-/Helm-/Gesichts-/Haar-Silhouette war in den bisherigen echten Verfolgerbildern im Verhältnis zum original skinierten Körper weiterhin übergroß. Der **gesamte zusammenhängende Head-gebundene Porträtumfang** wird von Faktor **1,96 auf 1,82** verkleinert (lineare Abmessungen ca. **7,14 %** geringer), anstatt nur Augen oder einzelne Anbauteile zu verschieben. Der 65-Knochen-CC0-Quellkörper, sein originaler GPU-Skin, vier normierte Vertexgewichte, Boardkontakt, Touchsteuerung, drei Englischfragen, vier Welten, Bosskämpfe und vier Power-ups bleiben unverändert.

- `godot/rider_external_character.gd`: zentraler Porträtmaßstab 1,82; unveränderte Head-Bone-Bindung.
- `godot/rider_external_headgear_test.gd`: explizite Regressionsgrenze 1,80–1,84 und Schutz des Original-Skeletts.

## Qualitäts-Gates
1. Godot-Import, alle bestehenden Gameplay-/Skinning-/Pose-Regressionen und Webexport müssen auf dem **finalen** Branch-Head erfolgreich sein.
2. Echte 1280×720- und 1170×540-Querformat-Frames aus dem CI-Artefakt kontrollieren (Front, Chase, Detail, Profil sowie Action-Posen), idealerweise gegen denselben Kamerastand des vorherigen Branch-Heads `a94dec66`.
3. Kopf-/Haaransatz, Augenlesbarkeit, Schulter-/Hals-Clipping und reale iPhone-Safari-FPS separat prüfen. Eine veränderte Pixelzahl oder ein bestandener Headless-Test allein sind **kein** Qualitätsbeweis.
4. **Kein Merge und kein Release** ohne sichtbare Gesamtqualitätsabnahme; der experimentelle PR blockiert unabhängige stabile Releases nicht.

## Laufstatus
- Implementiert in `e6365b46`, Testanpassung `2f3b5686`.
- Finale CI und visuelle Abnahme **noch nicht bestätigt**. Ergebnisse nach Abschluss nachtragen, ohne die Gate-Anforderungen abzuschwächen.
