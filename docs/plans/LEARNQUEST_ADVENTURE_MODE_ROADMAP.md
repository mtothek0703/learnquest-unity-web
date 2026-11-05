# LearnQuest 3D – Action-Adventure mit Hoverboard und frei begehbaren 3D-Bereichen

**Produktentscheidung: 05.11.2026.** Neue verbindliche Spielrichtung auf Wunsch des Nutzers. Dieses Dokument ist ein **Implementierungsplan, kein fertiges Feature und kein Release**.

## 1. Produktziel und Spielgefühl

LearnQuest soll ein spannendes, mobil gut steuerbares **3D-Action-Adventure** ab Klasse 1 sein, kein reiner Endless Runner und keine Lernsoftware mit bloßem 3D-Anstrich.

- **Hoverboard:** schnelle Fahrten, Abzweigungen, Turbo, Sprünge, Gefahren, Bosssequenzen, Tricks.
- **Zu Fuß:** selbstbestimmte Bewegung in **echten räumlichen 3D-Arealen**, Sammelobjekte, Plattformen, Erkunden, ein klar erkennbares Missionsziel, Kämpfe gegen Fantasy-/Robotergegner und versteckte Belohnungen.
- **Übergänge:** in einer zusammenhängenden Spielrunde fahren -> sicher absteigen -> zu Fuß spielen -> wieder aufsteigen -> Rundenergebnis. Kein doppeltes Fortschrittskonto und kein separater Spielstart.
- **Lernintegration:** weiterhin **genau drei verpflichtende Englischaufgaben vor Beginn einer vollständigen Runde**. Richtig gelöste Aufgaben können Energie/Spezialfähigkeiten oder Zusatzbelohnungen freischalten. Im laufenden Actionabschnitt **keine wiederkehrenden aufpoppenden Pflicht-Vokabel-Dialoge**, die Steuerung oder Kämpfe unterbrechen. Optional spätere Rätsel mit vorgelesenen Hinweisen für Klasse 1; Englisch/Deutsch/Mathe als Erweiterung, ohne das bestehende Aufgabenmodell zu brechen.
- **Langzeitmotivation:** Welten, Sammlerstücke, Missionssterne, kosmetische freischaltbare Skins, Gegner/Geheimnisse mit Wiederspielwert; Belohnungen pro Runde nicht mehrfach farmbar.

## 2. Bestandsaufnahme / ausdrücklich unverändert lassen

Die aktuelle Codebasis ist **Godot** unter `godot/` in `mtothek0703/learnquest-unity-web`. `godot/world.gd` koordiniert derzeit vier Welten, Training -> Race -> Results, die dynamische Chase-Kamera und Touch-Gesten. `godot/touch_gestures.gd` interpretiert **Runner-spezifische** Lenken/Sprung/Power-up-Gesten. `godot/rider_character.tscn` ist die bestehende Spielfigur mit Hoverboard.

Schützen: funktionierende V154/weitere immutable `skyway-vN/`-Builds, Unity-Archiv, alle vier Welten (Neon City, Kristall-Canyon, Sternen-Hafen, Aurora-Gletscher), Bosse, vier Fähigkeiten, Touch-Steuerung, Klassenwahl, drei Englischaufgaben und bisherige XP-/Stern-Belohnungen. `main` und bereits offene DRAFT-PRs vor Änderungen prüfen. Keine Versionsnummer im Voraus reservieren.

Die experimentelle 65-Bone-Figur aus PR #111 ist **keine Voraussetzung** für den ersten begehbaren Abschnitt. Der neue Abenteuer-Modus muss mit dem aktuellen stabilen Spieler-Asset laufen. Nicht auf einen unfertigen Charakter-Branch warten.

## 3. Technischer Ansatz: modular statt bestehenden Runner umzuschreiben

**GameSession / AdventureDirector:** Der bestehende Rennablauf ist vorläufig Eigentümer der Session (Klasse, Welt, XP, Energie, Mission, Sterne, drei Eingangsfragen). Ein kleiner Controller koordiniert zusätzlich `RACE -> TRANSITION -> ON_FOOT -> TRANSITION -> RACE/RESULTS`. Unbedingt vorhandene `phase`-, `started`- und `quiz_active`-Tests zuerst lesen. Die erste Integration wird hinter einem standardmäßig deaktivierbaren Feature-Schalter und nur in einem vorgesehenen Neon-City-Abschnitt getestet; bestehende Versionen bleiben lauffähig.

