# LearnQuest 3D — 01.11.2026 — CC0 weighted rear-lock phase sway (Spur B, DRAFT)

## Verbindliche Vorbereitung und Release-Schutz
- Auf `main` wurden `LEARNQUEST_SPRINTS.md` und `LEARNQUEST_RELEASE_POLICY.md` gelesen. Verifiziertes Ziel: GitHub Primary `mtothek0703` (`michael_kohler1@yahoo.de`), Repository `mtothek0703/learnquest-unity-web`.
- Letzter geprüfter stabiler Main-Commit: `2f90449c0404461c555f4617afd6fa17bee606f2` (Skyway V139). Main-Godot-CI `41256233196`, Archivschutz `41256233294` und Pages `41256233194` waren `completed/success`.
- PR #111 bleibt ausdrücklich **DRAFT / VISUAL HOLD**, nicht mergebar, ohne reservierte Versionsnummer. Kein V140 und keine Änderung an historischen Skyway- oder Unity-Dateien in diesem Experiment.

## Implementierung
- `rider_external_back_hair_wind.gdshader`: fünf echte GPU-geskinnte Haarlocken bekommen individuelle zeitbasierte Wellenphasen und eine spiegelsymmetrische, root-anchored seitliche Auffächerung der Enden. `flutter = tip * tip` verhindert zusätzliche Verschiebung an der Kopfhaut; die originalen vier Gewichte pro Vertex und das 65-Bone-Skinning bleiben erhalten.
- `rider_external_weighted_locks.gd`: fünf bestehende ShaderMaterial-Instanzen erhalten einmalig `lock_side` = [-1, -0.5, 0, 0.5, 1] und `lock_phase` = [0, 0.63, 1.26, 1.89, 2.52]. Keine neuen Meshes, Drawcalls, Kollisionen, Eingaben oder Fremd-Assets.
- `rider_external_skinned_back_hair_test.gd`: kontrolliert die tatsächlichen Shader-Parameter aller fünf geriggten Locks, root-anchored GPU-Bewegung und bestehende originale Skin-/Wind-/Farb-Invarianten.

## Prüfgates
- Neue PR-Godot-CI für finalen Code-Head: https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41260063925 (Ergebnis nach Abschluss prüfen).
- Automatische Tests/Webexport allein belegen **keine** hochwertigere Figur. Für eine Freigabe sind identische 1280×720-/1170×540-Chase-/Frontbilder und ein qualitativer Vergleich mit V123 sowie echte iPhone-FPS, Clipping und eine komplette Touch-Spielrunde nach drei Englischaufgaben nötig.
- Spur A erhält keinen neuen Release ohne eigenständig fertigen, getesteten Mehrwert. Stabile V139 bleibt unangetastet.

## Nächster Schritt
CI-Fehler gegebenenfalls anhand des konkreten Logs korrigieren. Anschließend die neuen Haarbewegungen in echten Pose-locked Godot-Querformatbildern gegenüber dem vorherigen DRAFT-Stand vergleichen. Wenn die Unterschiede optisch unzureichend sind, das Experiment weiter verfeinern; keine vorzeitige Grafikfreigabe.

## Nachweis der abschließenden technischen Prüfung
- **Finaler Code-Head `b5ab1da18d800088ba25e7c4c3f72c7a77124ed1`:** [Godot-PR-CI 41260063925](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41260063925) ist `completed/success`, **52/52 Jobschritte erfolgreich**. Enthalten: 65-Bone- und Haar-Regressionen, Godot-Import, Gameplay, Webexport sowie bestehende Querformat-Render-QA.
- [18 gerenderte Haar-Vorher/Nachher-Frames](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41260063925/artifacts/13064743212) wurden als CI-Artefakt bereitgestellt (2.369.525 Bytes). Eine unabhängige visuelle Gegenüberstellung der neuen Phasenvariation gegen den vorherigen DRAFT-Head wurde in diesem Durchlauf **nicht** abgenommen; daraus wird kein Premiumgrafik-Meilenstein abgeleitet.
- Nach dem Test folgte nur diese Sprintdokumentation; kein Gameplay- oder Grafikcode wurde nach dem grünen Head verändert. PR #111 bleibt DRAFT, main bleibt `2f90449c` / V139.

