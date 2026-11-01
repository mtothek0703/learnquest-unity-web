# 2026-11-01 — DRAFT PR #111: skinnierte Jackenschultern zur V-Halslinie verjüngen

## Ausgangslage
Beide Pflichtdateien auf `main` gelesen; GitHub-Primary `mtothek0703` und `mtothek0703/learnquest-unity-web` geprüft. Stable **V146** wurde unabhängig vom DRAFT-Charakter unter https://mtothek0703.github.io/learnquest-unity-web/skyway-v146/ veröffentlicht (Main `2445586f`, [Pages-CI 41326988635](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41326988635), fünf HTTP 200 und 143 historische Versionen). DRAFT #111 bleibt ohne Versionsreservierung, VISUAL HOLD.

## Erstes Experiment: Front-V statt flacher Jackenkante
- Commit `def0907f`: originale viergewichtete Jackendreiecke an einer vorne abgesenkten V-Halslinie geschnitten; `218938e2`: Normalisierung, symmetrische Halslinie und neue interpolierte Skin-Grenzen abgesichert.
- [Godot-PR-CI 41327806544](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41327806544) erfolgreich: Import, Gameplay, Original-65-Bone-Skin, Webexport, 108 Layer-Frames und 48 Gesamt-Silhouetten-Frames bestanden.
- [48 echte Bilder](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41327806544/artifacts/13092705116) und [108 Layer-Bilder](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41327806544/artifacts/13092460923) heruntergeladen und gegen [vorherige 48 Bilder](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41326626477/artifacts/13091204453) und [108 Layer-Bilder](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41326626477/artifacts/13091149234) verglichen. Identische 1280x720 Front-Detailkamera: **2.404 Pixel / 0,261 %**, Chase-Detail **6.303 / 0,684 %**, isolierte Front-Jacke **7.594 / 0,824 %** mit RGB-Maxkanalabweichung >25. Die neue Öffnung ist technisch real, aber im vollständigen Bild **zu subtil** und der breite cyanfarbene obere Jackenbalken bleibt dominant. Keine Gesamtfreigabe.

## Zweites Experiment: echte obere Jackenbreite reduzieren
- `godot/rider_external_skinned_outfit.gd`: Das vorher konstante, seitlich 24 % der originalen CC0-AABB breite Jacket-Clipfenster verjüngt sich jetzt **nur am oberen Torso** sanft auf 18 % pro Seite; Brust und Taille bleiben breit, die separat GPU-geskinnten Ärmel behalten ihre Deltoid-Geometrie. Der schmale obere Jackenabschluss soll die zu breite horizontale blaue Schulterbrücke ersetzen. Die Grenzschnittpunkte behalten die vier normalisierten Original-Skin-Einflüsse.
- `godot/rider_external_skinned_outfit_test.gd`: Test für reale 24%-zu-18%-Taperung, nicht verworfene Quell-Dreiecke und interpolierte viergewichtete Schnittkanten. Originaler CC0-GLB, 65 Bones, Animationen, Hoverboard, Touchsteuerung, drei Fragen, vier Welten, Bosskämpfe, vier Power-ups und Archive unverändert.
- Implementierungscommits `cf773ab826ead576d191a0bf27decf77b8e6793d` und `45b6fd795db016e667397b5e79443a45897500cc`.

## Freigabegrenzen
- [ ] Finale vollständige Godot-CI und Webexport nach Taperung grün
- [ ] 16:9/19,5:9 Front-/Chase- und isolierte Jackenbilder tatsächlich A/B vergleichen; prüfen, ob die blaue Schulterbrücke sichtbar schmaler ist und keine neuen Löcher/Clipping entstehen
- [ ] Kein Merge oder Stable Release von PR #111 vor unabhängiger visueller Gesamtfreigabe
- [ ] Reale iPhone-FPS und vollständige Touch-Runde nach drei Englischfragen bleiben offen

Dieser Sprint ist ein **reversibler DRAFT-Qualitätsversuch**, kein V147-Kandidat.
