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
Pending new CI and actual image review.