**Getrennte 3D-Szene:** Neue Dateigruppe `godot/adventure/` mit z. B.:
- `adventure_area.tscn` – statischer kleiner 3D-Bereich, Boden, Treppen/Plattformen, Kollisionsformen, Beleuchtung, Portal.
- `on_foot_controller.gd` – `CharacterBody3D` mit geerdeter Bewegung, Gravitation, Beschleunigung, Fall/Respawn und Springen; kein Runner-Spurzwang.
- `adventure_camera.gd` – eigenständige Third-Person-Follow-Kamera mit Kollision/Abstandsbegrenzung; übernimmt nicht die Race-Chase-Parameter.
- `adventure_touch.gd` und `adventure_hud.gd` – linker virtueller Joystick oder linkes Drag-Feld für Bewegung, rechts `SPRUNG`, `ANGRIFF`, `INTERAKTION`; klar getrennt von `touch_gestures.gd`. Tastatur W/A/S/D bzw. Pfeile, Space, E für Desktop-QA. Rechts eine zugängliche Kamerasteuerung nur nach Bedarf; zuerst stabile automatische Third-Person-Kamera.
- `mission_state.gd` – eindeutige Aufgabe, Checkpoints, Sammelobjekte und einmalige XP-/Stern-Vergabe.
- `encounter_robot.gd` – später im zweiten Umsetzungspaket einfacher, telegraphierter Robot-Gegner mit verständlichem Angriff/Abwehr-Feedback.

Sichtbar wird dieselbe bekannte Spielfigur genutzt; das Board wird **nur im Gehmodus versteckt**, sofern technisch sauber vom Charakter trennbar. Kein neuer Charakter oder kostspieliges Asset als Voraussetzung. Auf und Absteigen mit kurzer Animation; für den ersten vertikalen Slice reicht eine sauber ausgeblendete Übergangssequenz statt vorgetäuschter hochwertiger Animation.

**Laufzeit/Rendering:** Nur eine aktive Spielsimulation; Race-Hazards, Bosse und scrolling scenery während `ON_FOOT` anhalten, nicht nur verstecken. Die Abenteuer-Szene nur bei Bedarf instanziieren oder ausreichend klein halten. Kein paralleles dauerlaufendes Open-World-Level, keine unkontrollierten `_process`-Loops, keine neuen Drittanbietergebühren oder Lizenzrisiken. Godot Web GL Compatibility und Safari Querformat bleiben Ziel.

## 4. Erster spielbarer Vertical Slice: Neon City – Dachterminal

**Feste, testbare Spielrunde** (Wegpunkte und Anzahl sind Entwurfsziele, noch nicht implementiert):

1. Klassen-/Weltwahl -> **3 Englischfragen** -> normaler, verkürzter Rennabschnitt. Bestehende Boss-/Runner-Mechanik unverändert.
2. Markiertes **Ankunftsportal** hält das Rennen kontrolliert an. Ein kurzer, nachvollziehbarer Absteigeübergang wechselt in die begehbare Szene.
3. Die Figur bewegt sich frei im 3D-Areal: Boden, zwei unterschiedliche Höhen, eine sichere Sprungplattform, sichtbare Begrenzungen und Checkpoint. Keine Kulissen-Diorama-Kamera: tatsächliche freie Fortbewegung.
4. Kleine Mission: **3 Energiekristalle sammeln**, **2 Schalter aktivieren** und das Ausgangsportal öffnen. Der zweite Schalter erfordert einen einfachen Sprung und einen anderen Weg, damit das Laufen spielrelevant ist.
5. **Ein Robot-Gegner** mit klar angekündigtem Angriff, begrenzter Gesundheit und einer kindgerechten Attacke; Schild/Spezialenergie aus dem bestehenden Lern-/Runner-System in sinnvoller, nicht übermächtiger Form nutzen. Kampf erst nach erfolgreichem Laufen/Interagieren integrieren.
6. Ausgangsportal -> automatisches, verständliches Wiederaufsteigen -> bestehender Renn- oder Bossabschluss -> ein einziges Ergebnis mit XP, Missionsstern und Sammelfortschritt.

**Abnahme des ersten Laufs:** durchgängig nach drei Eingangsfragen spielbar; Portalwechsel verliert weder XP noch Weltzustand; Figur ist mit Touch und Tastatur frei beweglich, kann springen/landen und fällt nicht durch Boden/Plattformen; `INTERAKTION` löst nur in Reichweite aus; Kristalle/Schalter öffnen den Ausgang; Neustart/Retry setzt alle Ziele zurück; keine doppelte Belohnungsvergabe.

## 5. Umsetzungsreihenfolge – jeweils ein eigener getesteter Sprint

### A0 – Architektur- und Testgerüst (als Nächstes)
- [ ] Main-Branch, offene PRs, Automations und CI prüfen; aktuelle Runner-Zustandsmaschine, Save-System, `rider_character.tscn`, Touch-Routing, Kameralogik, HUD und Reset identifizieren.
- [ ] `docs/sprints/`-Sprintprotokoll mit konkret nachgewiesenen Schnittstellen, Regressionsrisiken, Testmatrix und Designentscheidungen.
- [ ] Testbarer, abgeschalteter Übergangscontroller; alter Runner läuft auf Default-Einstellung **bitgleich**.

### A1 – Wirklich frei laufen und springen
- [ ] Neon-Testarena als 3D-Szene mit Boden/Plattform/Checkpoint, echte `CharacterBody3D`-Kollision.
- [ ] Tastatur und mobile getrennte Eingaben; Third-Person-Follow, Kamera-Kollision, stabile Steuerung in 16:9 und 19,5:9.
- [ ] Wiedereintritt und Respawn. Vorher/Nachher-Screenshots statt nur Quellcodebehauptungen.

