# LearnQuest V137 – Neon-Schild-Konter (stabiler Kandidat, 31.10.2026)

## Ziel und echte Spielfunktion
Ein **neu aktivierter** Energieschild in den letzten 0,60 Sekunden eines angekündigten Neon-Dirigent-Strahls kann genau **einen** Puls reflektieren, sofern der Spieler in der angekündigten Spur bleibt und nicht springt. Das trifft den Boss für 1 Kernpunkt und gibt +35 XP. Der vorhandene Schild kostet unverändert 30 Energie. Zu frühe Schilde schützen weiterhin, reflektieren aber nicht; Ausweichen zählt nur für die unabhängige 3er-Ausweichserie. Eine Schildaktivierung kann niemals mehrere Pulse kontern. Der bereits vorhandene Super-Angriff und alle vier Fähigkeiten bleiben erhalten.

## Echte 3D-Grafik
Ein neuer, zeitlich begrenzter, räumlich wachsender cyanfarbener Torus am Bosskern zeigt die Reflexion an; der bestehende Boss reagiert zusätzlich auf den Treffer. Kein neues Fremdasset, keine neuen Touch-Gesten oder Kollisionskörper. Ring ist im Leerlauf unsichtbar, nach 0,8 s wieder deaktiviert. Das Smartphone-Querformat-HUD zeigt während des präzisen Zeitfensters „KONTER!“. Der Ergebnisbildschirm nennt die erzielten Reflexionen.

## Abnahme-Gates
- [ ] Vollständige PR-Godot-Regression einschließlich Boss-/Schild-Zeitfenster-, Einmal-pro-Schild-, Gegen-Spur-, frühem Schild-, letztem Boss-Kern- und 3D-Ring-Test.
- [x] Headless-Gameplay, Godot-Webexport und Querformat-Renderprüfungen bestanden.
- [x] [PR-Archivschutz 41243384842](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41243384842) bestanden.
- [x] **12 echte 1280×720-/1170×540-OpenGL-Bilder**: [Artefakt 13057949224](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41243270342/artifacts/13057949224) heruntergeladen und visuell geprüft. Der 3D-Schockring verändert 10.345 Chase- und 8.307 Oblique-Pixel bei 1280×720 (>25 RGB-Maxkanal). Kein Ersatz für reale iPhone-Abnahme.
- [ ] Erst bei allen erforderlichen grünen Gates Merge nach main und einmalige Veröffentlichung unter **skyway-v137/**; exakte Commit-ID in build.txt und HTTP 200 für fünf Dateien prüfen. Bis dahin V136 unverändert.
- [ ] Reale iPhone-Safari-FPS, Clipping und vollständige Drei-Fragen-Touch-Spielrunde weiterhin separat prüfen.

**Spur B:** Experimenteller PR #111 bleibt DRAFT/VISUAL HOLD; Titel V124 reserviert keine Release-Nummer. Keine alten Skyway-Versionen oder Unity-Archive verändern.

## Release-Korrektur
PR #125 als `32e7aa9c` nach grüner CI gemergt. Erste Main-Release-CI `41243648861` scheiterte ausschließlich am alten 8-PNG-Zähltest nach erfolgreich gerenderten zwölf Bossbildern. Der Release-Workflow erwartet jetzt zwölf PNGs; V137 wird **erst nach erfolgreicher erneuter Pages-CI** als live bezeichnet.
