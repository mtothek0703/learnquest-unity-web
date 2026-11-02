# 2026-11-02 — DRAFT: 3D-Bug freigelegt, alte flache Board-Überlagerungen entfernt

## Pflichtprüfung und getrennte Spuren
- LEARNQUEST_SPRINTS.md und LEARNQUEST_RELEASE_POLICY.md auf main gelesen.
- GitHub-Primary `mtothek0703` (`michael_kohler1@yahoo.de`), Repository `mtothek0703/learnquest-unity-web` überprüft.
- Spur A: main `16693217f9cc37b59329cb2e46ce090680b15e9b` / letzte bestätigte Skyway V151. Kein V152 ohne fertigen, nachweislich sichtbaren neuen Mehrwert, grüne CI, Archivschutz und Pages-Nachweis.
- Spur B: PR #111 bleibt DRAFT / VISUAL HOLD. Die im PR-Titel stehende V124 ist keine reservierte Release-Nummer.

## Fehlerursache und Änderung
In den echten 1280x720-Frontaufnahmen war der große flache violette V12-PrismMesh-Bug **vor** der später modellierten, geschlossenen 3D-Bugform sichtbar. Außerdem überlagerten alte gelbe und cyanfarbene rechteckige V12-Markierungen die konturierte, echte 3D-Traktionsfläche. Die neue 3D-Bug-Chine war dadurch teilweise verdeckt; weitere Mikroskulpturen allein konnten die Gesamtwirkung nicht lösen.

`godot/hover_hero.gd` benennt nun die sechs Originalteile (Prow, CenterSpine, NoseBar, FrontBar, Port/StarboardDeckStripe) und schaltet sie **nur dann** unsichtbar, wenn `SculptedHoverboardChassis.built` wahr ist. Alle Original-Meshes bleiben im Szenenbaum für den Fallback erhalten. Das vorhandene Board, Lean/Hover/Boost, Turbinen, Kollisionen und Touchsteuerung bleiben unverändert. Keine neuen Assets, Meshes oder Draw Calls.

`godot/hoverboard_sculpted_hull_test.gd` prüft, dass alle sechs alten Meshes als Fallback existieren, beim neuen Board aber verborgen sind und die echten 3D-Chassis-/Deck-Meshes sichtbar bleiben.

## Akzeptanz-Gates
- Vollständige GitHub Godot-PR-CI, Webexport, Gameplay und Querformat-Render-QA: **nach Commit prüfen**.
- Vorher/Nachher: identische Kamera/Pose, 1280x720 und 1170x540, besonders Frontansicht und Verfolgeransicht. Die Entfernung der Überlagerungen ist ein echter Sichtbarkeits-Fix, aber noch keine pauschale Freigabe der Gesamtfigur.
- Kein Merge und keine neue Skyway-URL vor visueller Freigabe. Historische Skyway-Versionen, Unity-Archiv, drei Englischfragen, vier Welten, Bosse und vier Power-ups unangetastet.
- Reale iPhone-FPS, Clipping und komplette Touch-Spielrunde bleiben offen.

## Commits
- Sichtbarkeit/Legacy-Fallback: `1de2b653caf8d30979f7288d1ea2c355e77652ec`
- Regression: `bcef92d28c95ee76fa030039b8a2cafc3e2495c0`

## Abschluss: CI und tatsächlicher Vorher/Nachher-Bildvergleich
- [Vollständige Godot-PR-CI 41382641917](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41382641917) **SUCCESS**, inklusive Gameplay, 65-Bone-Skinning, Godot-Webexport und echten Smartphone-Querformatbildern.
- Verglichen: [Original-Captures vor Änderung 41376883132](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41376883132/artifacts/13112036564) gegen [neue Captures 41382641917](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41382641917/artifacts/13114650795), jeweils `1280x720_front_after.png` / `1280x720_chase_after.png`, gleiche Pose und Kamera.
- Differenz mit maximaler RGB-Kanalabweichung >25: **Front 18.212 Pixel (1,976%)**, Änderungsbereich x=487..792/y=394..554; **Chase 2.402 Pixel (0,261%)**, Bereich x=558..721/y=368..442. Keine Unterschiede außerhalb der Board-Zone in diesen Captures; die Änderung ist eindeutig auf die alten Board-Overlays zurückzuführen.
- Die Frontansicht zeigt statt des flachen violetten Bugkeils jetzt das echte 3D-Chassis mit Bug-Chines; die Chase-Ansicht verliert die breite gelbe Mittelmarkierung. Substanzieller Sichtbarkeitsgewinn, **aber keine vollständige Premium-Figur**.
- PR #111 bleibt DRAFT / VISUAL HOLD. Keine Version reserviert, kein Merge. Reale iPhone-FPS/Clipping/volle Touch-Spielrunde weiterhin nicht abgenommen.
