# LearnQuest V100 — Charakter: visuelle QA im Smartphone-Querformat

Die automatisierten Godot-Tests prüfen Skin-Bindings, echte Knochenbewegung,
Vertex-Normalen, Neon-Materialien und Kollisionsfreiheit. Sie **beweisen keine**
optische Clipping-Freiheit, Framerate oder Darstellung auf einem echten Telefon.

## Geräteprüfung (offen bis manuell bestätigt)
1. Skyway V100 im mobilen Safari und Android-Chrome bei 16:9 bzw. 19,5:9 **Querformat** öffnen. Kein Hochformat-Test als Ersatz.
2. Im Charaktermenü Rücken, Gesicht und Haare prüfen. Die V100-Jackenrückseite soll vor der alten, jetzt ausgeblendeten starren Rückenplatte sichtbar sein; der drehende Reaktor bleibt sichtbar. Die skinierten Ärmel, Beinschalen und cyanfarbenen Leuchtkanten in Nahansicht und Verfolgerkamera prüfen. Vorher/Nachher mit V99 bei identischer Kamera aufnehmen.
3. Je 30 Sekunden Geradeausfahrt, hartes Links-/Rechtslenken, Turbo und Mega Jump ausführen. Besonders an Achseln, Taille, Ellbogen und Knien auf überlappende Meshes oder Durchdringen von Kleidung achten. Screenshots der Problemstellen sichern.
4. In allen vier Welten eine vollständige Runde spielen: genau drei Englischfragen vor der ununterbrochenen Runde; vier Power-ups, Missionen und Bosse prüfen. Touchzonen dürfen die Figur und wichtige Spielwelt nicht verdecken.
5. FPS mit Browser-Entwicklerwerkzeugen oder geeigneter Geräte-Messung über 60 Sekunden erfassen; Ladezeit, Abstürze und Erwärmung notieren. Vorher/Nachher mit V99 bei identischem Gerät und Szene vergleichen.

**Status:** Manuelle Geräte- und visuelle QA ist ausstehend. Keine FPS- oder
Clipping-Freiheit ohne entsprechende Messung behaupten.

## Automatische V100-Sichtbarkeitsregression

`rider_suit_visibility_test.gd` prüft die geometrische Tiefe und Breite der
skinierten Rückenfläche, dass starre überdeckende Rücken- und Schienbeinmeshes
nur bei vorhandenem Suit-Skin ausgeblendet werden, und dass Reaktor,
Stiefel, Kniegelenke, Knochenpose und Kollisionsfreiheit erhalten bleiben.
**Das ist eine geometrische Prüfung, keine Pixelanalyse.** Es ersetzt keine
Sichtkontrolle bei 16:9/19,5:9 und keine Messung der tatsächlichen FPS.
