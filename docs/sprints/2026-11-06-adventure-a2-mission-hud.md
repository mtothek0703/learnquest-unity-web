# Sprint 2026-11-06 09:19 – A2 Mission HUD

## Basis / Kontozuordnung
Primary GitHub: mtothek0703 / michael_kohler1@yahoo.de; Repository: mtothek0703/learnquest-unity-web; main: `0e01246620d33a9afcbb617152748adac4402993`. Frischer Feature-Branch `feature/adventure-a2-mission-hud-20261106-0919`. Vier vorgeschriebene Dokumente vor Änderung aus main gelesen.

## Änderung
Adventure-only Control mit Kristall- und Schalterfortschritt sowie sichtbarer Portal-Freigabe. Verbindet sich mit den Signalen der Mission aus DRAFT PR #146; bind_mission(null) entfernt Verbindungen. HUD ignoriert Maus-/Touch-Eingaben, verändert weder Runner noch Touch-Gesten. Keine Änderung an main. Der Code ist absichtlich separat: PR #146 muss vor Integration geprüft und korrekt übernommen werden.

## Akzeptanzkriterien
- Start 0/3 und 0/2, Portal gesperrt.
- Nach drei Kristallen und zwei Schaltern: Portal bereit.
- Reset sperrt Portal; Abmelden trennt Signale.
- Runner und alte Releases unberührt.

## Tests und Ergebnis
Regression `godot/adventure/adventure_mission_hud_test.gd` angelegt, **nicht ausgeführt**: Godot 4.4.1 ist in dieser Laufzeit nicht installiert. Da `adventure_mission.gd` ausschließlich in PR #146 existiert, ist der Test vor Integration mit PR #146 auf diesem isolierten Branch noch nicht ausführbar. Keine Behauptung erfolgreicher Godot-Importe, Webexporte, Renderbilder, iPhone-Tests oder Releases. Kein Merge/Pages.

## Nächster Schritt
PR #146 und diesen Branch kontrolliert integrieren, HUD in der Arena instanziieren, Godot-Import/Headless-Test und reale Querformatbilder prüfen. Anschließend Race-Pause/Return aus PR #150 integrieren. PR #111 bleibt getrennt.
