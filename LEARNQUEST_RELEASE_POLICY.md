# LearnQuest – Veröffentlichungsstrategie (30.10.2026)

## Warum diese Regel nötig wurde
V123 ist seit dem 27.10.2026 die letzte veröffentlichte stabile Version. PR #111 experimentiert unabhängig mit einer neuen CC0-Figur, realem 65-Bone-Rig, kostümierten Skins und Bild-QA. Weil deren Gesamtoptik noch nicht klar besser als V123 ist, blieb der PR zu Recht im DRAFT-Zustand. Das darf aber **andere fertige Spielfunktionen und sichtbare Verbesserungen nicht auf unbestimmte Zeit blockieren**.

## Zwei parallele Entwicklungsspuren
**A. Stabile Spielversionen (main):**
- Die letzte bestätigte Pages-Version ermitteln und die nächste **noch freie Versionsnummer** wählen. Nicht bloß Versionsnummer erhöhen: Jede Veröffentlichung braucht einen nachweisbaren spielbaren oder deutlich sichtbaren Mehrwert.
- Kleine **zusammenhängende**, abgeschlossene Verbesserungen aus dem Sprintplan entwickeln (z. B. Spielmechaniken, Missionen, UI-/Kamera-Komposition im Smartphone-Querformat, optimierte 3D-Umgebung, Belohnungen); klar abgrenzbar gegen den experimentellen Charakter.
- Godot-Regression, Headless-Gameplay, Export, GitHub Actions und Archivschutz vor der Veröffentlichung bestehen lassen. Erst nachdem GitHub Pages und die exakte Build-Revision nachweislich erfolgreich sind, die neue immutable URL mitteilen.
- Keine Veröffentlichung von unfertigen Features, kaputten Builds, bloßen Farbänderungen ohne spürbaren Effekt oder nur neuer Versionsnummer.

**B. Großes Grafik-Upgrade (eigener DRAFT-Branch, derzeit PR #111):**
- Den neuen CC0-65-Bone-Charakter in Ruhe optisch und technisch bis zur Freigabereife verbessern.
- Keine unfertige Grafik nach main übernehmen; echte Querformat-Bildvergleiche, Spieleransicht sowie manuelle iPhone-QA beachten.
- **Versionskollision vermeiden:** Der Arbeitstitel „V124“ in PR #111 ist *kein fest reservierter Release-Name*. Nach Freigabe muss der Charakter-PR gegenüber dem aktuellen main rebaset/aktualisiert werden und beim Merge die dann nächste **unbenutzte** Release-Nummer erhalten. Nicht alte immutable URLs überschreiben.

## Ablauf je automatischem Sprint
1. Neueste main-Version, PR #111 und Actions prüfen; bei CI-Fehlern zuerst reparieren.
2. Wenn eine risikoarme **fertige** Verbesserung in main publizierbar ist, diese eigenständig priorisieren, testen und als frische Version ausliefern. Unterbinde nicht alle Releases wegen eines auf Dauer offenen Grafik-PRs.
3. Danach den großen Charakter-Branch fortsetzen, sein visuelles Qualitäts-Gate beibehalten.
4. Bei keinem freigabefähigen Fortschritt **kein** Release erzwingen: konkret berichten, was fehlt.
5. Ältere Skyway-Versionen und Unity-Archiv unangetastet lassen; Smartphone-Querformat und funktionierende Touch-Gesten priorisieren; drei Englisch-Fragen vor jeder kompletten Spielrunde, vier Welten, Missionen und vier Fähigkeiten bewahren.
6. Aufgaben laufen **nur bei den geplanten stündlichen Durchläufen**, nicht permanent. Nach einem abgeschlossenen Schritt im selben Durchlauf direkt mit dem nächsten fortfahren, wenn möglich.

## Erfolgskriterien
- Nutzbare neue Versionen sollen wieder regelmäßig entstehen, wenn **fertige** sichere Änderungen existieren.
- Eine experimentelle große Charakterüberarbeitung bleibt geschützt, ohne den stabilen Release-Kanal zu blockieren.
- Jede Behauptung über Merge, Tests oder URL braucht konkrete CI-/Deployment-Nachweise.
