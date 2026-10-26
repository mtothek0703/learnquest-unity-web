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

## Sprintprotokoll — 26.10.2026, V97 (PR #84, veröffentlicht und automatisiert geprüft)
- Sprint 1, Teilziel **Originalkörper-Skinning**: In der PR wurde der tatsächlich importierte glTF-Körper an ein neues 13-Knochen-Skelett mit vier normierten Gewichten je Vertex gebunden. Die bisherigen V94–V96-Zierpanzer-Rigs bleiben bestehen.
- Separate Godot-Regression prüft Knochenhierarchie, Originalmesh-Oberflächen, normalisierte Gewichte, gewichtete Körperregionen und die Reaktion auf Lenken, Sprung und Turbo. PR- und Release-CI führen sie zusätzlich zum bisherigen Gameplay-Test aus.
- [x] **Technisches Teilziel erreicht:** Original-glTF-Körpermesh ist an 13 echte Knochen und vier normalisierte Skin-Gewichte pro Vertex gebunden. GitHub Actions Godot-Test, Gameplay-Integration, Webexport und Veröffentlichung waren erfolgreich (Main `e1dd1f94a76fdbaf751713bcc4f9b1caa8a69be8`, Actions-Lauf `40348485601`, `skyway-v97/` mit HTTP 200 für fünf Dateien).
- [ ] **Sprint 1 insgesamt offen:** Modellierungsqualität, Synchronisierung von Kopf/Haaren/Kleidung, Clipping und reale iPhone-Querformat-FPS sind nicht abgenommen. Automatische Skinning-Tests sind kein Ersatz für die visuelle Prüfung.
- Die Veröffentlichung bewahrte laut Actions-Protokoll 94 historische Versionsverzeichnisse und die bestehende Unity-Webseite.
- Als nächstes: visueller QA-Vergleich im Querformat und saubere gemeinsame Animation der Kopf-/Haar-/Kleidungsgeometrie. Touch-Gesten, Spielregeln und Alt-Releases bleiben unverändert.

## Sprintprotokoll — 26.10.2026, V98 (Implementierung zur CI-Prüfung)

