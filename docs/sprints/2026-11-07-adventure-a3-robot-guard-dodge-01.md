# LearnQuest A3 – Roboterschlag mit Abwehr und Ausweichen (07.11.2026, 01 Uhr)

## Ausgangskontrolle
Primary GitHub: mtothek0703 / michael_kohler1@yahoo.de; Repository: mtothek0703/learnquest-unity-web; bestehender DRAFT PR #157 auf feature/adventure-a1-walkable-neon-testbed-20261106-19. Main bei Kontrolle: 3117869390c6f3dff6409bfde1f64c2d184b0853. Alle vier Pflichtdateien auf main gelesen. PR-Head vor Änderung: 75ce5fa094086d8f6ad1fab873cca9392170e7aa. Dessen Godot-PR-CI 42310847359 war erfolgreich.

## Implementierung
Ein telegraphierter Roboterangriff wird nach der Warnzeit tatsächlich aufgelöst: innerhalb von drei Metern ohne Abwehr kostet er einen von drei lokalen Energiepunkten. Bewegung außerhalb der Reichweite beim Einschlag weicht aus. Separate ABWEHR-Taste (G am Desktop) bietet 0,8 Sekunden Schutz. Bei aufgebrauchter Energie lokaler Neustart an der Arena-Startposition, ohne Runner-Leben zu verändern. Missionsreset stellt Energie/Abwehr zurück. Runner-Steuerung, drei Pflichtfragen, XP und alte Builds nicht geändert.

## Akzeptanzkriterien
1. Warnung -> Treffer in Reichweite ohne Abwehr kostet exakt einen Energiepunkt.
2. Aktive Abwehr verhindert Treffer; Verlassen der Reichweite vor Einschlag ebenso.
3. Reset stellt Energie wieder her; kein Eingriff in bestehende Runner-Leben.
4. Zwei eigene Treffer deaktivieren weiterhin den Roboter.

## Tests und Grenzen
Der bestehende Headless-Integrationstest res://adventure/adventure_bridge_test.gd wurde um Treffer/Abwehr/Ausweichen erweitert. **Dieser neue Test wurde in diesem Durchlauf noch nicht ausgeführt; neue PR-CI ist abzuwarten.** Vorheriger erfolgreicher CI-Lauf gilt nur für den vorherigen Commit. Kein lokaler Godot-Import, Webexport, Rendervergleich, iPhone-Safari-Test, Merge oder Release nachgewiesen. Neue Commits: 3074dade567ce505ef9d5cb25faed73c3b2e545b und 130832497ff5d48b58a12a807a47123429d68281.

## Nächster Schritt
CI für aktuellen PR-Head prüfen und Fehler beheben; dann Angriffswarnung und Touch-Bedienflächen im echten 16:9-/19,5:9-Render testen. Bei Erfolg Kampffortschritt in Portalbedingungen integrieren, ohne ungetestete Drafts zu mergen.
