# 2026-11-02 — Diagnose der überlagerten CC0-Kragen-/Schulterflächen (DRAFT)

## Ausgangslage
- Verbindliche Dateien `LEARNQUEST_SPRINTS.md` und `LEARNQUEST_RELEASE_POLICY.md` auf `main` gelesen; GitHub-Primary `michael_kohler1@yahoo.de` und Repository `mtothek0703/learnquest-unity-web` geprüft.
- Stabile `main`-Basis `09601905af48ff905747ea58f43177aa7f7e2e31` / `skyway-v152/`; unverändert. PR #111 ist weiterhin DRAFT und reserviert keine Versionsnummer.
- Die letzte 108-Bild-Diagnose zeigte: Das obere Jackenfragment trägt zur hellblauen Frontkante bei; ohne obere Jacke wird eine andere violette Schicht sichtbar. Ein weiterer ungeprüfter Kragenschnitt wäre spekulativ.

## Umsetzung nur im DRAFT-Branch
- Die bestehende Godot-Visual-QA erhält **zwei zusätzliche Varianten** je 1280x720-/1170x540-Perspektive:
  - `after_no_jacket_no_harness`: Originalkörper und gewichtete Ärmel sichtbar, Jacke und tatsächlich GPU-geskinntes Vierband-Gurtsystem unsichtbar.
  - `after_no_jacket_no_harness_no_sleeves`: zusätzlich beide echten GPU-geskinnten Ärmel unsichtbar. Das ermöglicht die Zuordnung der Restkontur zum Originalkörper bzw. anderen Schichten.
- Die bereits vorhandenen neun Varianten bleiben erhalten. Sechs identische Kameraansichten, zwei Querformatauflösungen, eingefrorene Skelettpose und unveränderte Lichtquellen ergeben **11 × 6 × 2 = 132** echte Frame-Dateien.
- Das Capture-Skript prüft vorab, dass Gurte und beide Ärmel dieselbe Original-Skin wie der CC0-Körper verwenden. Ursprüngliche Sichtbarkeiten werden nach der Aufnahme wiederhergestellt; die QA-only-Shaderoption bleibt standardmäßig deaktiviert.
- Die PR-CI fordert nun genau 132 PNG-Dateien statt 108. Keine Änderungen an Gameplay, Touchsteuerung, Kollisionen, importiertem GLB, Original-Skin, `main`, Pages, alten Skyway-Verzeichnissen oder Unity-Archiv.

## Abnahmekriterien und nächster Schritt
1. Auf dem letzten Code-Commit muss Godot-PR-CI einschließlich Import, Gameplay-Regression, Capture und Webexport **nachweislich** bestehen. Die Erhöhung des Sollwerts ist allein noch kein bestandener Test.
2. Tatsächliche Front- und Verfolgeraufnahmen der Varianten `after_no_jacket`, `after_no_jacket_no_harness` und `after_no_jacket_no_harness_no_sleeves` aus demselben Actions-Artefakt in identischer Kamerapose vergleichen. Getrennt dokumentieren, welche obere violette/blaue Kante durch Gurte, Ärmel oder Originalkörper entsteht.
3. Erst dann eine zusammenhängende geometrische Schulter-/Kragenkorrektur entwickeln, mit realen A/B-Bildern und neuer CI. Bei schlechterer Silhouette zurücknehmen.
4. **Keine** Freigabe oder V153 allein für Diagnosebilder. PR #111 bleibt DRAFT; reale iPhone-Safari-FPS, Clipping und vollständige Drei-Fragen-Touchrunde sind weiterhin nicht abgenommen.

## CI-Status
- Code-Commit mit 132-Frame-Gate: `762fd64fe83f8409b503fcc90b9ed75f14f6a7e3`.
- CI-Ergebnis und Artefaktprüfung zum Zeitpunkt der Erstellung **noch nicht bestätigt**; erst nach nachweislichem Actions-Erfolg ergänzen.
