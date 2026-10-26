# LearnQuest 3D — fortlaufende Entwicklungssprints

Stand der Ausgangsbasis: **Skyway V95**, veröffentlicht und in GitHub Actions erfolgreich geprüft am 26.10.2026.

## Arbeitsregel
Entwickle in **aufeinander aufbauenden Sprints**, nicht in isolierten Kleinstkorrekturen. Jeder Sprint besitzt ein sichtbares Ergebnis, Akzeptanzkriterien, Godot-Tests und eine neue **unveränderliche** Skyway-Version. Prüfe vor einer neuen Änderung zuerst `main`, die letzten Commits und Actions-Runs. Bei Fehlschlägen zunächst reparieren. Nach Abschluss **ohne Rückfrage direkt zum nächsten offenen Sprintschritt gehen, soweit die laufende Sitzung dies zulässt**. Die stündliche ChatGPT-Aufgabe dient zum Wiederaufnehmen; sie ist **keine permanent laufende Instanz**.

**Priorität:** ein kommerziell anmutendes, erkennbar hochwertiges **3D-Abenteuerspiel** im **Smartphone-Querformat**. Die vom Nutzer auf einem echten Telefon bestätigte Touch-Steuerung bleibt funktional. Die drei Vokabelaufgaben vor jeder ganzen Runde für Klasse 1–10, die vier Welten, Missionen, Bosskämpfe und Power-ups bleiben erhalten.

## Sprint-Backlog (Reihenfolge)

### Sprint 1 — Figur: deutlicher Qualitäts- und Animationssprung
- [ ] Original glTF-Körpermesh durch hochwertig modellierten, vollständig geriggten und *tatsächlich skinierten* Charakter ersetzen oder sinnvoll erweitern; keine bloße Ansammlung neuer Boxen/Kugeln. Kostenfreie rechtssicher lizenzierte Assets nur mit dokumentierter Quelle/Lizenz.
- [ ] Körper, Gesicht, Haare und Kleidung klar lesbar in Verfolger- **und** Menüperspektive. Flüssige Lean-/Jump-/Boost-Animationen, ohne sichtbares Mesh-Clipping.
- [ ] Godot-Skinning-/Pose-Tests und gut nachvollziehbare visuelle QA-Anleitung; 16:9 iPhone-Grafik/Bildrate prüfen, manuelle Gerätetests nicht als automatisch bestanden ausgeben.

### Sprint 2 — Hoverboard & Action
- [ ] Detailliertes Hoverboard mit plastischer Form, glaubhaften Materialien und dynamischem Schwebeverhalten.
- [ ] Beschleunigung, Sprung, Schild und Spezialangriff durch deutlich sichtbare, optimierte 3D-VFX unterscheiden.
- [ ] Kamera/Charakterkomposition und UI-Freiraum für 16:9/19.5:9 Querformat testen.

### Sprint 3 — Neon City Cinematic
- [ ] Großflächig abwechslungsreiche 3D-Architektur mit überzeugenden Materialien, beleuchteten Fassaden und Tiefe.
- [ ] Atmosphärische, mobile-kompatible Beleuchtung und Schatten/Reflexionsersatz statt teurer Echtzeit-Effekte.
- [ ] Mindestens ein klares „Vorher/Nachher“ bei sichtbarer Rennperspektive; WebGL-Leistung schützen.

### Sprint 4 — Weitere Welten als echte Abenteuerlevels
- [ ] Dschungel/Kristall, Eiswelt und Sternen-Hafen mit eigenständigen Sichtachsen, Spielobjekten und Missionen statt nur umgefärbter Rennspuren.
- [ ] Interaktive Alternativrouten, Plattformen oder Erkundung als neue Spielmechanik mit geeigneter Touchsteuerung.
- [ ] Fortschritt, Levelauswahl, Bonusziele und Bossbelohnungen konsistent halten.

### Sprint 5 — Spielreife & mobile Qualität
- [ ] Übergänge Aufgaben → Level → Resultat → nächstes Level verständlich und motivierend.
- [ ] UI im Querformat mit sicheren Touchzonen, Lesbarkeit sowie optionalen Buttons.
- [ ] Performance, Speicher, Browser-Reload und Fehlertoleranz (Safari/Android) prüfen.

## „Fertig“-Definition für jeden Sprint
1. Die Änderung bringt **sichtbar** bessere Grafik oder eine **wirklich spielbare** Funktion; keine bloßen Ankündigungen.
2. Godot importiert, headless Gameplay-Tests und Webexport sind erfolgreich.
3. GitHub Pages stellt den neuen Build unter einer **neuen Skyway-Version** bereit; Veröffentlichung und Revisionsdatei sind bestätigt.
4. Historische Skyway-Builds und die alte Unity-Version bleiben unverändert.
5. Nächsten offenen Sprintschritt in der laufenden Sitzung direkt beginnen, wenn möglich; andernfalls wird er beim nächsten planmäßigen Task-Durchlauf aufgenommen. **Keine Behauptung durchgehender Arbeit zwischen den Task-Ausführungen.**

## Dokumentation
- Erfolg nur mit überprüftem Commit, Tests und URL melden.
- Keine neuen Kosten oder unklaren Fremd-Asset-Lizenzen.
- Bei mehreren gleichzeitig arbeitenden Prozessen zuerst den aktuellen Branch und die Release-Nummer prüfen, um Versionsüberschreibungen zu vermeiden.

## Sprintprotokoll — 26.10.2026, V97 (PR #84, zunächst ungeprüft)
- Sprint 1, Teilziel **Originalkörper-Skinning**: In der PR wurde der tatsächlich importierte glTF-Körper an ein neues 13-Knochen-Skelett mit vier normierten Gewichten je Vertex gebunden. Die bisherigen V94–V96-Zierpanzer-Rigs bleiben bestehen.
- Separate Godot-Regression prüft Knochenhierarchie, Originalmesh-Oberflächen, normalisierte Gewichte, gewichtete Körperregionen und die Reaktion auf Lenken, Sprung und Turbo. PR- und Release-CI führen sie zusätzlich zum bisherigen Gameplay-Test aus.
- **Abnahme erst nach grüner CI und erfolgreichem V97-Release.** Dies ist kein Abschluss von Sprint 1: Kopf-/Haar-/Kleidungs-Synchronisierung, visuelle Qualität, Clipping und echte iPhone-Querformat-FPS bleiben offen.
- Als nächstes: visueller QA-Vergleich im Querformat und saubere gemeinsame Animation der Kopf-/Haar-/Kleidungsgeometrie. Touch-Gesten, Spielregeln und Alt-Releases bleiben unverändert.
