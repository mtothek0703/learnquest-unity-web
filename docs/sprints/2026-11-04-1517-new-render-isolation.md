# Sprint 2026-11-04 15:17 – isolierte Neuansicht (PR #111)

## Änderung
Das lokale A/B-Renderprüfwerkzeug bietet zusätzlich zur bisherigen isolierten Altansicht nun eine isolierte Neuansicht. Die Neuansicht zeigt das vollständige neue Bild ohne Clip-Maske; Escape kehrt zur geteilten Ansicht zurück. Die Bedienelemente signalisieren ihren Zustand mit aria-pressed. Keine Gameplay-, Rig- oder Releaseänderung.

## Akzeptanz und Prüfung
- Quellcode nach GitHub-Commit auf Branch erneut abrufen; Neuansicht, Rückkehr zur geteilten Ansicht und beide Schaltflächen kontrollieren.
- Statische Präsenzprüfungen der Zustandslogik (fünf Zeichenketten) vor Commit bestanden.
- Echter Browser-/Touchtest, reale Renderbilder, visuelle Charakterabnahme, Godot-Import/Tests, Webexport, Pages, Archiv- und Geräte-FPS-Prüfungen **nicht** ausgeführt und ausdrücklich nicht als bestanden gewertet.

## Spur A
Kein neues Gameplay oder sichtbar verbessertes 3D-Level auf main, deshalb keine neue unveränderliche Skyway-URL. Historische Versionen und Unity-Archiv nicht angefasst.

## Spur B
PR #111 bleibt DRAFT/VISUAL HOLD. Code-Commit: 7471ab99f23eef936c4e116260881fd848e91147. Nächster sinnvoller Schritt: echte pose- und kameragleich gerenderte 16:9-/19,5:9-Bilder des Charakters, konkrete Modellkorrekturen und unabhängig davon ein echtes spielbares Feature für main.
