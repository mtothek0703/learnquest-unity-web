# LearnQuest 3D — Godot Browser-Prototyp

Eine eigenständige, kostenlose Godot-4-WebGL-Testwelt. Die Unity-Version im Wurzelverzeichnis bleibt erhalten.

Features: futuristische Neon-Rennstrecke, 3D-Hoverboard-Fahrer mit Animation, Spurwechsel (Touch und Tastatur), Englisch-Quiz für Klassen 1–10, XP und Turbo-Energie.

Engine: Godot 4.4.1, GDScript, Compatibility Renderer, Single-Thread-Web-Export für Safari/iPhone.

## Veröffentlichung

Der Workflow `.github/workflows/publish-unity-webgl.yml` exportiert das Projekt automatisch und veröffentlicht es unter `/learnquest-unity-web/godot/`. Die bestehende Unity-Web-Testversion bleibt unter `/learnquest-unity-web/`.

Ein GitHub-Actions-Export muss erst erfolgreich durchlaufen, bevor die Version spielbar ist.

Skyway V33: Eigenständig modellierter dreisträhniger 3D-Zopf mit Farbverlauf, zwei leuchtenden Haarspangen und weicher Wind-/Turbo-Animation. Originalgeometrie ohne Fremdlizenzen.

Skyway V34: Original modellierte, verlaufsschattierte Hosenbeine mit geschwungenen, beweglichen Kniepanzern und leuchtenden Nähten. Alle Geometrien werden einmalig erzeugt; keine Fremdassets.

Skyway V35: Volumetrische Haarhaube aus eigenem 3D-Oberflächenmesh, sechs überlappende, verlaufsschattierte Haarlagen mit leuchtenden Strähnen und zwei windanimierte Schläfenlocken. Kostenlose Originalgeometrie, keine Fremdassets; vorhandener Zopf und Spielmechanik bleiben erhalten.

Skyway V36: Großflächiger, gebogener Aero-Rückenpanzer mit verlaufsschattiertem 3D-Mesh, animiertem Neon-Reaktorring und zwei schwenkbaren Schubdüsen. Alle Modelle sind eigene, einmalig generierte Meshes; die bisherige Spiellogik und ältere Versionen bleiben erhalten.

Skyway V38: Geschneiderte, dreidimensional modellierte Frontjacke mit zwei hochaufgelösten Stoffpaneelen, schattierten Brustpanzern, hohem Rundkragen, leuchtendem Reißverschluss und animierter Atembewegung. Originalgeometrie ohne Fremdassets, nur Godot-4-Meshes; bestehendes Hoverboard und Englisch-Quiz bleiben unverändert.

Skyway V39: Vier große, zweigelenkig animierte Haarsträhnen rahmen den bisherigen Zopf. Jede Strähne besteht aus zwei plastisch geformten, farbverlaufsschattierten 3D-Meshes mit separater leuchtender Kontur. Eigenentwicklung ohne Fremdassets, optimiert für WebGL; Spiellogik, Vokabeln und ältere Versionen bleiben unverändert.

Skyway V44: Dritte Spielwelt **Sternen-Hafen** mit 1100-Meter-Runde, eigenständig modellierten, wiederverwendeten 3D-Turm-, Luftschiff- und Torbogen-Meshes sowie beweglicher Architektur. Optionale Mission: vier Energiekristalle sammeln für einen Bonusstern. Vor jeder Runde bleiben drei richtige altersgerechte Englisch-Vokabeln verpflichtend, danach ununterbrochenes Rennen. Kostenfreie Originalgeometrie ohne Fremdassets. Veröffentlichung ausschließlich nach erfolgreicher CI unter `/learnquest-unity-web/skyway-v44/`; frühere Skyway-Versionen und Unity-Archiv bleiben unangetastet.

Skyway V45: Vierte auswählbare 3D-Spielwelt **Aurora-Gletscher** (1200 m) mit eigenständig modellierten, schattierten Eisgraten, gebogenen Eisbrücken, transparenten und animierten Polarlicht-Bändern sowie fünf echten Sprungtoren. Für mindestens drei erfolgreich durchfahrene Sprungtore (Lenken und Springen) gibt es einen Bonusstern. Neue Runde nur nach drei richtigen Englisch-Vokabelantworten (Klasse 1–10), danach ununterbrochene Fahrt. Originale, wiederverwendete Godot-ArrayMeshes ohne Fremdassets und ohne Kosten. V45 wird erst nach Godot-Tests und erfolgreichem Webexport unter `/learnquest-unity-web/skyway-v45/` veröffentlicht; alte Skyway-Versionen und das Unity-Archiv bleiben erhalten.

