# LearnQuest 3D – DRAFT hoverboard edge-light volume (2026-11-01)

## Pflichtprüfung / Trennung der Spuren

Vor Änderungen wurden `LEARNQUEST_SPRINTS.md` und `LEARNQUEST_RELEASE_POLICY.md` auf `main`, das Primary-Konto (`mtothek0703`), Repository `mtothek0703/learnquest-unity-web`, PR #111 und die aktuellen GitHub Actions gelesen. Stabile Version bleibt die zuletzt erfolgreich veröffentlichte Skyway V146 auf main (Commit `2445586f0ae776149accc62034a79bf664f592c1`, Godot-CI 41326988667, Archivschutz 41326988707, Pages 41326988635). Die Main-Dateien und alle historischen Releases sowie das Unity-Archiv werden in diesem DRAFT-Sprint nicht geändert. Kein V147 ohne eigenständigen, freigabefähigen Mehrwert.

## Spur B: echter 3D-Hoverboard-Rand

- Die zwei bisherigen flachen Edge-Light-Streifen des Hoverboards wurden **in-place** durch echte geschlossene, über 2,57 m geschwungene Leuchtröhren mit 12 radialen Segmenten, 28 Längssegmenten und geschlossenen Endkappen ersetzt. Sie verjüngen sich an beiden Enden (Radius 0,010 m), haben in der Mitte einen 0,046-m-Radius und folgen der bestehenden Chassis-Breite.
- Die bisherigen zwei Mesh-/Material-Instanzen bleiben erhalten; es kommen keine zusätzlichen Drawcalls, Physikkörper, Kollisionen, Eingabegesten oder Assets hinzu. Das vorhandene Boost-/Carve-Feedback über getrennte Port-/Starboard-Materialien bleibt aktiv. Der gesamte Eingriff betrifft ausschließlich die experimentelle Hoverboard-Grafik auf PR #111.
- Neue Godot-Regression in `godot/hoverboard_sculpted_hull_test.gd`: prüft mindestens 2.000 echte Mesh-Vertices pro Seite, vollständige Normalen, radiale Höhe/Tiefe, Endverjüngung, Symmetrie und durchgehende Längsausdehnung. Bestehende Board-, Gameplay-, 65-Bone- und Webexport-Tests dürfen nicht gelockert werden.
- Code-Commit `bc9b9e70`; Test-Commit `b05cb54b`.

## Abnahme-Gates

- [ ] Aktueller vollständiger PR-Godot-Workflow inklusive Export erfolgreich; finale Commit-SHA und Workflow-Link nach Abschluss ergänzen.
- [ ] Originale 16:9-/19,5:9-Querformatbilder mit/ohne Änderung bei gleicher Pose **tatsächlich ansehen** und bewerten. Mesh-Vertices allein belegen keine sichtbare Qualitätssteigerung.
- [ ] Gesamter CC0-Charakter inklusive Board optisch hochwertiger als V123 und reale iPhone-FPS/Clipping/Touchnavigation nach drei Englischfragen freigegeben.

**Entscheidung:** PR #111 bleibt DRAFT / VISUAL HOLD, nicht mergen, keine Release-Nummer reservieren. Stabile Skyway V146 unverändert; späterer Merge nur nach Rebase auf dann aktuelles main und mit nächster freier unveränderlicher Versionsnummer.
