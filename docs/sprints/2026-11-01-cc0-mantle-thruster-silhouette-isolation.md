# 2026-11-01 — DRAFT #111: Mantel-/Thruster-Silhouette isoliert prüfen

## Pflichtprüfungen
LEARNQUEST_SPRINTS.md und LEARNQUEST_RELEASE_POLICY.md auf main gelesen. Primary-Konto mtothek0703 und Repository verifiziert. Letzter bestätigter stabiler Release bei Beginn V145. DRAFT #111 bleibt strikt VISUAL HOLD; keine Versionsnummer reserviert.

## Problem
Die CC0-65-Bone-Figur wirkt trotz vieler technischer Skinning- und Kostümtests aus der Verfolgerkamera zu spielzeugartig. Eine Reihe kleiner Mesh-Anpassungen ergab bislang keinen überzeugenden Gesamtqualitätssprung. Der breite gewichtete Mantel und die leuchtenden Schulterkerne sind mögliche dominante Silhouettenelemente; das soll anhand **identischer, eingefrorener echter Renderbilder** statt nach Bauchgefühl entschieden werden.

## Implementierung
Der vorhandene Godot-OpenGL-Vergleich rendert jetzt 48 statt 24 Frames: V123 original, vollständige experimentelle Figur, Figur ohne beide GPU-skinned Mantelschöße und Figur ohne beide GPU-skinned Schultertriebwerkskerne. Zwei echte Smartphone-Querformate und sechs identische Kameraansichten bleiben erhalten. Die tatsächlichen beiden Mantel- und Core-Meshes werden explizit gesucht; fehlen sie, scheitert der Test. Der Originalvergleich und alle 65 Bones, Skin-Gewichte, Gameplay, Touch, Archive bleiben unverändert. GitHub Actions verlangt exakt 48 Bilder.

## Offene Abnahme
- [ ] Godot-CI, Webexport und 48 reale PNGs erfolgreich erzeugt
- [ ] Die 48 Bilder tatsächlich vergleichen und die silhouettenbestimmende Baugruppe identifizieren
- [ ] Danach gezielt Mantel-/Thruster-Geometrie überarbeiten; keine pauschale Freigabe aufgrund von Pixelzahlen
- [ ] iPhone-Safari-FPS, Clipping und vollständige Touch-Spielrunde nach drei Englischaufgaben manuell prüfen

**Kein Merge und kein Release.** Diese Diagnose ist ein Schritt zur gestalterischen Freigabe, kein bereits nachgewiesener Grafikqualitätssprung.

## Erste echte Bildauswertung und anschließender Geometrie-/Sichtbarkeitsversuch
- [x] [Godot-CI 41325621645](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41325621645) **52/52 Schritte erfolgreich**, darunter originaler CC0-65-Bone-Skin, Gameplay, Webexport und 48 echte 16:9-/19,5:9-Frames. [Originalbilder, Artefakt 13090709179](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41325621645/artifacts/13090709179).
- [x] Die 48 Originalbilder wurden heruntergeladen und visuell betrachtet: Im 1280×720-Chase-Detailbild entfernt `after_no_thrusters` die zwei großen cyanfarbenen, scheinbar losgelösten Schulterflügel; die Figur wirkt an der Schulter dadurch ruhiger. `after_no_mantle` entfernt dagegen vor allem schmale seitliche Mantelflächen, ohne den dominanten Schulterfehler zu beheben. Auch die Front-Detailbilder zeigen die störenden cyanfarbenen Schulterkerne. Das ist eine qualitative A/B-Diagnose, **kein** fertiger High-End-Charakter.
- [x] Reversibler experimenteller Sichtbarkeitsversuch: Wenn die echte skinnierte Jacke, beide Ärmel und beide Mantelschöße vorhanden sind, werden neben den bereits versteckten Schultergehäusen jetzt auch die zwei GPU-gewichteten leuchtenden Schulterkerne ausgeblendet. Bei unvollständiger Kleidung werden beide Kern- und Gehäusepaare wieder sichtbar. Original-Skin und Geometrie bleiben vorhanden. Regression prüft beide Zustände; die 48-Bild-QA enthält jetzt `after_with_thrusters` als expliziten alten A/B-Vergleich.
- [ ] Neue Godot-CI, 48 neue Querformatbilder und erneute Front-/Chase-Qualitätsabnahme nach diesem Versuch stehen aus. Kein Merge, kein Release, PR #111 bleibt DRAFT/VISUAL HOLD. Reale iPhone-FPS/Clipping/Touch-End-to-End weiter offen.

### Quantitative A/B-Prüfung der Original-PNGs
Bei identischen 1280×720-Frames (RGB-Maxkanal-Differenz >25) ändern sich durch Ausblenden der Mantelschöße **12.379 Pixel / 1,343 %** in der Chase-Detailansicht, aber nur **2 Pixel** in der Front-Detailansicht. Die Schulterkerne ändern **6.017 Pixel / 0,653 %** in Chase-Detail und **1.228 Pixel / 0,133 %** in Front-Detail. In der 1170×540-Chase-Detailansicht sind es Mantel **6.947 / 1,100 %** und Kerne **2.835 / 0,449 %**. Die Mantelgeometrie trägt also stärker zur rückwärtigen Fläche bei, die Kerne sind hingegen aus beiden Richtungen als störende cyanfarbene Spitzen sichtbar. Pixelzahlen sind reine Sichtbarkeitsmessungen, keine automatische Qualitätsnote.

### Erste CI des Sichtbarkeitsversuchs: bewusst noch keine Freigabe
[Godot-Lauf 41326295834](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41326295834) erreichte Import, Gameplay, Webexport und die 48-Bild-Hauptdiagnose, scheiterte aber an einer **veralteten 108-Bild-Diagnoseassertion**, die weiterhin zwei sichtbare Schulterkerne verlangte. Das ist eine echte rote CI, kein bestandener Sprint. Der Test wurde auf die neue bewusst **leere Schulter-Only-Kontrollgruppe** angepasst; die zwei ursprünglichen GPU-geskinnten Kerne und ihr Fallback bleiben separat im Thruster-Regressionstest nachweisbar. Erneute vollständige CI und Bildabnahme ausstehend.
