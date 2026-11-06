# LearnQuest Adventure A3 – sichtbarer Neon-Roboter (06.11.2026, 06:14 CET)

## Ausgangslage und Konto
Primary GitHub: mtothek0703 / michael_kohler1@yahoo.de. Repository mtothek0703/learnquest-unity-web. Main 0e01246620d33a9afcbb617152748adac4402993; A3-DRAFT-Branch vor Änderung 3 Commits voraus, 0 zurück. Auf main gelesen: LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md.

## Änderung
godot/adventure/neon_robot_actor.gd erzeugt einen sichtbaren 3D-Roboter und einen rot pulsierenden Warnkreis. Der Actor verwendet die bestehende A3-Zustandslogik aus PR #148, überprüft die echte Distanz zu einer zugewiesenen Spieler-Node, bietet Angriff/Abwehr und signalisiert Treffer/Besiegen. Der Kampf ist standardmäßig deaktiviert und läuft nur bei aktivem Encounter. Keine Änderungen an world.gd, Runner, Quiz, Touch-Gesten, vier Welten, Bossen, Power-ups, alten Builds oder Unity-Archiv. Keine Fremdassets.

## Akzeptanzkriterien
- Sichtbarer Roboter und Warnkreis, Warnkreis nur während Angriffsvorwarnung.
- Distanzabhängige Angriffe, Abwehr schützt, keine Doppelbelohnung nach Sieg.
- Deaktivierter Kampf führt keine Angriffe aus; Reset stellt Roboter und Lebenspunkte wieder her.
- Separater Arena-Controller kann den Actor später instanziieren, ohne Runner-Zustand zu beeinflussen.

## Tests und tatsächlicher Stand
Neuer Godot-Test godot/adventure/neon_robot_actor_test.gd geschrieben; erwarteter Aufruf: godot --headless --path godot --script res://adventure/neon_robot_actor_test.gd. **Nicht ausgeführt**: Godot 4.4.1 in dieser Ausführungsumgebung nicht nachgewiesen. Kein erfolgreicher Godot-Import, Gameplay-Test, Webexport, echter 16:9-/19.5:9-Render, iPhone-Safari-Test, Archivschutz oder Pages-Deployment nachgewiesen. Keine CI-Freigabe behauptet.

## PR und nächster Schritt
DRAFT PR #148, Commits dd995f283b083395d4364342abfc3c79ace60d4c und ce1f08d7e814f2f3a6e45387b20df62340b082bc plus dieses Protokoll. Noch nicht in die A1-Arena aus PR #146 integriert. Als Nächstes Actor im Arena-Branch integrieren, mobile Angriffs-/Abwehrflächen ergänzen und Godot-Tests tatsächlich ausführen. Kein Merge oder Release ohne Qualitätsgates.