- Sprint 1, offener Teilbereich **Kopf-/Kostüm-Synchronisation**: V93-Kopfhelm, Gesicht und Haargruppen lesen jetzt die Pose des echten 13-Knochen-Originalkörper-Skeletts, statt unabhängig von dessen Kopf zu rotieren. Die bereits vorhandenen detaillierten Jacken-, Mantel-, Exosuit- und Umhanggruppen folgen einer gewichteten Brust-/Hüftpose. Eigene Haar-, Stoff- und Reaktoranimationen bleiben aktiv.
- Ein eigenständiger Godot-Regressionstest prüft tatsächliche gemeinsame Kopf-, Gesichts- und Haartransformationen, sichtbare Brust-/Mantelbewegung, Pose-Reihenfolge, neutrale Rückkehr und Kollisionsfreiheit. PR- und Release-Workflows führen ihn zusätzlich zu V97-Skinning- und Gameplay-Tests aus.
- [x] **V98-Teilziel und CI-/Release-Abnahme abgeschlossen:** Main-Commit `201eb540b8fb13c190898f5c3e65c0180c2dd994` (PR #85); Godot-PR-Tests, V97-Originalkörper-Skinning, neue gemeinsame Pose-Regression, Gameplay-Test, Webexport, Healthcheck und Archivschutz erfolgreich. GitHub Actions Release `40358789325` bestätigte `build.txt`, `index.html`, `index.js`, `index.wasm`, `index.pck` jeweils HTTP 200 unter der neuen unveränderlichen URL `skyway-v98/`. Laut Release-Log 95 historische Versionsverzeichnisse bewahrt, Unity-Seite vorbereitet.
- [ ] **Sprint 1 weiterhin offen:** ein erkennbar hochwertigerer vollständig geriggter Gesamtcharakter, nachgewiesene Clipping-Freiheit und iPhone-Querformat-FPS brauchen weitere Arbeit und visuelle/manuelle Prüfung.
- Touchsteuerung, Spielregeln, historische Skyway-Versionen und Unity-Archiv wurden im Änderungssatz nicht bearbeitet.

## Sprintprotokoll — 26.10.2026, V99 (PR #86, veröffentlicht und automatisiert geprüft)

- [x] **Sichtbarer Modellierungs-/Skinning-Zwischenschritt:** Eine selbst modellierte, gekrümmte Flugjacken-Rückenschale, zwei konisch geformte Ärmel und zwei Beinschalen mit schattierten Farbverläufen wurden ergänzt. Fünf mit demselben 13-Knochen-Skelett verbundene Neon-Piping-Meshes bilden insgesamt sechs gebogene Leuchtstreifen. Alle Flächen besitzen vier normierte GPU-Skin-Gewichte je Vertex; Arme und Beine verformen sich beim Lenken, Turbo und Springen. Keine neuen Fremd-Assets, Touch- oder Kollisionsänderungen.
- [x] **Technische Abnahme:** PR #86, Main-Commit `e14301797a0c6de737a99c1ebe1b5b38224de201`; Godot-PR-Validierung, bestehende Gameplay-, Originalkörper- und Kostüm-Pose-Tests sowie neue `rider_sculpted_skinned_suit_test.gd` erfolgreich. Webexport, Healthcheck, historische Versionsschutzprüfung und Release-Workflow `40367659523` erfolgreich.
- [x] **Immutable Release:** `skyway-v99/` mit HTTP 200 für `build.txt`, `index.html`, `index.js`, `index.wasm`, `index.pck`. Laut Release-Log **96 historische Versionsverzeichnisse** bewahrt; Unity-Webseite weiterhin vorbereitet. V98 und ältere URLs wurden nicht neu exportiert.
- [x] **Visuelle QA-Anleitung:** `godot/CHARACTER_VISUAL_QA.md` enthält reproduzierbare Prüfungen für 16:9/19,5:9 Querformat, Clipping, Menü-/Verfolgerkamera und reale FPS.
- [ ] **Sprint 1 bleibt offen:** Optisch erkennbarer Gesamtqualitätsgewinn, Kleidungs-Clipping, Gesicht-/Haarkohärenz und iPhone-Safari-FPS sind **nicht manuell abgenommen**. Die bekannte Godot-Importmeldung `Parameter "t" is null` erscheint weiterhin, ohne die Tests zu blockieren.
- **Nächster offener Schritt:** V99/V98 bei gleicher 16:9-Kamera visuell vergleichen, Durchdringungen an Schulter/Brust/Taille/Knie beseitigen, dann das gemeinsame Charakter-Rig mit saubererem Deformations-/Animationsablauf erweitern. Die nächste neue Veröffentlichung muss **V100 oder höher** verwenden; V99 niemals überschreiben.

## Sprintprotokoll — 26.10.2026, V100 (PR #87, veröffentlicht und automatisiert geprüft)

- [x] **Sichtbarkeits-/Überdeckungsfehler in V99 behoben:** Die neu skinnierte Rückenfläche lag geometrisch hinter den alten starren Rückenplatten (V99 ca. z=0,5–0,6, alte Jacke bis ca. z=0,78). Die V100-Oberfläche besitzt nun eine geformte, über dem alten Jackenprofil liegende Rückenwölbung und stärkere Schulter-/Taillenkonturen; Ärmel- und Beinpanzer sind für die Verfolgeransicht angehoben.
- [x] **Doppelte Geometrie gezielt ausgeblendet:** Alte starre Jacken-/Aero-Rückenflächen sowie starre Schienbein-/Knöchelmeshes werden **nur bei erfolgreicher 13-Knochen-Suit-Bindung** ausgeblendet. Der Reaktor, die animierten Kniegelenke, Leuchtringe, geformten Stiefel und die bestehende Steuerung bleiben erhalten. Ein zunächst fehlgeschlagener CI-Test deckte auf, dass V92 die alten Schienbeinmeshes in `AnimatedKneeKinematics/ArticulatedKnee` umgehängt hatte; Pfad und Regression wurden anhand des echten Fehlerlogs korrigiert.
- [x] **Neue Regression:** `godot/rider_suit_visibility_test.gd` kontrolliert Skin-Bindung, Rückenbreite und -tiefe, Material-/Normaldaten, gezielt verborgene starre Überlagerungen, erhaltene Reaktor-/Knie-/Stiefelobjekte, bewegte Originalknochen und Kollisionsfreiheit. In PR- und Release-CI integriert. Bestehende Gameplay-, Originalkörper-, Kostüm- und Suit-Tests bleiben aktiv.
- [x] **Belegter Release:** PR #87, Main-Commit `74c345a7910ec578e10689e377f3d9a97f6d8e9a`. PR-Godot-Validierung `40376138859`, Release `40376316967`, Godot-Tests, Webexport, Healthcheck und Archivschutz erfolgreich. Release-Log: **97 historische Versionsverzeichnisse** erhalten, Unity-Seite vorbereitet; `skyway-v100/` mit `build.txt`, `index.html`, `index.js`, `index.wasm`, `index.pck` jeweils HTTP 200 und verifizierter Commit-ID.
- [ ] **Sprint 1 weiterhin offen:** Automatische geometrische Sichtbarkeitsprüfungen sind **kein** Beweis für Clipping-Freiheit oder hochwertige Wirkung in echten gerenderten Frames. Ein iPhone-Querformat-Test (16:9/19,5:9), Bildvergleich V99/V100, echte FPS und Gesicht-/Haar-/Kleidungs-QA sind ausstehend. Kein vollständig neu gestalteter High-End-Charakter; die bisherigen glTF-Meshes bleiben bestehen. Die bekannte Importmeldung `Parameter "t" is null` ist weiterhin zu beobachten.
- **Nächster Schritt:** Sichtbares Gesamtmodell in Verfolger- und Menüperspektive anhand echter Bilder prüfen, verbleibende Überschneidungen an Achsel/Schulter und Kopf/Haar beseitigen und danach organischere, zusammenhängende Skin-/Pose-Animationen statt weiterer starrer Anbauteile entwickeln. V100 unverändert bewahren; nächste Release-URL frühestens `skyway-v101/`.

## Sprintprotokoll — 26.10.2026, V101 (PR #88; Release-Abnahme separat)

- [x] **Sprint 1, Animations-Teilziel:** Das bereits skinnierte 13-Knochen-Originalmodell nutzt jetzt phasenabhängige, anatomisch koordinierte Hoverboard-Posen: gegenläufige Hüft-/Brustbalance bei Kurven, sichtbar unterschiedliche Armhaltungen beim Auf- und Abstieg, Turbo-Vorlage und gedämpfte Kniekompression bei der Landung. Keine weiteren starren Zierkörperteile, keine neuen Assets.
- [x] **Regression:** `godot/rider_body_choreography_test.gd` prüft Original-Skinbindung, Brust/Hüftbalance, Sprungphasen, Turbo, Landung, Neutralrückkehr und fehlende zusätzliche Kollisionen. In PR- und Veröffentlichungs-CI aufgenommen. GDScript-Typfehler und eine zunächst festgestellte Drift der Kostümwurzeln beim Neutral-Reset wurden anhand echter fehlgeschlagener CI-Logs behoben.
- [x] **PR-Abnahme:** PR #88 in main als Commit `479bd7a48a26502f776f5be84d52a3557bd51af8` gemergt; finale PR-Godot-Validierung `40386253586` und Archivschutz `40386253480` erfolgreich. Main-Healthcheck und Archivschutz ebenfalls erfolgreich.
- [x] **Release-Abnahme:** Workflow `40386464618` erfolgreich abgeschlossen; Godot-Import, Gameplay-Tests, Original-Skin-/Kostüm-/Suit-/Sichtbarkeits-/Choreografie-Regression, Webexport und Pages-Deployment erfolgreich. `skyway-v101/` wurde neu und unveränderlich veröffentlicht; `build.txt` bestätigt Main-Commit `479bd7a48a26502f776f5be84d52a3557bd51af8`, `index.html`, `index.js`, `index.wasm`, `index.pck` jeweils HTTP 200. Das Release-Log bestätigt **98 historische Versionsverzeichnisse** und die vorbereitete Unity-Seite. Die Veröffentlichung ersetzt keine ältere Skyway-URL.
- [ ] **Sprint 1 offen:** Noch kein hochwertig neu modellierter Gesamtcharakter und kein Nachweis der visuellen Clipping-Freiheit, der tatsächlichen iPhone-Querformat-FPS oder einer klaren Qualitätssteigerung anhand identischer gerenderter Frames. `godot/CHARACTER_VISUAL_QA.md` beschreibt den V100/V101-Bewegungsvergleich.
- **Nächster Schritt:** Originalmodell-/Gesichts-/Haarkohärenz in echten gerenderten Frames prüfen, problematische Übergänge durch organische, gemeinsame Skin-Geometrie ersetzen; keine bloßen weiteren Panzer-Anbauten. Touch-Interpreter, Vokabelrunde, vier Welten, Power-ups und historische Builds nicht verändern.


## Sprintprotokoll — 26.10.2026, V102 (Implementierung / CI zunächst offen)
- [x] **Sprint 1, Gesichtsmodellierung:** Eine kontinuierliche, anatomisch geformte Wangen-/Kinn-/Nasenoberfläche mit Augenhöhlen, vertexfarbener Hautschattierung und realen Kopf-/Hals-Skin-Gewichten ersetzt drei alte frei schwebende Gesichts-Kugeln. Vorhandene animierte Augen, Brauen und Lächeln bleiben sichtbar; das ursprüngliche 13-Knochen-Rig wird wiederverwendet. Keine externen Assets oder Änderungen an Touch, Kollisionen, Regeln oder alten Releases.
- [x] **Regression / Release:** `godot/rider_skinned_face_test.gd` testet GPU-Skinning, Head-/Neck-Gewichte, verformte Geometrie, sichtbare Gesichtsausdrücke und Kollisionsfreiheit. PR- und Release-Workflow führen den Test aus; neue unveränderliche URL `skyway-v102/` nur bei erfolgreicher CI.
- [x] **V102 erfolgreich veröffentlicht:** Main `5129f281c46fa9987849a4a7ef4cb6281639f6d4`, PR #89, Release-Actions `40395177216` erfolgreich; Log bestätigt `SKINNED FACE TEST PASSED`, 99 erhaltene historische Versionsverzeichnisse und HTTP 200 für `build.txt`, `index.html`, `index.js`, `index.wasm`, `index.pck` unter `skyway-v102/`. Unity-Seite wurde im Releaseprozess vorbereitet.
- [ ] **Manuelle QA weiterhin offen:** V101/V102 im identischen 16:9-Querformat rendern und Gesicht, Haaransatz, Helmvisier, Clipping sowie echte iPhone-FPS prüfen. Keine High-End-Gesamtcharakter- oder FPS-Abnahme ohne Bild-/Gerätenachweis.

## Sprintprotokoll — 26.10.2026, V103 (Implementierung; CI und Release offen)
- [x] **Sprint 1, kohärente Kopf-/Haargeometrie:** Ein skulptierter, zusammenhängend geskinnt dargestellter Haar-Silhouettenmesh mit gewölbter Kopfhaut, sieben gekrümmten Rückensträhnen und vier kurzen, augenfreien Stirnsträhnen wird an die originalen 13 Körperknochen gebunden. Kopf-/Nacken-Gewichte verformen das Haar; ältere überlappende starre Kopfhautplatten und Haarstreifen werden nur bei erfolgreicher Skin-Bindung verborgen. Windanimierte Schläfenlocken, Zopf und Haar-Kaskade bleiben erhalten.
- [x] **V103-Regression:** `godot/rider_skinned_hair_test.gd` kontrolliert Vertexfarben, Normalen, Kopf-/Nacken-Gewichte, gemeinsame echte Knochen, Skinned-Pose, Sichtbarkeit und Kollisionsfreiheit. PR- und Release-CI müssen sie erfolgreich ausführen.
- [x] **Unveränderliche Veröffentlichung:** Nur nach grüner PR-/Main-CI, abgeschlossenem V102-Deployment und Archivprüfung unter `skyway-v103/` veröffentlichen. V102 und ältere Releases sowie Unity-Archiv nicht verändern.
- [ ] **Visuelle Abnahme bleibt offen:** Identische 16:9-Querformat-Screenshots V102/V103 in Menü und Verfolgerkamera vergleichen; Kopf-/Haaransatz, Visier-/Fringe-Clipping und iPhone-Safari-FPS manuell testen. Weder technische Skin-Tests noch ein HTTP-200-Check ersetzen echte Bild-/Geräteabnahme.

- [x] **Belegte V103-Abnahme:** PR #90 als Main-Commit `522b2b902a1360ad371e2ea0a4d462317fd8af01` gemergt. Abschließende PR-CI `40396625097`, Main-Godot-Test `40396815671`, Archivschutz `40396815673`, Healthcheck `40396815873` und Release `40396815762` erfolgreich. Release-Log: `SKINNED HAIR TEST PASSED`, 100 historische Versionsverzeichnisse erhalten, `skyway-v103/build.txt`, `index.html`, `index.js`, `index.wasm` und `index.pck` jeweils HTTP 200. Bestehende Unity-Seite im Deploy vorbereitet. V103 ist ein technischer und sichtbarer Modellierungsschritt, **keine** nachgewiesene High-End-Gesamtfigur oder iPhone-FPS-Abnahme.
- **Nächster Sprint-1-Schritt:** An echten gerenderten 16:9-Bildern Haare/Gesicht/Helm auf Clipping und Formfehler prüfen, Kopfhaut-/Gesichtsübergänge verfeinern und danach weitere zusammenhängende organische Skin-Geometrie statt starrer Anbauteile entwickeln. Touch, Gameplay und historische Builds erhalten.

## Sprintprotokoll — 26.10.2026, V104 (PR-/Release-Prüfung ausstehend)
- [x] **Sprint 1, sichtbare Volumenmodellierung:** Die sieben bisherigen flachen, skinierten Haarstreifen werden durch konisch auslaufende, rundum modellierte 3D-Strähnen mit kreisförmigem Querschnitt und vertexfarbener Lichtkante ersetzt. Sie teilen weiterhin das originale 13-Knochen-GPU-Skinning. Fünf ältere, starre `RiderHair/SweptHair*`-Meshes werden erst nach erfolgreicher Skin-Erzeugung ausgeblendet, damit die neue Silhouette nicht doppelt überzeichnet wird. Drei windbewegte Haarsträhnen, Schläfenlocken, Zopf und Kaskade bleiben erhalten.
- [x] **Godot-Regression ergänzt:** `rider_skinned_hair_test.gd` prüft nun echte 3D-Querschnitte, auslaufende Strähnenradien, zusätzliche Geometrie, ausgeblendete Alt-Tufts, erhaltene Windhaare sowie bestehende Skin-, Material- und Kollisionsbedingungen. PR- und Release-Workflows führen diesen Test aus.
- [x] **V104-CI und Release bestätigt:** PR #91, Main-Commit `94516c8673f4f55ca73579339c37b0b9260de242`; PR-Godot-Validierung `40402618581`, PR-Archivschutz `40402618632`, Main-Godot-Test `40402838044`, Main-Archivschutz `40402837853`, Healthcheck `40402837754` und Veröffentlichung `40402837859` erfolgreich. Der Release-Log bestätigt `SKINNED HAIR TEST PASSED`, **101 historische Versionsverzeichnisse erhalten**, vorbereitete Unity-Seite sowie `build.txt`, `index.html`, `index.js`, `index.wasm`, `index.pck` jeweils HTTP 200 unter der neuen unveränderlichen URL `skyway-v104/`. Die veröffentlichte Revision wurde vom Workflow mit `GITHUB_SHA` abgeglichen.
- [ ] **Manuelle QA offen:** 16:9-/19,5:9-Querformat-Fotos V103/V104 im Menü und Verfolgerkamera vergleichen; auf Haar-/Helm-Clipping, Augenfreiheit, FPS und flüssige Touchsteuerung prüfen. Geometrie- und Headless-Tests ersetzen keine reale Bildabnahme.
- **Nächster Sprint-1-Schritt:** Kopf-/Gesichts-/Helm-Übergänge anhand gerenderter Frames untersuchen und die gesamte organische Silhouette hochwertiger machen; keine weiteren starren Zierboxen.

## Sprintprotokoll — 26.10.2026, V105 (CI/Release ausstehend)
- [x] **Sprint 1, organischer Kopf statt flacher Maske:** Die bisherige V102-Gesichtsplatte wird zu einem durchgehenden 360°-Kopf mit Hinterkopf, Schläfen, Augenhöhlen, Nase, Wangen, Kinn und skinnierter Halskontur. Der Mesh nutzt weiterhin das **originale 13-Knochen-Skelett**; animierte Augen/Brauen, Haare und Helm bleiben. Keine Fremdassets, Touch-, Kollisions- oder Spielregeländerungen.
- [x] **Neue Regression/Release-Gate implementiert:** `godot/rider_closed_head_test.gd` prüft vollständige Kopfgeometrie, Relief, Gewichte, Pose und Kollisionsfreiheit. PR- und Release-CI führen sie aus. `skyway-v105/` wird nur bei bestandenen Checks und freier unveränderlicher URL angelegt.
- [ ] **Abnahme ausstehend:** PR-/Main-CI, Webexport, Release und Build-SHA/HTTP 200 nachweisen. Historische Releases und Unity-Archiv bewahren.
- [ ] **Sprint 1 weiterhin offen:** Tatsächliche Clipping-Freiheit, Vorher/Nachher-Renderbilder, High-End-Gesamtfigur und iPhone-FPS nicht belegt.
- **Danach:** Echte gerenderte Kopf-/Haar-/Helm-Bilder prüfen, organische Schulter-/Hals-Übergänge verbessern; erst danach Sprint 2.

- [x] **V105-Abnahme belegt (26.10.2026):** PR #92 nach zwei erfolgreichen PR-Godot-Läufen und Archivschutz gemergt; Main-Commit `0bc1a2c6fcc230f956b362fb886c998b8d418a49`. Main-Godot-CI `40411235798`, Healthcheck `40411235936`, Archivschutz `40411239085` und Release `40411235787` erfolgreich. Im Release-Log: `SKINNED FACE TEST PASSED`, `SKINNED HAIR TEST PASSED`, `CLOSED HEAD TEST PASSED`, **102 historische Versionsverzeichnisse erhalten** und `skyway-v105/build.txt`, `index.html`, `index.js`, `index.wasm`, `index.pck` jeweils HTTP 200. Der Workflow verifiziert `build.txt` gegen den Main-Commit. Die vorhandene Unity-Webseite wurde vom Veröffentlichungsworkflow vorbereitet; ältere Skyway-Verzeichnisse wurden nicht neu gebaut.
- [ ] **Offen trotz grüner CI:** Echte 16:9-/19,5:9-Rendervergleiche und iPhone-FPS/Clipping-Abnahme. Kein Nachweis für vollständige High-End-Gesamtfigur.
- **Nächster Schritt V106+:** Organische Übergänge zwischen Hals, Jacke und Schultern sowie eventuelle Helm-/Haar-Durchdringungen anhand reproduzierbarer Perspektiven verbessern. Erst nach visueller Abnahme Sprint 1 abschließen.
