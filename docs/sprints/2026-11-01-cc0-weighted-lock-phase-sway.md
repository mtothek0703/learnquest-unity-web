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
