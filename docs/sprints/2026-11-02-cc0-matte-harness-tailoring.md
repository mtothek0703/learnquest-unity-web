# 2026-11-02 — CC0 original-Skin fitted harness (DRAFT / visual hold)

## Motivation
The 1280×720 front/chase Godot renders still show a crowded blue/pink shoulder/chest silhouette. The four diagonal flight-harness bands add shiny, thick costume overlays on top of the already four-weight-skinned jacket and armor. The goal is to make the actual 3D source-skinned bands quieter and closer-fitting without changing gameplay, collision, imported glTF Skin, 65 bones, or any published build.

## Implemented in the isolated PR #111 branch
- `rider_external_skinned_harness.gd`: narrow each real diagonal clipped band from normalized half-width **0.052 to 0.034** (about 35% narrower), retaining original four-bone influences at every clipped seam.
- Reduce raised 3D band relief from **0.008–0.023 m to 0.005–0.014 m**; preserve real mesh triangles, mirrored front/rear seams and original Skin.
- Replace glossy pink/cyan plastic with subdued plum/teal cloth: metallic **0.34 → 0.12**, roughness **0.35 → 0.69**. No new textures, meshes, collisions or external assets.
- Extend `rider_external_skinned_harness_test.gd` to reject glossy materials, require the narrower actual 3D envelope and preserve normalized four-influence seam interpolation. Measurement includes the intentional 0.014-m normal-offset relief after clipping.

## Evidence and honest status
- Geometry/material commit: `8d1a0564`; regression commit: `7ed96e1a`; corrected finished-geometry tolerance: `62669b91`.
- First stricter test CI [41374010781](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41374010781) **FAILED**: test measured displaced 3D vertices as if they still lay exactly on the pre-relief clip boundary. The corrected test measures clip width plus actual relief.
- **Final full Godot CI [41374182067](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41374182067) SUCCESS**, including imported 65-bone Skin, gameplay, new harness envelope test, Web export and 16:9/19.5:9 OpenGL capture. The separate original code-only [CI 41373991097](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41373991097) also passed.
- **Actual A/B frames inspected:** prior [artifact 13109562426](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41371847362/artifacts/13109562426) vs new [artifact 13111025269](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41373991097/artifacts/13111025269), identical named 1280×720/1170×540 front/chase/detail views. At max RGB channel delta >25, 1280×720 chase-detail changed **4,745 pixels (0.515%)** and front-detail **3,018 (0.327%)**. Full chase changed **1,801 (0.195%)** and full front **1,421 (0.154%)**, while unchanged V123 control frames drifted by **982 (0.107%)** and **800 (0.087%)** respectively. These raw differences are not isolated quality proof.
- **Visual verdict:** narrower, darker straps are visible in the torso close-up, especially the chase back V; the character, oversized shoulder forms, hair and board still look cartoon-like. This is a modest garment-cleanup experiment, **not** a high-end graphics milestone. PR #111 stays DRAFT.
- Independent stable track A: [Skyway V151](https://mtothek0703.github.io/learnquest-unity-web/skyway-v151/) published from main `16693217`; [Pages run 41372959027](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41372959027) succeeded, verifying five files HTTP 200 and the exact build revision. 148 historical version directories preserved.

## Release gate
- [x] Final 65-bone/4-weight Godot regression, gameplay, Web export and real landscape render CI: run 41374182067.
- [x] Identical-camera 1280×720 and 1170×540 before/after inspection; result modest and insufficient for visual approval.
- [ ] Manual all-pose clipping QA, real iPhone Safari landscape FPS and uninterrupted three-English-question-to-full-touch-round test.
- [ ] Premium-quality complete character and board compared to stable reference.

**NO MERGE / NO DRAFT RELEASE / NO RESERVED VERSION.** Preserve historical Skyway URLs and Unity archive.
