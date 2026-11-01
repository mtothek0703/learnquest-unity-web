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

## Tatsächliche CI- und Bildabnahme
- Kandidat: `e6365b46`; Testanpassungen: `2f3b5686`, `a0cf68c2`, `25a707b2`, `854ddb85`, `c20fb39d`.
- Zwei zunächst rote CI-Läufe zeigten **veraltete numerische 1,96-Grenzen** in Headgear-, Integrated-Silhouette-, Mantle- und Thruster-Regressionen. Die vier Prüfungen wurden ausdrücklich auf den experimentellen 1,82-Entwurf aktualisiert. Der frühere 1,85-Mindestwert für Gesicht-Lesbarkeit wurde **nur für diesen DRAFT-Versuch** auf 1,80 angepasst; das ist keine automatische visuelle Freigabe.
- [Finale Godot-CI 41288166672](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41288166672): **52/52 Jobschritte erfolgreich**, einschließlich Import, Gameplay-/65-Bone-Skin-/Pose-Regressionen, Webexport und echter OpenGL-Querformatbilder. [24 Original-Renderframes](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41288166672/artifacts/13075629071).
- Echte 1280×720-PNGs von vorherigem erfolgreichem Branch-Head `a94dec66` ([Artefakt 13074618636](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41284431489/artifacts/13074618636)) und finalem Kandidat direkt in gleicher Front-/Chase-Detailkamera verglichen (max. RGB-Kanaldifferenz >25).
  - Front-Detail **8.085** veränderte Bildpixel (0,877 %), davon **7.007** im Kopfbereich x=480..799, y=45..209. Der unveränderte V123-Kontrollcharakter driftete im selben Kopfbereich nur **90** Pixel.
  - Chase-Detail **7.947** veränderte Bildpixel (0,862 %), davon **6.805** im Kopfbereich; V123-Kontrolle dort **222** Pixel. In den weiten Front-/Chase-Ansichten nur ca. 0,41 % Bildänderung.
- **Visuelle Bewertung:** Die kleinere Helm-/Kopf-/Haar-Silhouette ist real und etwas proportionaler, der komplette CC0-Fahrer wirkt jedoch weiter klobig und spielzeugartig. Keine ausreichende Gesamtqualitätssteigerung gegenüber dem stabilen V123-Charakter. Pixelunterschiede allein sind kein Qualitätsnachweis.
- **Freigabeentscheidung:** PR #111 bleibt **DRAFT / VISUAL HOLD**; kein Merge, kein V142- oder anderer Release aus dieser Änderung. Die letzte bestätigte stabile Version bleibt V141. Reale iPhone-FPS, Hals-/Schulter-Clipping und vollständige Touch-Runde nach drei Englischfragen sind nicht manuell abgenommen.
- Nächster großer Grafikschritt: die starren, breiten Schulter-/Brust-Überlagerungen und das blockige Haar als zusammenhängende GPU-geskinnte Form aufräumen; vor einer Freigabe echte Vorher-/Nachher-Gesamtansichten statt bloßer Prozentzahlen prüfen.
