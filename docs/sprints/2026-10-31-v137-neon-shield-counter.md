# LearnQuest V137 – Neon-Schild-Konter (stabiler Kandidat, 31.10.2026)

## Ziel und echte Spielfunktion
Ein **neu aktivierter** Energieschild in den letzten 0,60 Sekunden eines angekündigten Neon-Dirigent-Strahls kann genau **einen** Puls reflektieren, sofern der Spieler in der angekündigten Spur bleibt und nicht springt. Das trifft den Boss für 1 Kernpunkt und gibt +35 XP. Der vorhandene Schild kostet unverändert 30 Energie. Zu frühe Schilde schützen weiterhin, reflektieren aber nicht; Ausweichen zählt nur für die unabhängige 3er-Ausweichserie. Eine Schildaktivierung kann niemals mehrere Pulse kontern. Der bereits vorhandene Super-Angriff und alle vier Fähigkeiten bleiben erhalten.

## Echte 3D-Grafik
Ein neuer, zeitlich begrenzter, räumlich wachsender cyanfarbener Torus am Bosskern zeigt die Reflexion an; der bestehende Boss reagiert zusätzlich auf den Treffer. Kein neues Fremdasset, keine neuen Touch-Gesten oder Kollisionskörper. Ring ist im Leerlauf unsichtbar, nach 0,8 s wieder deaktiviert. Das Smartphone-Querformat-HUD zeigt während des präzisen Zeitfensters „KONTER!“. Der Ergebnisbildschirm nennt die erzielten Reflexionen.

## Abnahme-Gates
- [ ] Vollständige PR-Godot-Regression einschließlich neuer Boss-/Schild-Zeitfenster- und 3D-Ring-Tests.
- [ ] Headless-Gameplay, Godot-Webexport, vorhandene Querformat-Renderprüfungen.
- [ ] Historischer Pages-/Unity-Archivschutz.
- [ ] **12 echte 1280×720-/1170×540-OpenGL-Bilder**: je Perspektive Boss abwesend, Boss normal und Boss mit reflektiertem 3D-Schockring. Der Render-Test prüft eine tatsächliche Pixeländerung des neuen Rings. Zusätzlich mobile HUD-Lesbarkeit; automatische Bilder sind keine echte iPhone-Abnahme.
- [ ] Erst bei allen erforderlichen grünen Gates Merge nach main und einmalige Veröffentlichung unter **skyway-v137/**; exakte Commit-ID in build.txt und HTTP 200 für fünf Dateien prüfen. Bis dahin V136 unverändert.
- [ ] Reale iPhone-Safari-FPS, Clipping und vollständige Drei-Fragen-Touch-Spielrunde weiterhin separat prüfen.

**Spur B:** Experimenteller PR #111 bleibt DRAFT/VISUAL HOLD; Titel V124 reserviert keine Release-Nummer. Keine alten Skyway-Versionen oder Unity-Archive verändern.