Skyway V46: Im Sternen-Hafen erscheint ab 60 % der Strecke der **Orbit-Wächter** als zweiter optionaler 3D-Boss. Sein großer, geschwungener Rumpf, die animierten Flügel und drei leuchtenden Energieringe bestehen aus selbst erzeugten, wiederverwendeten ArrayMeshes. Anders als der Kristall-Wächter visiert er die aktuelle Fahrspur an und schießt Plasma: Ausweichen, Springen oder Energy Shield schützen, Turbo allein nicht. Zwei Super Attacks besiegen ihn und bringen +120 XP sowie einen Bonusstern zusätzlich zur Kristall-Sammelmission. Die drei Vokabelaufgaben vor jeder Runde, Klassen 1–10 und die durchgehende Fahrt bleiben erhalten. Keine Fremdassets oder Kosten; Veröffentlichung ausschließlich nach Tests unter /learnquest-unity-web/skyway-v46/.

Skyway V47: Dritter optionaler Boss im Aurora-Gletscher: Der **Frost-Drache** erscheint ab 65 % der 1200-m-Runde. Sein großer, gebogener, schattierter Körper, die schwenkbaren Eisflossen und der bewegliche Kiefer werden aus eigenentwickelten Godot-ArrayMeshes erzeugt. Er markiert **zwei gefährliche Fahrspuren** 1,6 Sekunden vor der Eiswelle; die dritte Spur bleibt sicher. Lenken, Springen oder Energy Shield schützen. Drei Super Attacks besiegen ihn und bringen +150 XP sowie einen Bonusstern zusätzlich zur Sprungtor-Mission. Drei richtige Vokabelantworten (Klassen 1–10) bleiben vor jeder Runde verpflichtend; danach läuft die Fahrt ohne Unterbrechung. Keine kostenpflichtigen Dienste oder Fremdassets. Veröffentlichung nur nach bestandenen Godot-Tests und Webexport unter /learnquest-unity-web/skyway-v47/; alle früheren Skyway-Versionen und das Unity-Archiv bleiben unverändert.

Skyway V48: Der Aurora-Frostdrache kündigt seine zweispurigen Angriffe mit **geformten, schattierten 3D-Eiswellen** an: transluzente, gewölbte Wellenflächen mit animierten, asymmetrischen Eiskämmen statt flacher Boxen. Die Warnungen bleiben eindeutig auf zwei Fahrspuren begrenzt; die dritte Spur bleibt sicher. Zusätzliche Godot-Tests prüfen Geometrie, Materialien, Animation und unveränderte Spurzuordnung. Sämtliche Geometrie ist selbst erstellt, ohne Fremdassets oder Kosten.

Skyway V49: Alle drei aktivierbaren Spezialeffekte (Energy Shield, Mega Jump und Super Attack) erhalten eigenständig modellierte, farbverlaufsschattierte 3D-Energieflächen: gewölbte Schildkuppel, zwei aufsteigende Spiralbänder und drei expandierende Plasma-Ringe. Geometrie wird einmalig erzeugt und anschließend effizient per Transform animiert; vorhandene Energiekosten, Tasten, Bosskämpfe, Vokabelpflicht und vier Welten bleiben erhalten. Godot-Smoke-Tests prüfen Meshdichte, Materialeigenschaften und bestehende Treffer-/Energie-Logik. Keine Fremdassets, keine Kosten.

Skyway V50: Kinoreife Charakterpräsentation im Menü: Die Kamera zeigt die vorhandene detaillierte Spielfigur erstmals von vorn (Gesicht, Haare, Jacke) und fährt beim Start sanft in die bewährte Verfolgerperspektive. Eine eigens modellierte, animierte 3D-Neon-Galerie mit mehreren geschwungenen Lichtbögen und leuchtenden Bodenringen rahmt die Figur, ohne die Rennen zu beeinflussen. Neue Godot-Tests prüfen Meshdichte, Farbverläufe, Animation und Kameratransition. Keine Fremdassets oder Kosten; Veröffentlichung erst nach CI unter /learnquest-unity-web/skyway-v50/.
