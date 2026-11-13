# Adventure A1/A4 – bestehende Spielfigur im Gehmodus (09.11.2026, 08:17 CET)

## Ausgangslage und Schutz
Primary GitHub: mtothek0703 / michael_kohler1@yahoo.de; Repository mtothek0703/learnquest-unity-web; bestehender DRAFT PR #157 auf feature/adventure-a1-walkable-neon-testbed-20261106-19. Vor der Änderung alle vier Pflichtdokumente auf main gelesen; main 46bfea3ecbfa4db8cc755df8d7fab201706d8059. Vorheriger PR-Head 8971ee5; dessen Godot PR CI #42555380615 success. Kein Merge/Rebase/Release.

## Änderung
- Die Neon-City-Arena instanziiert die bereits im stabilen Projekt vorhandene lizenzierte res://models/rider.gltf als eigenständiges visuelles Kind des CharacterBody3D.
- Größenanpassung anhand der importierten Mesh-AABB, vertikale Zentrierung; ursprüngliche Kapsel bleibt nur als Fallback, wenn die Ressource nicht ladbar ist.
- Keine Instanziierung von rider_character.tscn, LegacyRider oder Hoverboard. Runner-Assets und Runner-Eingaben bleiben unangetastet.
- Adventure-Bridge-Regression prüft den tatsächlichen WalkingVisual-Knoten, versteckte Kapsel und das Fehlen der Runner-Board-Knoten.

## Akzeptanzkriterien
1. Godot 4.4.1 importiert die vorhandene glTF-Figur ohne Parserfehler.
2. Die Arena zeigt die Figur ohne Board, während CharacterBody3D-Kollision, Touch, Sprung, Kamera und Runner-Rückkehr erhalten bleiben.
3. adventure_bridge_test.gd läuft headless erfolgreich; keine Regression der drei Pflichtfragen oder der vier Welten.
4. Vor Merge/Release zusätzlich realer Godot-Webexport, 16:9-/19.5:9-Rendervergleich und iPhone-Safari-Querformat-Test.

## Tatsächlich ausgeführte Prüfungen
GitHub-Connector: Primary-Konto, Repository, PR-Head, Main, vier Dokumente, vorhandenes rider.gltf und die relevanten Skripte geprüft. Vorherige CI #42555380615 war erfolgreich. **Neue Godot-Import-/Headless-/Webexport-/Render-/iPhone-Tests in diesem Durchlauf nicht ausgeführt**; neue PR-CI abwarten. Der Code ist experimentell, visuelle Qualität/Clipping und tatsächliche Godot-Importfähigkeit sind noch nicht abgenommen.

## Commits
Gameplay 0f492222eb4198727081aa05295a183334bacf5b, AABB-Fix 96f994cf9ea1cb2e522bb9051a040d0c3884b414, Regression 899121e777e26e948d438bd321eaf134aedf50c6. PR #157 bleibt DRAFT. Kein Skyway-Release.

## Nächster Schritt
Neue PR-CI prüfen, eventuelle Parser-/Importfehler beheben, danach die Figur in echten Godot-Renderbildern prüfen; keine unbelegten visuellen Erfolgsbehauptungen.
