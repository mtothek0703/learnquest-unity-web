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
