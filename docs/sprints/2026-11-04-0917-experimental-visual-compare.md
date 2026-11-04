# LearnQuest Sprint – 2026-11-04 09:17 CET

## Verbindliche Basis
Konto Primary (mtothek0703), Repository `mtothek0703/learnquest-unity-web`. Auf `main` gelesen: `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`. PR #111 ist offen, DRAFT und nicht mergebar.

## Spur B – tatsächliche Änderung
Auf dem **experimentellen Branch** `sprint-v124-quaternius-rigged-hero` wurde `tools/character-frame-compare.html` ergänzt (Commit `c279abe2a0ce30cca326faf6d9723e3f1a89f7af`). Das vollständig offline nutzbare Werkzeug lädt zwei lokale PNG/JPEG/WebP-Bilder, bietet eine verschiebbare A/B-Trennlinie und 16:9-/19,5:9-Ansichten. Keine Netzwerkanfrage, kein Asset-Upload, keine Abhängigkeit. Es dient zur reproduzierbaren manuellen Silhouetten-/Clipping-Prüfung des 65-Bone-Charakters; **keine** visuelle Freigabe oder gemessene FPS.

### Tatsächlich geprüfte Kriterien
GitHub-Datei nach dem Commit erneut abgerufen. Acht statische Strukturprüfungen bestanden: HTML-Dokument, zwei Datei-Eingaben, lokale Object-URLs, URL-Freigabe, Schieberegler, beide Querformat-Seitenverhältnisse, keine externen Ressourcen, geschlossener Skriptblock. **Nicht ausgeführt:** Browser-Interaktion, echter Screenshot-Vergleich, Godot-Import, Gameplay-Tests, Webexport, iPhone-FPS. Deshalb PR weiterhin DRAFT und keine Freigabe.

## Spur A – stabile Releases
Keine Änderung auf `main`, kein neuer Skyway-Release; letzte zuvor dokumentierte stabile Version V154. Historische Skyway-Versionen und Unity-Archiv wurden nicht berührt. Ohne unabhängig getesteten Spiel-/Grafikmehrwert kein Versionssprung.

## Nächster Schritt
Echte identisch gerenderte 16:9- und 19,5:9-Bilder von Referenz und Experiment aufnehmen, im Vergleichswerkzeug an Kopf/Haar, Schultern, Kostüm, Board und HUD kontrollieren; anschließend gezielte Mesh-/Skinning-Fixes mit Godot-CI. Stabile Features weiterhin unabhängig entwickeln und nur mit vollständigen Release-Gates veröffentlichen.
