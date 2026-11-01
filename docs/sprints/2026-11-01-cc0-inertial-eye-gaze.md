# LearnQuest 3D — 01.11.2026 — inertiale Blickführung der CC0-Figur (Spur B)

## Ausgangslage und Pflichtregeln
Vor dem Sprint wurden `LEARNQUEST_SPRINTS.md` und `LEARNQUEST_RELEASE_POLICY.md` explizit auf `main` gelesen. GitHub-Konto `mtothek0703` / `michael_kohler1@yahoo.de` und Repository `mtothek0703/learnquest-unity-web` geprüft; nicht das Grees-Klimatechnik-Konto. Letzter bestätigter stabiler Release: **Skyway V141**, PR #129, Main-Build `9a6187d1`; der nachfolgende Main-Commit `4b6bf0e2` ändert ausschließlich die Release-Dokumentation. Keine V142 ohne freigegebenen Mehrwert.

## Experimentelle Änderung
Die tatsächlich am importierten 65-Knochen-Head-Bone befestigten, modellierten Iris- und Pupillenmeshes reagieren nicht mehr hart auf jeden Lenkrichtungswechsel. `rider_external_expression.gd` glättet ihren Blick mit `1 - exp(-12*dt)` anhand der bestehenden Animationsuhr. Bei abrupter Links/Rechts-Kurve folgt der Blick verzögert; die vorhandenen Augenlider, Augenbrauen und Smile-/Boost-Animationen bleiben erhalten. Bei Zurücksetzen der QA-Uhr springt die Blickpose bewusst exakt auf die Sollposition, damit Vergleiche reproduzierbar bleiben.

Keine neuen Assets, Materialien, Meshes, Drawcalls, Kollisionen, Touch-Eingaben oder Änderungen an den drei Englischfragen, vier Welten, Bossen und Power-ups. Die ursprüngliche 65-Bone-Skinbindung bleibt unverändert. Implementierungscommit `9e53b1d0`, Regression `a94dec66`.

## Akzeptanz und Status
`rider_external_expression_test.gd` prüft nun zusätzlich, dass ein 60-FPS-Frame nach einem abrupten Richtungswechsel noch die vorherige Blickrichtung zeigt, dass die Iris danach das neue Ziel erreicht, dass nach 0,30 Sekunden die 30-/60-FPS-Pose innerhalb 0,02 % der Kopfbreite übereinstimmt und dass ein zurückgesetzter Clock keine Restdrift hinterlässt. Der bereits in GitHub Actions eingebundene Test muss mit allen übrigen Gameplay-, Skinning-, Webexport- und Renderprüfungen erfolgreich sein. **CI-Ergebnis erst nach dem endgültigen Test-/Dokumentations-Head prüfen; kein Erfolg vorab behaupten.** Die vorhandenen Querformat-Captures sind technische Nachweise, keine reale iPhone-Safari-Freigabe.

## Zwei-Spuren-Regel
**Spur A:** Skyway V141 bleibt stabil; keine V142 nur zur Versionssteigerung. Alle historischen Skyway-Builds und das Unity-Archiv bleiben unverändert. **Spur B:** PR #111 bleibt DRAFT und VISUAL HOLD; ein natürlicherer Blick allein genügt nicht für die hochwertige Gesamtfigur. Nächste Priorität: deutlicherer Silhouetten-/Gesichts-/Hoverboard-Qualitätssprung in echten 1280×720/1170×540 Bildern, danach reale iPhone-FPS, Clipping und vollständige Touch-Runde.
