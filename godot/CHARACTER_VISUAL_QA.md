# LearnQuest V101 — Charakter: visuelle QA im Smartphone-Querformat

Die automatisierten Godot-Tests prüfen Skin-Bindings, echte Knochenbewegung,
Vertex-Normalen, Neon-Materialien und Kollisionsfreiheit. Sie **beweisen keine**
optische Clipping-Freiheit, Framerate oder Darstellung auf einem echten Telefon.

## Geräteprüfung (offen bis manuell bestätigt)
1. Skyway V101 im mobilen Safari und Android-Chrome bei 16:9 bzw. 19,5:9 **Querformat** öffnen. Kein Hochformat-Test als Ersatz.
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

## V101 — Bewegungs-/Animationsabnahme (noch offen)

1. V100 und V101 in identischer 16:9-Verfolgerkamera vergleichen. In V101 sollte der Oberkörper sichtbar gegen die Hüfte arbeiten, wenn das Hoverboard links/rechts gesteuert wird. Der Kopf soll trotz Brustdrehung zur Kurve schauen.
2. Bei einem Mega Jump **Aufstieg und Abstieg getrennt** aufnehmen: die Arme öffnen sich im Aufstieg und ziehen sich beim Abstieg an den Körper. Bei der Landung sollten beide Knie kurz sichtbar nachgeben und danach ohne Ruckeln in die Neutralpose zurückkehren.
3. Turbo im Stand und während einer Kurve testen. Kopf, Haare, Jacke und originaler glTF-Körper sollen der gemeinsamen 13-Knochen-Pose folgen; keine Doppelrotation, überdehnten Schultern oder verdeckten Hände.
4. Auf echtem iPhone und Android im Querformat FPS, Kamerakomposition, Touch- und HUD-Freiraum messen. Drei Vokabeln, vier Welten und vier Power-ups weiterhin im Gameplay prüfen.

**Automatische Regression:** `rider_body_choreography_test.gd` prüft Knochenrotationen, Aufstiegs-/Abstiegsphasen, Landekompression, Rückkehr zur Ruhe, gemeinsame Skin-Bindung und Kollisionsfreiheit. **Kein automatischer Test beweist tatsächliche Bildqualität, Clipping-Freiheit oder iPhone-FPS.**


## V102 — kontinuierliche skinnierte Gesichtsoberfläche (manuelle Abnahme offen)
1. V101/V102 im gleichen 16:9-Querformat-Menü vergleichen: eine zusammenhängende Wangen-/Kinn-/Nasenfläche ersetzt drei schwebende Kugeln. Augen, Blinzeln, Augenbrauen und Lächeln müssen davor erkennbar bleiben.
2. In der Verfolgerkamera und bei Turbo/Mega Jump Kopf-/Halsübergang, Helmvisier, Haaransatz und Wangen auf Z-Fighting oder Durchdringungen prüfen. Auch beide Seitenansichten aufnehmen.
3. Automatischer Test `rider_skinned_face_test.gd` kontrolliert Original-Skelettbindung, echte Kopf-/Halsverformung, gewichtete Geometrie, Normals/Vertexfarben, Erhalt der Augen und fehlende Kollisionen. **Kein** Pixel-/FPS-Nachweis; echtes iPhone-Querformat bleibt offen.

## V103 — gemeinsame geskinte Haar-Silhouette (manuelle Abnahme offen)
1. V102 und V103 bei **identischer** Kamera im Smartphone-Querformat (16:9 und 19,5:9) aufnehmen. Im Menü Front-, Profil- und Rückenansicht vergleichen: gewölbte Kopfhaut, sieben geschwungene Rückensträhnen und vier kurze Stirnsträhnen statt der alten starren, überlappenden Platten.
2. Die Stirnsträhnen dürfen Augenbrauen, Augen und Blinzeln nicht verdecken. Auf Spalten zwischen Gesicht, Kopfhaut und Helmvisier sowie Z-Fighting bei Kopfrotation achten. Das bisherige Gesicht muss sichtbar bleiben.
3. Turbo, Links-/Rechtskurven, Mega Jump und Landung filmen: der neue Haar-Mesh soll mit dem **originalen** Kopf-/Nacken-Rig verformen; die weiterhin animierten Schläfenlocken, Kaskadensträhnen und der Zopf dürfen nicht doppelt rotieren oder durch den Helm ragen.
4. FPS und Framezeiten über 60 Sekunden auf echtem iPhone im Querformat erfassen, dazu Browser-Reload und alle vier Welten prüfen. Touch-Gesten und HUD dürfen sich nicht verändern. Ohne Gerätetest keine FPS- oder Clipping-Abnahme behaupten.

**Automatische Regression:** `rider_skinned_hair_test.gd` prüft echte Skin-Gewichte, 13-Bone-Bindung, Geometrieumfang, Materialien, erhaltene Schläfenlocken, ausgeblendete Altplatten und Kollisionsfreiheit. Diese Prüfungen ersetzen **keinen** Vorher/Nachher-Bildvergleich.
