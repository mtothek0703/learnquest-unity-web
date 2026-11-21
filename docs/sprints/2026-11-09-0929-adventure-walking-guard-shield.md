# LearnQuest Adventure – 09.11.2026, 09:29 CET – sichtbarer Gehmodus-Schild

## Ausgangslage
Primary GitHub mtothek0703 / michael_kohler1@yahoo.de, Repository mtothek0703/learnquest-unity-web, bestehender DRAFT PR #157 (feature/adventure-a1-walkable-neon-testbed-20261106-19). Main 46bfea3ecbfa4db8cc755df8d7fab201706d8059, PR war 2 Commits dahinter; vier Pflichtdokumente auf main gelesen. Vorheriger PR-Head 7842673 hatte Godot PR validation #42578543421: success.

## Änderung
Der bisherige ABWEHR-Effekt färbte nur das provisorische Kapselmaterial ein, obwohl diese Kapsel nach dem Import von rider.gltf verborgen wird. Eine eigene transparente WalkingShield-Meshkugel um die CharacterBody3D-Figur zeigt aktive Abwehr nun unabhängig vom importierten Körpermaterial. Die neue Regression prüft initial unsichtbar, bei aktivem Guard sichtbar und nach Ablauf wieder unsichtbar. Keine Runner-/Hoverboard-/Archivdateien geändert.

## Akzeptanzkriterien
- Abwehr im Gehmodus ist am echten glTF-Körper erkennbar, ohne dessen Materialien zu ändern.
- Schild erscheint nur während robot_guard > 0.
- Runner-Touch, drei Quizfragen, vier Welten, Boss- und Power-up-Logik bleiben unberührt.
- Import, Headless-Gameplay, Webexport, echte 16:9/19.5:9-Bilder und iPhone-Safari vor Merge/Release separat nachweisen.

## Tests und Ergebnis
Code-/Regressionstest ergänzt, jedoch **kein lokaler Godot-Test ausgeführt**. Die GitHub-CI für diesen neuen Head ist zum Zeitpunkt dieses Protokolls noch nicht bestätigt. Frühere erfolgreiche CI belegt **nicht** diesen Änderungssatz. Visuelle Darstellung, FPS und Touch auf iPhone nicht abgenommen. PR bleibt DRAFT; kein Merge, kein Skyway-Release.

## Commits
Gameplay d527b771c19c3edac38418bf8c83f4fa2b9793dc; GDScript-Sicherheitskorrektur f176b75ad0074ca00d27581e134d88e0b729623e; Regression 8598eff8707b32bf4421c9f005a225776277dda7. Nächster Schritt: neue CI prüfen und ggf. korrigieren, echte Renderbilder und Geräte-QA nachholen.
