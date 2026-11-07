# LearnQuest Adventure A4 – Mobile mission retry (07.11.2026, 21 Uhr)

## Ausgangslage
Primary GitHub `mtothek0703` / `michael_kohler1@yahoo.de` und Repository geprüft. Vor Änderung alle vier Pflichtdokumente von `main` gelesen. Main-Vergleich `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; DRAFT PR #157 Head `d11a0d6930cf94850edb75e47de4c20a1a1e5d4d`, 85 voraus/2 hinter main. Vorheriger Head CI-Lauf 42400014034 erfolgreich. Kein paralleler A1-Branch.

## Änderung
Im bestehenden Neon-City-Adventure-HUD gibt es jetzt einen tatsächlichen `NEUSTART`-Button. Er ruft den bereits implementierten lokalen Missionsreset auf, ohne die laufende Runner-Session, die drei Eingangsfragen oder XP zu verändern. Bei Safari-Fokusverlust werden Retry-Eingaben ignoriert. Separate Runner-Touch-Gesten und historische Releases bleiben unberührt.

## Akzeptanzkriterien
- HUD-Button ist vorhanden und sein echtes `pressed`-Signal löst lokalen Reset aus.
- Checkpoint, Geschwindigkeit, Touch-Achse und Roboterenergie werden zurückgesetzt.
- Der Adventure-Zustand bleibt aktiv; XP wird nicht vergeben.
- Fokusverlust blockiert den Retry; Runner/Archiv unverändert.

## Tests und Evidenz
- Vorheriger PR-Head `d11a0d6`: GitHub Actions 42400014034 = success; gilt **nicht** als Prüfung dieser Änderung.
- Neuer Regressionstest in `res://adventure/adventure_bridge_test.gd` committed; prüft HUD-Signal, Checkpoint, Geschwindigkeit, Touch, Energie, Phase und XP.
- Godot-Import, Headless-Test, Webexport, 16:9/19.5:9 Renderbilder und iPhone-Safari-QA **in diesem Durchlauf nicht ausgeführt/bestätigt**. CI für neuen Head abzuwarten.
- Gameplay-Commit `e4a106a2a52443633ebc637e10b2407fd46c1fbf`; Test-Commit `7c67584d885f9f8704e906563d9df00deb7e7860`. DRAFT PR #157 bleibt ungemergt. Kein Release.

## Nächster Schritt
Aktuelle CI kontrollieren und Fehler korrigieren. Danach bestehendes lizenziertes Charakter-Asset statt der provisorischen Kapsel sicher im Gehmodus darstellen und echte Querformatbilder prüfen, ohne PR #111 zu übernehmen.