### A2 – Hoverboard-Abstieg, Mission und Aufstieg
- [ ] Nach drei Quizfragen in derselben Spielrunde kontrollierter Wechsel vom echten Runner in Arena und zurück.
- [ ] Drei sammelbare Objekte, zwei Interaktionsschalter, Portal-Freigabe, Checkpoint, einfache Quest-Anzeige.
- [ ] XP/Energie/Stars teilen sich eine Session, Reward-Duplikate verhindern; Retry, Neustart, Tab-Wechsel.

### A3 – Kindgerechtes Kampf-Grundsystem
- [ ] Ein einfacher patrouillierender Roboter, Warnanimation/Telegraph, Nah-/Energieangriff, Schadensrückmeldung, Ausweichen und Checkpoint.
- [ ] Bestehende Schild-/Angriffsenergie integrieren; Schwierigkeit nach Schulstufe skalieren, keine harten Gewaltbilder.
- [ ] Sichtbare Belohnung und Rückkehr zur Rennstrecke.

### A4 – Motivation und Spielqualität
- [ ] Echte 3D-Umgebung Neon City: lesbare Orte, vertikale Plattformen, klare Blickführung, kurze Transitionen.
- [ ] Bestenliste nur falls später gewünscht, zunächst Geheimkristalle, Missionserfolg, Skins und Wiederholungsanreize.
- [ ] Mobile HUD-Überlappungen, Gesten, FPS/Speicher, Safari Reload, Fokusverlust und Speicherstand prüfen.

### A5 – Ausrollen auf bestehende vier Welten
- [ ] Kristall-Canyon: Höhlen, kletter-/sprungbasierte Wege, Geheimschätze.
- [ ] Sternen-Hafen: Raumstationsgänge, Tür-/Energie-Rätsel, Roboter.
- [ ] Aurora-Gletscher: Eishöhlen, Rutsch-/Sprungplattformen, Eis-Boss.
- [ ] Neue Missionsmechaniken je Welt, nicht nur anderes Farbschema. Altes Hoverboard-Gameplay bleibt erhalten.

## 6. Strenge Test- und Veröffentlichungsregeln

Je Code-Sprint möglichst klare Godot-Testdatei und CI-Aufruf:
- Drei Pflichtfragen und unveränderte bestehende Runner-Runde im Feature-off-Modus.
- On-foot-Lauf, Schwerkraft, Hinderniskollision, Sprung und Checkpoint; Tastatur/Touch und Portrait-Sperre oder sichere Fallback-Ansicht.
- Vorher/Nachher-Aufnahmen aus **echtem Godot-Render** beider Querformate; realistischer manueller iPhone-Safari-Test separat (FPS, Button-Zonen, wechselnde Orientierung, Fokusverlust).
- Zustandsübergänge und Race-Pause, Missionsreset, Boss-/Rewardsystem, keine zusätzliche Pflichtfrage beim Wiedereintritt.
- Bestehende Godot-Import-/Gameplay-/Webexport-/Archivschutz-CI vor Merge; kein `main`-Release ohne grüne Tests und echte Feature-QA.
- Nur neue, noch nicht verwendete unveränderliche `skyway-vN/`-URL, exakte Buildrevision und HTTP 200 für HTML, JS, WASM, PCK und Revisionsdatei nachweisen; alle historischen Versionen und das Unity-Archiv schützen.
- **Kein V155 oder anderes Release behaupten, solange kein nachgewiesenes Deployment vorliegt.**

## 7. Automatisierte Weiterentwicklung und Berichterstattung

Die bestehende stündliche Sprint-Automation soll **bei jedem Lauf dieses Dokument auf main lesen**. Neben stabilen Verbesserungen und dem **getrennten** Charakter-DRAFT #111 gilt der Abenteuer-Modus als eigenständige priorisierte Gameplay-Spur **A**: erst **A0 -> A1 -> A2 -> A3**, anschließend A4/A5. Pro Durchlauf die nächste konkrete, mit aktuellem main kompatible Code-/Testaufgabe abschließen; nicht nur Dokumente ergänzen. Eigene Branches/PRs, keine direkte Übernahme veralteter Kamera-/Charakter-PRs. Nach jeder tatsächlich geprüften Zwischenetappe im Status ausdrücklich unterscheiden: Planung, Code committed, CI bestanden, auf Telefon getestet, live veröffentlicht.

## 8. Definition of Done für das neue Spielprinzip

**Nicht erreicht**, bis ein Kind auf einem echten Telefon die **gesamte** Folge ohne externe Eingriffe spielen kann: 3 Vokabeln -> Hoverboard -> absteigen -> frei bewegen/springen -> Schalter/Kristalle -> Roboterkampf -> aufsteigen -> Boss/Resultat, mit verständlichen Kontrollen und störungsfreiem Fortschritt. Ein Architekturplan oder isolierter Kameratest zählt ausdrücklich **nicht** als fertiger Adventure-Modus.
