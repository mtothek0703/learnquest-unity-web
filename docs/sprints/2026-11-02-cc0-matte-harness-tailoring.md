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
- **Final CI and same-camera before/after visual review pending.** No claim of a large visible improvement without inspecting OpenGL frames.
- Independent stable track A: [Skyway V151](https://mtothek0703.github.io/learnquest-unity-web/skyway-v151/) published from main `16693217`; [Pages run 41372959027](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41372959027) succeeded, verifying five files HTTP 200 and the exact build revision. 148 historical version directories preserved.

## Release gate
- [ ] Final 65-bone/4-weight Godot regression, gameplay, Web export and real landscape render CI.
- [ ] Identical-camera 1280×720 and 1170×540 before/after inspection, including front/chase silhouette coherence.
- [ ] Manual all-pose clipping QA, real iPhone Safari landscape FPS and uninterrupted three-English-question-to-full-touch-round test.
- [ ] Premium-quality complete character and board compared to stable reference.

**NO MERGE / NO DRAFT RELEASE / NO RESERVED VERSION.** Preserve historical Skyway URLs and Unity archive.
