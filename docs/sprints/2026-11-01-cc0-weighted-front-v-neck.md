# 2026-11-01 — DRAFT PR #111: echte skinnierte Front-V-Halslinie

## Pflichtbasis und zwei Spuren
- `LEARNQUEST_SPRINTS.md` und `LEARNQUEST_RELEASE_POLICY.md` auf `main` vor dem Sprint gelesen; GitHub-Primary `mtothek0703` / `michael_kohler1@yahoo.de`, Repository `mtothek0703/learnquest-unity-web` geprüft.
- **Spur A:** Der eigenständige stabile V146-Querformat-HUD-Commit `2445586f0ae776149accc62034a79bf664f592c1` ist auf `main`. Godot-, Health- und Archiv-Workflows sind grün; Pages-Workflow [41326988635](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41326988635) war beim Beginn dieses DRAFT-Sprints noch im Deployment. Keine V146-Live-Behauptung ohne Abschluss, exakte `build.txt`-Revision und HTTP 200 aller fünf Dateien. Keine neue Versionsnummer erzwingen.
- **Spur B:** [PR #111](https://github.com/mtothek0703/learnquest-unity-web/pull/111) bleibt DRAFT / VISUAL HOLD. Sein historischer V124-Titel reserviert keine Versionsnummer.

## Beobachtetes Problem und echte Änderung
Die zuvor breite, gerade obere Jackenkante wirkte im Smartphone-Querformat wie ein durchgehender Spielzeugkragen. Die zusätzliche gewichtete Halsmanschette wurde bereits in einem früheren DRAFT-Sprint ausgeblendet; die tatsächlich geriggte Jackengeometrie selbst blieb jedoch oben horizontal abgeschnitten.

- In `godot/rider_external_skinned_outfit.gd` wird die obere **echte CC0-65-Bone-Jackenoberfläche** jetzt entlang einer symmetrischen, zur vorderen Körpermitte um 5,2 % der ursprünglichen Körperhöhe abgesenkten V-Halslinie geschnitten. Die beiden seitlichen Schultern und der hintere Kragen bleiben auf der alten Höhe.
- Die neuen Schnittpunkte interpolieren weiterhin vier normalisierte Original-Skin-Bindungen; die originalen CC0-Dreiecke, das 65-Knochen-Rig und die darunterliegende Körperoberfläche bleiben unverändert. Keine starren Ersatzteile, neue Kollisionen, Touch-/Gameplay-/Boardänderungen oder externen Assets.
- `godot/rider_external_skinned_outfit_test.gd` testet V-Tiefe, links/rechts symmetrische Schulterhöhe, erhaltenen Rückenausschnitt, geschnittene statt verworfene Quell-Dreiecke und vier normalisierte Skin-Gewichte an neuen Schnittpunkten.

## Verifikation und Freigabegate
- Implementierungscommits: `def0907f48fdeae3d39b427ceed92f63956a4cd7` und `218938e2c3a4cb4a35b612266a7685e84661ef92`.
- [ ] Finale PR-Godot-CI einschließlich Webexport, Original-65-Bone-Regression, 108 isolierten Kleidungsbildern, 48 Silhouettenbildern und 16:9-/19,5:9-Render-QA abwarten und konkrete Ergebnisse nachtragen.
- [ ] Echte Originalbilder mit der vorherigen Jackenkante in identischen Kamera- und Pose-Zuständen vergleichen; prüfen, ob die Halslinie in der Front-/Chase-Gesamtfigur sichtbar und nicht vom Helm verdeckt ist. Pixelabweichungen allein sind keine Qualitätsabnahme.
- [ ] Reale iPhone-FPS, vollständige Touch-Spielrunde nach drei Englischfragen und alle Clipping-Posen bleiben manuell offen.

**Kein Merge, kein Stable Release und keine Freigabe der Gesamtfigur ohne sichtbare Qualitätsabnahme.** Die bestehende stündliche Aufgabe bleibt aktiv.
