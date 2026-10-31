## Sprintprotokoll — 31.10.2026, PR #111 DRAFT: dynamische vierfach gewichtete Mantel-Silhouette

- **Optisches Ziel:** Die bisher in der Verfolgerkamera dominierenden zwei blauen Mantelfinnen liegen im Leerlauf enger an den Hüften; bei bestehendem Turbo und Sprung entfalten sie sich entlang der echten GPU-skinierten Stofffläche. Die Schulterwurzel bleibt fixiert, der Mittelkanal für Beine/Hoverboard bleibt frei. Keine zusätzlichen Meshes, Collider, Shader-Pässe oder Touch-Befehle.
- **Technik:** Ein einziger, UV-abhängiger `fold_to_hips`-Deformer in `rider_external_mantle.gdshader`; echte 65-Knochen-Skinning-Gewichte und ursprüngliche GLB-Daten unverändert. Der bestehende Manteltest prüft nun die dynamische Geometrieverdrahtung.
- **Freigabe:** Godot-/Webexport-/Querformat-CI abwarten, dann reale 16:9-/19,5:9-Bilder auf weniger Leerlauf-Überlagerung und sichtbares Ausfalten prüfen. **Keine visuelle Gesamtfreigabe**, PR #111 bleibt DRAFT, kein Merge/Release, V124 reserviert keine Versionsnummer. Reale iPhone-FPS und vollständiger Touchdurchlauf weiter offen.
- **Stabiler Kanal:** Separater V133-Kandidat PR #121 mit spielbarem Aurora-Luft-Windstrom, ohne die experimentelle Figur.
