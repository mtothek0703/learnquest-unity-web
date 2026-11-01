# LearnQuest 3D — CC0 weighted hair shoulder-clearance trial (2026-11-01, Spur B)

## Ziel und Release-Disziplin
- GitHub-Konto vor allen Änderungen verifiziert: Primary `mtothek0703` / `michael_kohler1@yahoo.de`, Repository `mtothek0703/learnquest-unity-web`.
- Auf `main` verbindlich gelesen: `LEARNQUEST_SPRINTS.md` und `LEARNQUEST_RELEASE_POLICY.md`.
- Stabile Spur A bleibt bei nachweislich veröffentlichtem **Skyway V141** (Main-Release `9a6187d1`, Pages `41280907588`). Keine Änderungen an `main`, alten Skyway-Builds oder dem Unity-Archiv.
- **DRAFT PR #111 / VISUAL HOLD**: Titel V124 reserviert keine Versionsnummer. Vor späterem Merge neueste `main`-Basis und nächste freie Version prüfen.

## Tatsächlich programmierte 3D-Geometrie
- `godot/rider_external_back_hair_sculpt.gd`: stärkere beidseitige Einwärtsverjüngung der durchgehend modellierten, vierfach GPU-geskinnten Rückenhaarschale von 8% auf 16% (zum unteren Saum), etwas stärkere S-Kurven und fünf ausgeprägtere räumliche Saumlappen/Grooves. Die Kopfhautwurzel bleibt unverändert.
- `godot/rider_external_headgear.gd`: Querschnitt des realen 3D-Haarschalenpfads von `1.06 + 0.40*sin(PI*t) - 0.32*t` auf `1.06 + 0.50*sin(PI*t) - 0.49*t` geändert: weiterhin breiter Mittelteil, aber am unteren Saum ca. **46% schmaler als die Kopfhautbreite**. Alle fünf tatsächlich vierfach geskinnten äußeren Haarlocken folgen derselben 16%-Einwärtsverjüngung; keine zusätzlichen Nodes, Materialien, Drawcalls, Kollisionen oder externen Assets.
- `godot/rider_external_back_hair_sculpt_test.gd`: geometrische Regression für breiten Ansatz, 48–64% Saum-/Kopfhautbreitenverhältnis, fünf skulptierte Saumspitzen und beidseitige, synchronisierte Locken. Originale 65 Knochen, Skin und Gewichte bleiben erhalten.

## Echte Tests und Bildvergleich
- Erste CI auf `74058d37` **rot** ([41292718334](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41292718334)): bestehender Headgear-Test meldete `rear hair must have a sculpted shoulder flare and tapered tips`. Ursache: die erste Variante (`+0.34*sin`) hatte den Mittelteil zu stark eingeengt. Korrektur `+0.50*sin` in `bd609734` erhält die Schulterform und lässt die unteren Spitzen schmaler.
- **Finale CI auf `bd60973488b99e2db0aa801703ee6ca76b9e1551` grün:** [Godot PR validation 41292801254](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41292801254), **52/52 Schritte erfolgreich**: Import, alle Gameplay-/Rig-/Skinning-/Geometrie-Regressionen, Webexport und echte 1280×720- und 1170×540-OpenGL-Renderframes.
- [24 finale Original-Porträtframes](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41292801254/artifacts/13077724398) gegen [24 vorige Frames](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41288166672/artifacts/13075629071) in identischen Kameras verglichen. RGB-Maxkanaldifferenz >25:
  - 1280×720 Chase-Detail: **3.470 Pixel / 0,377%**, davon **1.825 Pixel** in oberem x=400..879/y=0..219-Bereich.
  - 1280×720 Chase-Weit: **1.808 Pixel / 0,196%**.
  - 1280×720 Front-Detail: **1.996 Pixel / 0,217%**.
  - 1280×720 linkes Profil: **3.391 Pixel / 0,368%**.
- **Visuelle Bewertung:** Die unteren Haare liegen etwas enger an; in der gesamten Verfolgeransicht ist die Änderung jedoch **klein**. Die großen cyanfarbenen Schulterelemente, die blockige Gesamtform und die Qualität des Gesichts sind weiterhin nicht ausreichend. Pixelunterschiede beweisen keine High-End-Qualität.

## Entscheidung und nächste Arbeit
- **Kein Merge, kein Release:** PR #111 bleibt DRAFT / VISUAL HOLD; stabile Spur A darf unabhängig fortschreiten.
- Nächster Schritt: auffällige cyanfarbene Schulter-/Kopf-Silhouette und klobige Kostümüberlagerungen in echten identischen 16:9-/19,5:9-Frames gezielt reduzieren, hochwertige Gesamtfigur und Hoverboard priorisieren.
- Reale iPhone-Safari-FPS, Mesh-Clipping unter allen Posen und vollständige Touch-Spielrunde nach drei Englischfragen bleiben manuell offen. Pages-Artefakt >1 GB weiter beobachten.
