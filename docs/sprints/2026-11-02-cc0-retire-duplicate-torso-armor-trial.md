# 2026-11-02 — CC0 fitted jacket silhouette: retire redundant torso armor (DRAFT)

## Policy, account and scope
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` for this run. Confirmed GitHub Primary `mtothek0703` / `michael_kohler1@yahoo.de` and exact repository `mtothek0703/learnquest-unity-web`.
- Stable main was `09601905af48ff905747ea58f43177aa7f7e2e31` (verified Skyway V152). Stable releases remain independent; no version reserved by DRAFT PR #111.

## Hypothesis and real implementation
Recent same-camera 1280×720 comparisons showed that repeated narrow panel and shoulder tweaks changed only small pixel fractions while the full rider still looked layered and barrel-shaped. This trial tests a **composition change**, not another recolor: if the original-65-bone weighted flight jacket **and** the four genuine weighted harness bands both install, hide the three opaque overlaid pectoral/spine armor panels. Keep their original Skin meshes, weights and nodes intact for fallback and isolated before/after comparisons. The jacket, sleeves, original CC0 body, facial animation, 65-bone rig, and sculpted board stay unchanged. No new primitives, draw calls, physics, touch inputs or external assets.

## Regression and release hold
- Extend `rider_external_skinned_armor_test.gd` to assert the fitted harness, visible source-weighted jacket, three retained hidden armor panels and `armor_layers_retired` state; keep all existing four-weight interpolation, curved profile and mesh checks.
- Run complete Godot CI, export, gameplay and 1280×720/1170×540 front/chase QA. Compare actual complete rider and layer-isolated images against the preceding DRAFT commit. **A successful test is not aesthetic acceptance.**
- No merge of PR #111 or Skyway release without demonstrable complete-hero improvement and manual iPhone FPS/clipping/full-touch-round QA. Older Skyway builds and Unity archive must remain untouched.

## Results
- First full CI [41387635292](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41387635292): Godot gameplay/skin tests and Web export succeeded, but the existing 108-frame sleeve visual capture correctly rejected its outdated expectation of three *visible* armor panels. The three meshes are intentionally hidden by this trial; updated the QA gate to require zero visible duplicate panels while explicitly re-enabling those same original-Skin panels in the isolated `skinned_armor` A/B frame. Re-run full CI and compare before/after; no visual approval yet.

## Abschluss nach zweiter CI und echten Pixelvergleichen
- Implementierung: [7859bc38](https://github.com/mtothek0703/learnquest-unity-web/commit/7859bc38ffaeeb40b393e675735c1c20b7828bbb); korrigierte isolierte Armor-QA: [293f917a](https://github.com/mtothek0703/learnquest-unity-web/commit/293f917a7e1902d15bcb5032d0a559bb1fdb1977).
- [Godot PR-CI 41388051447](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41388051447) **SUCCESS, 52/52 Schritte**. Darin Godot-Import, Gameplay, echte 65-Bone-Skin-/Jacket-/Armor-Regression, Webexport und 108 gerenderte Smartphone-Querformat-Kostümkontrollen. Der erste CI-Fehler 41387635292 wurde gezielt repariert, nicht ignoriert.
- Echte Originalbilder: [vorherige 60 Querformatframes](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41382641917/artifacts/13114192033) gegen [60 neue Querformatframes](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41388051447/artifacts/13116183581), jeweils identisch benannte `1280x720_front_after.png`, `1280x720_chase_after.png`, `*_detail_after.png` und 1170x540.
- Pixel mit maximalem RGB-Kanalunterschied >25: 1280x720 Front **2.646 (0,2871%)**, Chase **1.868 (0,2027%)**, Front-Detail **5.630 (0,6109%)**, Chase-Detail **4.234 (0,4594%)**; 1170x540 Front **1.523 (0,2411%)**, Chase **1.107 (0,1752%)**. Die Änderung ist auf den echten Jacket-/Armor-Bereich konzentriert; Front-V-Naht und Rücken-V werden klarer, aber die Gesamtproportionen bleiben zu breit.
- **Visuelles Qualitäts-Gate NICHT bestanden:** echte Änderung, aber keine nachweisbar hochwertige Gesamtfigur; PR #111 bleibt DRAFT, kein Merge und keine neue Version. Reale iPhone-FPS, Clipping und vollständige Touch-Runde fehlen. Stable main bleibt unverändert bei V152 / `09601905`.
- Nächster Versuch muss die *gesamte* Schulter-/Kragen-/Körperproportion in der realen Verfolgerkamera sichtbar verbessern statt nur kleine Überlagerungen auszublenden.
