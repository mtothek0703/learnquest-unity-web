# LearnQuest 3D — Sprint 2026-11-04 16:13 CET

## Verbindliche Grundlage
`LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md` und `LEARNQUEST_RELEASE_POLICY.md` auf `main` gelesen. Repository `mtothek0703/learnquest-unity-web`, Konto Primary (`michael_kohler1@yahoo.de`) geprüft.

## Spur A — stable
Kein neuer freigabefähiger Gameplay-/Grafik-Commit in diesem Sprint erstellt. Keine Release-Nummer vergeben, keine bestehende Skyway-URL geändert. Godot-Import, Gameplaytests, Webexport, Pages-HTTP und Archivintegrität wurden in diesem Durchlauf nicht ausgeführt und gelten ausdrücklich nicht als bestanden. Unabhängige stabile Features dürfen durch PR #111 nicht blockiert werden.

## Spur B — DRAFT PR #111
Aktuelles `tools/character-frame-compare.html` auf `sprint-v124-quaternius-rigged-hero` gelesen. Vorhanden: lokale Bildauswahl, 16:9/19,5:9, Split-Vergleich, Pointer-Touch, Alt-/Neu-Einzelansicht, Abmessungswarnungen. Noch keine echten reproduzierbaren gerenderten Vorher-/Nachher-Frames, keine belegte Clipping-Freiheit, keine iPhone-FPS und keine bestandene visuelle Qualitätsabnahme. Keine Modelländerung und kein Merge. PR-Titel reserviert keine Versionsnummer.

## Nächste technische Akzeptanz
1. Identische Kamera, Pose, Beleuchtung und Auflösung in Menü und Verfolgeransicht aufnehmen (16:9 und 19,5:9).
2. 65-Bone-CC0-Körper, Kostüm und Hoverboard auf echte Clipping- und Silhouettenfehler untersuchen und konkrete Geometrie-/Skinning-Fixes implementieren.
3. Godot-Import und Regression, Webexport, mobile Querformatsteuerung und komplette Runde mit drei Englischaufgaben testen.
4. Für einen unabhängigen stabilen Release: neue spielbare Funktion, grüne CI, geschützte Altversionen/Unity-Archiv und fünf HTTP-200-Dateien mit exakter Build-Revision an einer neuen unveränderlichen URL nachweisen.

Ergebnis dieses Durchlaufs: dokumentierte Qualitäts- und Releasegrenzen, **kein** neuer Spielmehrwert und **kein** Release.
