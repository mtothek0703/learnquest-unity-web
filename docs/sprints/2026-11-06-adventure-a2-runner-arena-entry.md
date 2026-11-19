# 2026-11-06 14:14 — Adventure A2 runner ↔ arena integration (DRAFT)

## Ausgangslage
Primary GitHub mtothek0703 / michael_kohler1@yahoo.de, Repository mtothek0703/learnquest-unity-web, main 0e01246620d33a9afcbb617152748adac4402993. Die vier Pflichtdokumente auf main wurden vor Änderungen gelesen. Weiterarbeit im bereits main-basierten Adventure-PR #146, um die vorhandene Arena nicht auf einem isolierten Branch zu duplizieren; kein Merge nach main.

## Konkrete Änderung
In `godot/world.gd` wurde eine opt-in Eintrittstaste `ABSTEIGEN` auf eigener CanvasLayer ergänzt. Sie erscheint ausschließlich bei aktivem Feature-Schalter, Neon City, laufendem Rennen und ohne Quiz. Beim Eintritt wird die echte Arena instanziiert, die Rennphase auf `on_foot` umgestellt, die Runner-Figur versteckt, die Arena-Kamera aktiviert und die Runner-Touch-Eingabe zurückgesetzt. Das Ausgangsportal der Arena löst die Rückkehr zur vorherigen Rennphase aus, schaltet die Rennkamera wieder aktiv und entfernt die Arena. Der bestehende `_process` führt während `on_foot` keine Rennsimulation aus.

## Akzeptanzkriterien und Grenzen
- Default `NEON_ADVENTURE_ENABLED = false`: bisheriger Runner bleibt unverändert.
- Nach bewusstem Einschalten: nur nach den drei Pflichtfragen in Neon City zugänglich.
- Rennfortschritt, Distanz, XP und bestehende Bosszustände werden bei Eintritt nicht zurückgesetzt.
- Portalabschluss setzt die Rennsimulation fort, ohne neue Pflichtfragen.
- Noch **nicht** nachgewiesen: fehlerfreier Godot-Import, kompletter Lauf, korrekte HUD-Überlagerungen, Touch auf iPhone, Renderbilder, Performance. Kein Release.
- Die Arena verwendet derzeit einen prototypischen Capsule-Spieler; die bestehende lizenzierte Figur ist noch nicht sichtbar integriert. Dieser Punkt bleibt offen.
- Der neue Einstieg ist nur als deaktiviertes Integrationsgerüst eingecheckt; noch kein nutzerfertiges Adventure.

## Tatsächlich ausgeführte Prüfungen
- GitHub Main-Vergleich: 0e012466 gegen main identisch.
- Vorheriger `godot/world.gd`-Inhalt und Arena-/Portal-Signale gelesen.
- Quellcode per GitHub-Contents-API geschrieben; Commit 7e876a45 und CanvasLayer-Fix 56dd3a8c.
- Lokaler Godot-Check: `command -v godot || command -v godot4` → `GODOT_UNAVAILABLE`. Daher **keine** Godot-Gameplay-/Import-/Webexport-Tests ausgeführt.
- Keine HTTP-200-/Pages-/Archivschutz-/Geräte-Abnahme.

## Nächster Schritt
Godot 4.4.1 CI mit aktiviertem Feature-Schalter ausführen, Eintritt und Rückkehr headless testen, UI-Kollisionen im 16:9/19.5:9 prüfen. Erst danach optional aktivieren, bestehenden Charakter in der Arena verwenden und den vollständigen Neon-City-Slice abnehmen. PR #111 und alte Skyway-Versionen unangetastet.
