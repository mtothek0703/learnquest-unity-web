# Neue LearnQuest-Release-Policy – verbindlicher Einstieg

Stand: 03.11.2026. Diese Datei ergänzt die bestehende [LEARNQUEST_RELEASE_POLICY.md](LEARNQUEST_RELEASE_POLICY.md) und [LEARNQUEST_SPRINTS.md](LEARNQUEST_SPRINTS.md). Beide Dokumente bei **jedem** automatischen Durchlauf auf `main` lesen. Bei Widersprüchen gelten die strengeren Qualitäts- und Archivschutzregeln; keine automatische Freigabe aus diesem Dokument ableiten.

## Zwei unabhängige Spuren

**A – Stabile Releases auf main:** Vor jeder Änderung aktuellen main-Commit, letzte Releases, PRs und Actions kontrollieren. Nur klar spielbare neue Mechaniken oder sichtbar verbesserte 3D-Welten/Grafik im Smartphone-Querformat veröffentlichen. Vorher Godot-Import, Gameplay- und Regressionstests, Webexport, Archivschutz und Pages-Deployment prüfen. Neue freie `skyway-vN/`-URL ausschließlich einmal anlegen, exakten Build-Commit und HTTP 200 für die fünf Dateien nachweisen. Keine reine Versionsnummern-Erhöhung. Experimentelle Charakterarbeit darf fertige unabhängige Releases nicht blockieren.

**B – Experimenteller Charakter in DRAFT PR #111:** 65-Bone-CC0-Rig, Körper-/Kostüm-Skinning und Hoverboard als zusammenhängende Silhouette anhand reproduzierbarer echter 16:9-/19,5:9-Renderbilder verbessern. Solange visuelle Qualitätsabnahme, Clipping, Geräte-FPS und komplette Touch-Runde nicht belegt sind: DRAFT belassen, nicht mergen, nicht veröffentlichen. `V124` im alten Titel reserviert keine Release-Nummer. Erst nach Freigabe gegen den dann aktuellen main synchronisieren und die nächste freie Nummer wählen.

## Unveränderliche Spiel- und Archivregeln

- Touch-Steuerung im Querformat; drei Englischaufgaben vor einer vollständigen Runde.
- Vier Welten, Bosskämpfe, vier Power-ups, Missionen und Fortschritt bewahren.
- Alle alten Skyway-Builds sowie das Unity-Archiv unverändert erhalten.
- Jeder Sprint: Änderung, Akzeptanzkriterien, konkrete Tests, Commit/PR und Ergebnis in `docs/sprints/` dokumentieren; keine unbelegten Erfolgsmeldungen.
- Ohne fertigen Mehrwert keinen Release erzwingen; bei verfügbarer Zeit direkt nächsten sicheren Schritt bearbeiten.

**Hinweis:** Das Anlegen oder Aktualisieren dieser Richtlinie ist eine reine Dokumentationsänderung und **kein** Spielrelease.