## Zweiter Schritt im selben Sprint — isolierte Bildprüfung
- Der zunächst grüne CI-Head `b5ab1da1` hatte 18 Bilder erzeugt. Eine Gegenüberstellung mit dem vorigen DRAFT-Lauf `41256598793` zeigte zwar Bildunterschiede, aber auch zeitabhängige Veränderungen an Körper und Board. Diese globalen Pixeldifferenzen dürfen **nicht** als reiner Haarqualitätsgewinn ausgegeben werden.
- Deshalb erfasst `rider_external_skinned_back_hair_visual_capture_test.gd` jetzt zwei zusätzliche 1280×720-Bilder mit **identischer 65-Bone-Pose, identischem Boost und identischer Kamera**: fünf Haarlocken synchronisiert (`lock_side=0`, `lock_phase=0`) gegenüber ihren tatsächlichen gespiegelten/staffelten Parametern. Ein Vergleich ausschließlich im oberen Haar-Bildausschnitt verlangt mindestens vier sichtbare Pixeländerungen; Board und Turbinen liegen außerhalb der Messzone.
- Der PR-Workflow erwartet dafür 20 statt 18 Original-PNGs. Code-Head `d6f3ebe1628536f6d936c00aeecd6779b09250fe` braucht eine **neue vollständige CI**; bis dahin bleibt die zusätzliche visuelle Abnahme offen.

## 20-Bild-Abnahme und Korrektur der Messmethode
- [Godot-CI 41260528057](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41260528057) bestand **52/52 Schritte** mit dem 20-Bild-Vergleich. [20 Originalbilder](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41260528057/artifacts/13064624644) wurden heruntergeladen und tatsächlich betrachtet.
- Synchronisierte gegen gestaffelte Haarlocken, 1280×720: **880 Pixel (1,964 %)** im oberen Haar-ROI `x=500..779, y=30..189` unterscheiden sich um mehr als 25 RGB-Stufen; über das ganze Bild 10.100 Pixel (1,096 %). Die optische Veränderung ist klein, die Gesamtfigur weiterhin nicht hochwertig genug.
- **Messfehler erkannt:** Andere Kindskripte können während der jeweils fünf Renderframes weiterlaufen und Körper-/Boardbewegungen verursachen. Deshalb werden für den finalen isolierten A/B-Vergleich jetzt nach den bisherigen 18 Aufnahmen sämtliche kosmetischen Kindskripte des Riders angehalten; nur die fünf Shader-Uniforms unterscheiden sich. Diese methodische Korrektur ist Code-Commit `6d38e73b`, neue [CI 41261009372](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41261009372) muss separat bestanden werden. Die bisherigen 880 Pixel sind **kein belastbarer isolierter Haar-Nachweis**.

## Finale technische und isolierte visuelle Abnahme
- **Finaler Grafik-/QA-Code-Commit `6d38e73ba046fa1fc2dc13312edc75f4fdc26899`:** [Godot-PR-CI 41261009372](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41261009372) **completed/success, 52/52 Schritte**, einschließlich Gameplay, 65-Bone-/Skinning-Tests, Webexport und 20 gerenderter Haarbilder. [Original-Artefakt 13065097718](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41261009372/artifacts/13065097718).
- Die zwei finalen 1280×720-A/B-PNGs wurden heruntergeladen, geöffnet und pixelweise verglichen. Bei **identischer eingefrorener Pose und identischem Boost** ändern sich `876` Pixel (1,955 %) im Haar-ROI `x=500..779, y=30..189` um mehr als 25 RGB-Stufen; im Board-ROI `x=350..929, y=470..699` **0 Pixel**. Ganzes Bild: `3.647` Pixel (0,396 %). Damit ist der Unterschied der phasenversetzten skinierten Haarlocken von Boardanimationen isoliert nachgewiesen.
- Die Änderung ist **real, aber visuell klein**. Der Kopf-/Haar-/Mantel-/Hoverboard-Gesamteindruck bleibt hinter dem Premiumziel; **keine visuelle Gesamtfreigabe**, PR #111 weiterhin DRAFT, kein Merge und kein Skyway-Release. Reale iPhone-FPS, Clipping und komplette Touch-Spielrunde bleiben offen.
