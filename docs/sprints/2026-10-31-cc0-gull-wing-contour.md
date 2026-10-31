# LearnQuest – CC0-Board: zusammenhängende Gull-Wing-Kontur (31.10.2026, DRAFT)

## Ursache und Umsetzung
Die bisherigen seitlichen 3D-Stabilisatoren waren im Verfolgerbild sehr flach. In der **vorhandenen geschlossenen Original-ArrayMesh-Geometrie** wurde auf beiden Seiten eine 0,12-m-Auswölbung der Außenkante mit weichem Auslauf an Bug und Heck sowie eine 0,028-m-Unterschneidung der Unterseite modelliert. Ein per Vertex schattierter Lichtverlauf macht die tatsächliche 3D-Kante sichtbar, ohne zusätzliche Meshes, Drawcalls, Collider, Fremdassets oder neue Touch-Eingaben. Maximalbreite, Turbinen, 65-Bone-CC0-Figur und Board-Animation bleiben erhalten.

## Regression und Freigabe
- [ ] Vollständige Godot-CI einschließlich Gameplay, 65-Bone-Tests und Webexport.
- [ ] Die erweiterte Hoverboard-Regression prüft **echte Vertex-Positionen** und Farbwerte des GPU-Meshes auf beiden Seiten, symmetrische Kontur und geschlossene Flächen.
- [ ] Echte 1280×720-/1170×540-Renderbilder gegen vorherigen DRAFT-Stand visuell prüfen. Technische Geometrie ist noch **keine** optische Gesamtfreigabe.
- [ ] Reale iPhone-FPS, Clipping und vollständige Drei-Fragen-Touch-Spielrunde weiterhin offen.

**Strikte Trennung:** PR #111 bleibt DRAFT/VISUAL HOLD. Kein Merge, keine Versionsnummer reserviert; stabile V136 und sämtliche alten Skyway-/Unity-Archive bleiben unverändert. Spur A entwickelt unabhängig den V137-Kandidaten PR #125.
