# 2026-11-02 — DRAFT: true source-Skin pectoral volume reduction

## Evidence-driven cause
The previous 52/52-CI experiment removed the three opaque chest/back armor overlays, exposing a cleaner V harness but changing only 0.287% of 1280×720 front pixels and 0.203% of chase pixels. The [108-layer A/B artifact](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41388051447/artifacts/13116338040) shows the underlying **imported 65-bone source chest and the skinned jacket** are already broad in isolation. More changes to overlaid armor will not fix the underlying silhouette.

## New actual 3D sculpt
- `rider_external_body_resculpt.gd`: reduce **central chest width expansion from +15% to +7%** and depth expansion from **+12% to +6%**. The transformation still acts directly on original imported four-weight GPU-skinned vertices, preserving mesh indices, bind matrices, 65 original bones, shoulder taper, hand/face/foot and board contact.
- Extend `rider_external_body_resculpt_test.gd` with quantitative rest-space bounds that reject the old inflated pectoral profile in both X and Z. Existing skinning, normals, mirror, shoulder, thigh, collision and hand/foot gates remain.
- No new geometry, render passes, touch input, gameplay logic, external assets, or stable release metadata.

## Acceptance / HOLD
- Full PR Godot CI, web export and same-camera 1280×720/1170×540 front/chase and source-only frames must pass and be compared to [previous 60-frame reference](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41388051447/artifacts/13116183581).
- This is a **DRAFT silhouette trial**, not an aesthetic approval; if chest deformation looks worse or creates clipping, revert. PR #111 stays DRAFT, no merge/version reservation. Real iPhone FPS and full touch round remain unverified.

## Results
First CI [41388927752](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41388927752) stopped at the **old minimum chest expansion** (+0.015 absolute units), which contradicted the intended slimmer source chest. The new test still requires positive chest relief (+0.007) and the existing tapered waist, plus the new upper limits for both X/Z pectoral inflation. Re-run full CI; no release approval yet.

## Final CI and original Godot landscape comparison
- Source sculpt [902cd34f](https://github.com/mtothek0703/learnquest-unity-web/commit/902cd34fd2fb0862e14b71019675129eb1d98c7c), updated realistic taper threshold [170d4c0d](https://github.com/mtothek0703/learnquest-unity-web/commit/170d4c0de1ab6ad30cf3e436b00cdef01c9421a4).
- First CI [41388927752](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41388927752) failed on the **old minimum +0.015 chest expansion**; updated the test to keep a smaller but positive +0.007 taper while bounding excessive X/Z inflation. No gameplay code was changed.
- [Final Godot PR CI 41389049544](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41389049544): **SUCCESS 52/52 steps**, including 65-bone original Skin, real source-body vertex/normal tests, gameplay, Web export and landscape captures.
- Real pose-locked comparison: [previous full-rider frames](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41388051447/artifacts/13116183581) vs [new source-chest frames](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41389049544/artifacts/13116627229). 1280x720 pixels with max RGB channel difference >25: front **1,537 (0.1668%)**, chase **1,884 (0.2044%)**, front detail **3,402 (0.3691%)**, chase detail **3,704 (0.4019%)**. At 1170x540: front **948 (0.1500%)**, chase **766 (0.1212%)**.
- **Honest visual finding:** Source chest width/depth changed in real four-weight geometry and passed the tests, but the complete silhouette still appears bulky. The change is small at mobile camera distance. This is **NOT** a large visual quality leap or permission to merge PR #111. A cohesive redesign of jacket/sleeves/neck/shoulders, not another micro-taper, is required.
- No stable V153 or main modification. The original 65 bones, touch controls, four worlds, power-ups, boss fights, three English questions, older releases and Unity archive remain untouched. Real iPhone FPS, clipping and complete touch round remain open.
