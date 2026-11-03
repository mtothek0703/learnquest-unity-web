# LearnQuest – Sprint 2026-11-03 10:14 CET: zweispuriges Integrations- und Qualitätsgate

## Verbindliche Grundlage
Auf `main` gelesen: `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`.
Repository und GitHub-Konto: `mtothek0703/learnquest-unity-web`, Primary (`mtothek0703`).

## Ist-Zustand
- `main`: `15f544d0283d4e3340c3df2ed87b75f3c71890d6` (nur Release-Policy).
- Letzter Spielcommit: `72651ea1a046e25f885172c14dccc5d39ef32ba0` (Skyway V154).
- Experimenteller Branch `sprint-v124-quaternius-rigged-hero`: 1064 Commits voraus, 95 zurück; gemeinsamer Ausgangspunkt `c20c19571ebb4d300fb32b2bfc12d3854da47a46`.
- PR #111 bleibt ohne visuelle Qualitätsfreigabe. Kein Merge, kein Release.

## Konkrete nächste Implementierung – Charakter und Hoverboard
1. Eine zusammenhängende Änderung an der Verfolger-Silhouette vornehmen: Schulter-/Oberarmkontur, Jackentaille und Board-Körper gemeinsam auf Lesbarkeit bei 1280×720 prüfen, statt kleine isolierte Zierdetails.
2. Für jede Pose (neutral, links, rechts, Sprung, Boost) dieselbe Kameraposition und Lichtkonfiguration verwenden; Menü-, Seiten- und Rückenansicht bei 16:9 und 19,5:9 aufnehmen.
3. Render-Vergleich gegen unveränderte Baseline mit Bildpfaden, SHA und Pixelvergleich dokumentieren. Pixelabweichung allein ist **kein** Qualitätsbeweis.
4. Nach Änderung Skinning- und Gameplay-Regression, Godot-Import und Webexport ausführen; echten iPhone-Touch-Test und FPS ausdrücklich offen lassen, solange nicht durchgeführt.
5. PR #111 erst nach visueller Freigabe und kontrollierter Synchronisierung mit dem dann aktuellen `main` integrieren. Titel V124 ist keine Versionsreservierung.

## Unabhängiger stabiler Kanal
Ein eigenständiger, fertiger Gameplay-/Welt-Verbesserungssprint darf parallel freigegeben werden, aber nur mit grüner CI, Webexport, Archivschutz und einer **neuen** unveränderlichen Skyway-URL samt `build.txt`-SHA und HTTP-200-Nachweis. Historische Skyway-Versionen und Unity-Archiv nicht verändern.

## Tatsächlich in diesem Durchlauf ausgeführt
GitHub-Dateien auf `main` gelesen; letzte Commits und Branch-Divergenz über GitHub abgefragt. Keine neuen Godot-Tests, Exporte, Bildvergleiche, manuellen Geräteprüfungen oder Pages-HTTP-Checks ausgeführt. **Kein neuer spielbarer Mehrwert und kein Release.** Dieses Protokoll ist ein überprüfbarer Arbeits-/Gate-Stand, kein als fertig ausgegebener Grafik-Sprint.
