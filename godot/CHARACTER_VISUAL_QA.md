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

## V104 — Volumetrische 3D-Haare statt flacher Streifen (noch manuell zu prüfen)
1. V103 und V104 mit **gleicher 16:9-Querformat-Kamera** aus Rücken-, Profil- und Menüperspektive aufnehmen. Die sieben skinierten Strähnen sollen echte Rundung und eine deutlichere Tiefe besitzen, nicht mehr nur flache Bänder.
2. Bei harter Kurve, Turbo und Mega Jump auf Durchdringungen von Kopfhaut, Helm, Visier und Nacken achten. Die fünf alten starren `SweptHair*`-Tufts dürfen die neue Silhouette nicht überdecken. Drei Windsträhnen, Schläfenlocken, Zopf und Kaskade müssen weiterhin reagieren.
3. Im echten Smartphone-Querformat (16:9 und 19,5:9) Bildrate, Berührungseingaben und freie HUD-/Kamerazone messen; V103 als Baseline verwenden. **Noch keine** bestätigten Geräte-FPS, Pixel- oder Clipping-Ergebnisse.

Automatische Regression: `rider_skinned_hair_test.gd` prüft zusätzlich Volumen-Querschnitt, Tapering und das Verbergen starrer Duplikate, aber keine echten gerenderten Pixel.

## V105 — geschlossener skinnierter 360°-Kopf (manuelle QA offen)
1. V104/V105 bei identischer 16:9-/19,5:9-Querformatkamera vergleichen: Front, Profil, Dreiviertel und Verfolgerperspektive. Der neue Kopf muss echte Schläfen, Hinterkopf, Wangen und Halskontur statt einer schwebenden Gesichtsplatte zeigen.
2. Augen, Blinzeln, Brauen, Lächeln und Nase sowie Haaransatz, Helmvisier, Ohren-/Schläfen- und Halsübergang bei Turbo/Mega Jump auf Clipping und Z-Fighting prüfen.
3. Auf echtem iPhone FPS und Framezeiten je 60 Sekunden sowie Touch/HUD-Freiraum messen. Drei Vokabelaufgaben, volle Runde, vier Welten, Bosse und Power-ups durchspielen. Ohne Bilder/Messungen **keine** visuelle/FPS-Abnahme behaupten.

Automatisch prüft `rider_closed_head_test.gd` 360°-Volumen, Augenhöhlen-/Nasenrelief, Kopf-/Nacken-Gewichte, das originale 13-Knochen-Rig und Kollisionsfreiheit. Keine Pixel-/Geräteprüfung.

## V106 — skinnierte Jacke, Schulter- und Halsübergänge (manuelle QA offen)
1. V105 und V106 in **identischer 16:9- und 19,5:9-Querformatkamera** aufnehmen: vorn, Rücken, Profil, Dreiviertel sowie Verfolgeransicht. Die neue Jacke muss als ein durchgehender 360°-Körper mit geformten Schultern und asymmetrischer Kragenhöhe erkennbar sein, nicht als separate Boxen.
2. Turbo, harte Links-/Rechtskurven, Mega Jump und Landung filmen. Speziell an Kinn/Kragen, Schulter/Ärmel, Rücken/Reaktor und Brustnaht auf sichtbare Durchdringungen oder unnatürliche Deformation achten. Kopf, Haare, Helm und Gesicht müssen frei bleiben.
3. Im Smartphone-Querformat HUD-Überdeckung, Touch-Eingaben und FPS/Framezeiten mindestens 60 Sekunden prüfen; V105 bei identischem Gerät und Szene als Referenz. Drei Vokabelaufgaben, volle Runde, vier Welten, Bosse und vier Power-ups erhalten.
4. Automatisch prüft `rider_skinned_upper_jacket_test.gd` echte Skelettgewichte, zusammenhängende Jackengeometrie, den neuen Kragen und das Verbergen starrer V38-Duplikate. **Keine** automatische Pixel-/FPS-Abnahme; echte Gerätetests bleiben offen.

## V107 — anatomisch skinnierte Ärmel, Falten und Handgelenkbündchen (manuelle QA offen)
1. V106/V107 auf **demselben Smartphone** in 16:9 und 19,5:9 quer vergleichen: Front-, Seiten-, Rücken- und Verfolgeransicht. Die beiden neuen Jackenärmel müssen als plastische Schulter-Ellbogen-Handgelenk-Silhouette mit Stofffalten und reflektierenden Bündchen lesbar sein.
2. Links-/Rechtskurven, Turbo, Mega Jump, Landung und Idle je mindestens 10 Sekunden filmen. Schulter/Brust-Übergänge, Ellbogen, Gauntlet-Ansatz und Leuchtnaht auf Z-Fighting, Mesh-Clipping und Versatz prüfen. Der alte starre Oberarm/Schulterpanzer darf nicht sichtbar sein; Finger, Handschuhe und Ellbogengelenke müssen weiterhin animieren.
3. Touch-Zonen, HUD-Freiraum, vollständige drei Vokabelaufgaben, ununterbrochene Levelrunde, vier Welten, Bosse und Power-ups kontrollieren. Auf echtem iPhone im Querformat 60 Sekunden FPS/Framezeiten erfassen und V106 bei identischer Szene vergleichen.
4. Automatisierte `rider_skinned_armwear_test.gd`-Checks prüfen 13-Bone-Skinning, Volumen, Falten-/Bündchengeometrie, Deformation und ausgeblendete Überlagerungen, **nicht** gerenderte Pixel, realen FPS oder Clipping-Freiheit. Diese Abnahme bleibt offen.


## V108 — echte gerenderte QA-Bilder statt nur Geometrie-Assertions

Die Godot-CI erzeugt jetzt mit **OpenGL/Mesa unter Xvfb** 18 echte PNGs:
1280×720 (16:9) und 1170×540 (19,5:9), jeweils Front, Profil und
Verfolgerperspektive sowie Idle, Lenkung+Turbo und Sprung. Das Skript
`godot/rider_visual_capture_test.gd` prüft die Bildabmessungen und verwirft
leere oder nahezu einfarbige Bilder. Die Frames werden in GitHub Actions als
`learnquest-landscape-character-frames` (PR) bzw.
`learnquest-v108-landscape-character-frames` (Release) archiviert.

**Bildabnahme bleibt eine menschliche Aufgabe:** Die PNGs der gleichen
Perspektive/Posen aus zwei Versionen nebeneinander öffnen und konkret Kopf-/
Helm-/Haar-Clipping, Kragen, Achseln, Ellbogen, Gauntlets, Rücken und
Hoverboard-Komposition prüfen. Ein nichtleeres PNG beweist weder, dass die
Geometrie schön oder clippingfrei ist, noch die FPS auf einem iPhone.

Lokal (Linux mit Xvfb und Godot 4.4.1, im Repository-Hauptverzeichnis):

```bash
mkdir -p /tmp/learnquest-visual-qa
LIBGL_ALWAYS_SOFTWARE=1 LEARNQUEST_VISUAL_OUTPUT=/tmp/learnquest-visual-qa \
  xvfb-run -a -s '-screen 0 1600x900x24' \
  godot --path godot --rendering-driver opengl3 \
  --script res://rider_visual_capture_test.gd
```

**Nicht** `--headless` für diese Pixelprüfung verwenden: der Dummy-Renderer
kann keine verlässlichen Bilder liefern. Die echten iPhone-/Android-Tests,
60-Sekunden-FPS-Messungen und Browser-Touchprüfungen bleiben separat offen.
