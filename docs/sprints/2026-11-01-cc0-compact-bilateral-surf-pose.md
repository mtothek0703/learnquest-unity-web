# LearnQuest 3D — CC0 compact bilateral surf silhouette (2026-11-01, DRAFT)

## Ausgangslage / Release-Trennung

Vor der Änderung wurden `LEARNQUEST_SPRINTS.md` und `LEARNQUEST_RELEASE_POLICY.md` auf `main` gelesen und das Primary-GitHub-Konto `mtothek0703` (michael_kohler1@yahoo.de) sowie das Repository `mtothek0703/learnquest-unity-web` geprüft. Der stabile Kanal hat unabhängig Skyway V147 aus Main `11c2a54a5bc0df55723ff218108df8c17972d2e2` veröffentlicht: [Pages 41336908121](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41336908121) mit exakter `build.txt`-Revision und HTTP 200 für alle fünf Dateien; [Godot 41336908124](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41336908124) und [Archivschutz 41336908209](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41336908209) erfolgreich. Der experimentelle PR #111 bleibt ausdrücklich DRAFT / VISUAL HOLD; sein V124-Titel reserviert keine Release-Nummer.

## Tatsächliche Änderung

Die Original-65-Knochen-Figur hatte trotz älterer Schulterkorrekturen eine relativ breite Superhelden-T-Pose. In `godot/rider_external_character.gd` werden die beiden originalen gewichteten Oberarme in der neutralen Board-Haltung jetzt um **1,57 rad** statt 1,42 rad aus der importierten T-Pose gefaltet. Die beiden Ellbogen werden gleichzeitig um **0,73 rad** statt 0,55 rad angewinkelt; die Handgelenke gleichen die engere Haltung aus. Die außen/innen-spezifischen Touch-Carve-Offsets bleiben symmetrisch, mit geringerem Auswärtsweg. Die Änderungen betreffen nur die bereits animierten Originalknochen und weder den Skin noch Spielregeln, Touchsteuerung, Physik, vier Welten, vier Power-ups, drei Englischaufgaben, Bosskämpfe oder Altversionen.

- Implementierung: [Commit 24d4ad19](https://github.com/mtothek0703/learnquest-unity-web/commit/24d4ad19027579ec0b9e7ecba38d66cd54adcfd1).
- `godot/rider_external_athletic_pose_test.gd` prüft nun eine tatsächliche import-rest-relative Schulterfaltung zwischen 1,48 und 1,72 rad sowie beidseitig mindestens 0,66 rad import-rest-relative Ellbogenbeugung. Die bestehende Neutralrückkehr, Links-/Rechts-Carve-, Sprung-, 30/60-FPS- und Kollisionsprüfung bleibt bestehen.
- Test-Commits: [14395a31](https://github.com/mtothek0703/learnquest-unity-web/commit/14395a31525c1f154ddd550204a52ff9b5f6337d) und [65f89e7e](https://github.com/mtothek0703/learnquest-unity-web/commit/65f89e7e72a00ad4b5582e09d35f5c96a47316ea) (GDScript-Typ-/Zeilenfortsetzungskorrektur).

## Qualitäts-Gates

- [ ] Abschließende Godot-PR-CI am Dokumentations-Head vollständig bestanden; Gameplay, 65-Bone, Webexport, Render-Captures.
- [ ] Echte identische 1280×720- und 1170×540-Front-/Chase-Frames vor/nach Änderung angesehen; keine visuelle Qualitätsfreigabe allein durch Winkelmessung oder Pixelzählung.
- [ ] Vollständiger iPhone-Safari-FPS-, Clipping- und Touch-Rundentest nach drei Englischaufgaben: weiterhin ausstehend.
- [x] Kein Merge nach `main`, keine neue Release-Nummer, keine Änderung an Unity-Archiv oder historischen Skyway-Verzeichnissen.

**Entscheidung:** technisch begründeter DRAFT-Posenversuch, vorerst nicht veröffentlichen. Vor einem eventuellen Merge gegen das dann aktuelle `main` aktualisieren und die nächste tatsächlich freie unveränderliche Skyway-Version wählen.
