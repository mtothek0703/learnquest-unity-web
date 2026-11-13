# LearnQuest Adventure A2 – 06.11.2026, 20:11

## Ausgangslage
Primary GitHub mtothek0703 / michael_kohler1@yahoo.de; Repository mtothek0703/learnquest-unity-web. Alle vier Pflichtdokumente auf main gelesen. Main 3117869390c6f3dff6409bfde1f64c2d184b0853; bestehender DRAFT PR #157 / Branch feature/adventure-a1-walkable-neon-testbed-20261106-19 (kein paralleler A1-Branch). Branch ist gegenüber main um einen CI-Wartungscommit zurück; kein Merge/Release. Vor Änderung letzter PR-Head 9225b1504e74c5883c280528f21f2b2511fe9284; zugehöriger Godot PR validation Run 42275066398 erfolgreich. Das belegt nur die alte Bridge-Version, nicht diese Missionserweiterung.

## Implementierung
In neon_walk_testbed.gd drei räumlich getrennte Kristalle und zwei Schalter als sichtbare 3D-Objekte hinzugefügt. INTERAKTION-Button und Taste E arbeiten ausschließlich innerhalb 2m; jedes Objekt lässt sich nur einmal einsammeln/aktivieren. HUD zählt 0/3 und 0/2. AUFSTEIGEN löst erst nach 3 Kristallen UND 2 Schaltern die Rückkehr aus. reset_mission() stellt alle fünf Objekte und den Sperrzustand wieder her. Runner-Input, bestehende Welten und alte Skyway-Builds nicht geändert. Test adventure_bridge_test.gd erweitert um gesperrten Portalversuch, fünf echte Reichweiteninteraktionen und erfolgreiche Rückkehr.

## Akzeptanzkriterien
- Keine Rückkehr vor allen fünf Zielen; einmalige Interaktion in Reichweite; HUD und Reset konsistent.
- Drei Pflichtfragen vor Race; Hoverboard/Walking/Rückkehr erhält XP, Power, Leben und Strecke.
- Godot-Import, Headless-Bridge-Test, bestehende Regressionen, Webexport und reale Querformat-Renderbilder müssen vor Merge bestehen.

## Tatsächliche Prüfung und Ergebnis
Vor Änderung GitHub CI Run 42275066398: success für vorherigen PR-Head 9225b150. Für die neuen Commits d35ca2b939d8c1dcca3ecee71bc458e4f0cba600 und 29dcd1495640004f0a2fc67285e53e5cac9fa757 wurde hier kein Godot-Lauf ausgeführt; neue PR-CI ausstehend. Keine iPhone-/FPS-/Touch-QA, kein Pages-Release. Weiterhin DRAFT. Nächster Schritt: CI der neuen Revision prüfen, ggf. Fehler reparieren, danach echte Spielerfigur, Mission/XP und A3-Roboterkampf.
