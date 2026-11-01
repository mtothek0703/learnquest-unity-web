# 2026-11-01 — Stable track A: Crystal Canyon sculpted sky bridges (V142 candidate)

## Scope and safeguards
Read both mandatory main policies. Verified GitHub Primary account mtothek0703 (ID 339490599) and repository mtothek0703/learnquest-unity-web (ID 1427565370). Starting main 4b6bf0e2, last verified immutable release V141. PR #111 is independent DRAFT / VISUAL HOLD; its title reserves no version.

## Implementation
- Four substantial continuous faceted rock arches span the Crystal Canyon racing corridor at high clearance. Each has a 32-segment fully volumetric shaded mesh, including top, underside, front and rear, with normals and vertex colors.
- 28 hanging crystalline keystones (seven per bridge) are batched into four MultiMeshes. One rock mesh is reused across all arches, no new textures, third-party assets, lights, collision bodies or physics.
- All bridges scroll at level speed, wrap without accumulating objects, and freeze during the mandatory three English questions.
- The existing three-lane touch controls, four worlds, bosses, four powers, historic Skyway directories and Unity archive are untouched.
- Existing canyon regression now validates real 3D volume, shading, safe vertical clearance, batched crystals, collision absence, movement and pause.
- Existing 16:9 / 19.5:9 capture pipeline now produces eight additional **isolated** bridge-before/after PNGs at identical cameras, alongside eight existing geode comparisons. The PR and release workflows enforce all 16 frames and a nontrivial visible-pixel threshold.

## Release gates
- [ ] Full PR Godot import, gameplay, regression, OpenGL images and Web export pass.
- [ ] Historical archive protection passes.
- [ ] Review real landscape frames and visible difference before considering merge.
- [ ] Only then select next free immutable version (expected V142), update version/build workflow, merge, verify main CI, Pages and exact build.txt SHA plus five HTTP 200 files.
- [ ] Real iPhone Safari FPS, full touch-controlled three-question round and all-pose clipping require manual device QA. Do not claim those passed.
- [ ] Pages artifact is already over 1.4 GB; preserve existing builds and address storage separately.

No release has been claimed at candidate creation.

## Verified candidate gates (2026-11-01)
- Godot PR validation [#41296400036](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41296400036) **SUCCESS**: complete headless gameplay/geometry regressions, Web export, all legacy visual tests and sixteen real Canyon landscape frames. Historical archive protection [#41296399818](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41296399818) **SUCCESS**.
- Isolated same-camera bridge-before/after PNGs from [artifact 13079865354](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41296400036/artifacts/13079865354) inspected in chase and oblique views at both phone ratios.
- Measured changed pixels (max RGB channel delta >25): 1280x720 chase **11,712 (1.271%)**, oblique **7,625 (0.827%)**; 1170x540 chase **6,594 (1.044%)**, oblique **4,292 (0.679%)**. The near-camera overhead rock span is visibly present with its hanging crystal keystones; no gameplay controls or collisions changed.
- This proves a distinct substantial 3D landmark, not iPhone frame rate or commercial-grade visual quality.
- Release commit now prepares **V142** in the world label and immutable Pages workflow, retaining historical V141 sky-terrace QA artifact naming. **No claim of published V142 until main CI and Pages HTTP/build.txt verification.**

## CI repair before release
- Initial version-label candidate CI [#41296669514](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41296669514) failed the existing phone-portrait/race HUD smoke assertions because four expectations still required `V141` after the actual game label was upgraded to `V142`. No release was performed.
- Updated those four assertions to match the new version; gameplay and test semantics remain unchanged. A fresh full CI run must pass before merge.

## Final V142 release verification (2026-11-01)
- [x] Stable [PR #130](https://github.com/mtothek0703/learnquest-unity-web/pull/130) squash-merged to main at gameplay release commit `fe450cf366b40a9df0e28731b9826e9913ac8544`.
- [x] Main [Godot CI #41296982880](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41296982880) SUCCESS, [archive preservation #41296982834](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41296982834) SUCCESS, [health check #41296982890](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41296982890) SUCCESS.
- [x] [Pages publish #41296982946](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41296982946) SUCCESS, immutable [Skyway V142](https://mtothek0703.github.io/learnquest-unity-web/skyway-v142/) live. The workflow independently checked `build.txt` equals the release commit and HTTP 200 for `build.txt`, `index.html`, `index.js`, `index.wasm`, `index.pck`.
- [x] **139 historical version directories** restored unchanged before adding V142, including Skyway V141 and the original Unity archive.
- [x] Pages artifact size **1,432,433,117 bytes**; upload and deployment succeeded despite the ongoing 1-GB warning. Storage growth needs a separate safe fix, never delete historical versions.
- [ ] Real iPhone Safari frame rate, collision/clipping across full playthrough and manually controlled three-question round remain unverified.
- [ ] Experimental CC0 PR #111 remains DRAFT and does not block this stable release.
