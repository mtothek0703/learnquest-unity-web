# Adventure A1 – sichtbarer mobiler Joystick (06.11.2026)

## Ausgangslage und Sicherheit
Primary-Konto mtothek0703 / michael_kohler1@yahoo.de; Repository mtothek0703/learnquest-unity-web; Branch feature/adventure-a1-walk-arena-20261105-2111. Vor Änderung vier Pflichtdokumente aus main gelesen. Main war 0e01246620d33a9afcbb617152748adac4402993; A1-Branch 14 Commits voraus und 0 zurück.

## Änderung
Der zuvor unsichtbare A1-MovePad zeichnet nun einen halbtransparenten Joystick mit Außenring und beweglichem Knopf. Analogbewegung wird auf Länge 1 begrenzt; kleine ungewollte Fingerbewegungen werden durch 0,12 Dead Zone unterdrückt. Beim Loslassen oder Entfernen der UI wird die Bewegung zurückgesetzt. Nur godot/adventure/adventure_touch.gd geändert; Runner-Touch-Gesten und bestehende Releases unverändert. Neuer Test adventure_joystick_test.gd.

## Akzeptanzkriterien
- Im Gehmodus ist der Joystick sichtbar, bewegt sich relativ zum Finger und lässt sich in Querformat bedienen.
- Analogvektor bleibt innerhalb 1; Eingaben unter 0,12 führen nicht zu Drift; Loslassen stoppt Bewegung.
- Kein Eingriff in godot/touch_gestures.gd oder Runner; Feature weiterhin isoliert und nicht mit Rennrunde verbunden.

## Tatsächliche Tests
- GitHub-Quellcode gelesen und Branch mit main verglichen: erfolgreich.
- Godot-Import, Headless-Physiktest, neuer Joystick-Test, Webexport, echte Renderbilder, iPhone-Safari, CI und Pages: **nicht ausgeführt / nicht nachgewiesen**.
- Testbefehl nach Installation von Godot 4.4.1: `godot --headless --path godot --script res://adventure/adventure_joystick_test.gd`.
- Keine Freigabe und kein Skyway-Release.

## Commits
- Joystick: 2f9569ce29ebd8b0624107563b3a09cd00344a81
- Regression: 7e78eab07f57286615c264ea6e64b951113b942c
- PR: #146 (DRAFT).

## Nächster Schritt
Godot-Import und Headless-Tests ausführen, echte 16:9-/19,5:9-Bilder visuell prüfen, dann Steuerungszonen/Pointer-Cancel auf iPhone-Safari testen und A1 in die Session integrieren. Keine Veröffentlichung ohne vollständige Abnahme.
