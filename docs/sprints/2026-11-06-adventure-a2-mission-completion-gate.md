# LearnQuest Adventure A2 – Missionsabschluss nur nach allen Zielen (06.11.2026, 12:16 CET)

## Prüfung und Ausgangspunkt
Primary GitHub `mtothek0703` (`michael_kohler1@yahoo.de`), Repository `mtothek0703/learnquest-unity-web`, Branch `feature/adventure-a1-walk-arena-20261105-2111` (DRAFT PR #146, ursprünglich auf main `0e01246620d33a9afcbb617152748adac4402993` erstellt). Vor der Änderung die vier Pflichtdokumente von main gelesen. Kein Merge nach main.

## Konkreter Fehler und Änderung
`adventure_mission.gd::is_complete()` meldete nach drei Kristallen bereits Missionsabschluss, obwohl die beiden verpflichtenden Schalter noch nicht aktiviert waren. Jetzt ist die Abschlussbedingung identisch mit `can_open_portal()`: drei Kristalle **und** zwei Schalter. Das verhindert eine vorzeitige XP-/Ergebnis-Freigabe bei späterer Integration. Portalinteraktion und Runner sind nicht verändert.

## Akzeptanzkriterien
- Drei Kristalle allein ergeben keinen vollständigen Missionsabschluss.
- Erst nach beiden Schaltern gilt die Mission als abgeschlossen.
- Wiederholtes Aktivieren zählt nicht doppelt.
- Nach Reset ist der Abschluss wieder gesperrt.

## Tatsächlich ausgeführte Prüfungen
- GitHub-Quellcode von main und PR #146 gelesen; Logikfehler durch statische Codeprüfung festgestellt; Änderung und Regressionstest committed.
- Regressionstest: `godot --headless --path godot --script res://adventure/adventure_completion_regression_test.gd`.
- **Nicht ausgeführt:** Godot-Import/Headless-Test, Webexport, echte 16:9-/19.5:9-Renderbilder, iPhone-Safari, Archivschutz, Pages. Lokale Godot-Binary nicht verfügbar; GitHub-Connector führt keinen Godot-Prozess aus.
- Keine Behauptung über bestandene Tests oder spielbare Gesamtintegration.

## Commits und Ergebnis
- Logikfix: `a26d5b638affd70c8c3130f9c598bb0829e6e5ea`
- Regressionstest: `6c598c50a4a13d4c6e0095d635492baa84638f5d`
- PR #146: https://github.com/mtothek0703/learnquest-unity-web/pull/146
- Kein Merge, kein Skyway-Release.

## Nächster Schritt
Godot 4.4.1 CI für den Arena-Branch einrichten/ausführen und dann Session-Transition und Race-Pause aus den separaten DRAFT-PRs kontrolliert mit der Arena verbinden. PR #111/#133 nicht mergen.
