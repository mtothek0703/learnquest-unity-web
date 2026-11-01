# 2026-11-01 — Stable track A: Aurora Glacier sculpted icefalls (V143 candidate)

## Policy and account
Both LEARNQUEST_SPRINTS.md and LEARNQUEST_RELEASE_POLICY.md were read on main. Verified Primary GitHub login mtothek0703, repository mtothek0703/learnquest-unity-web (repo ID 1427565370). Main baseline d08c14d07, last verified immutable release V142. Experimental 65-bone character PR #111 stays independent DRAFT / VISUAL HOLD and does not reserve a version.

## Actual candidate implementation
- Six original 3D ice cascades on alternating sides of the Aurora Glacier racing corridor. Each shares one closed, folded, shaded ArrayMesh with front, rear, edges, top and underside, including normals and per-vertex ice colors. No billboard planes or third-party textures.
- Seventy-two luminous 3D icicles batched into six MultiMeshes. No new lights, physics/collision objects, gameplay inputs, dependencies or costs.
- Scenery scrolls with the race, freezes during the mandatory three English vocabulary questions and wraps with a fixed six-icefall cycle.
- Dedicated headless regression checks 3D depth, 6 shared icefalls, 72 batched icicles, no collisions, lane clearance, motion, pause and wrap.
- Dedicated Godot OpenGL capture checks eight isolated before/after frames at 1280x720 and 1170x540 in chase and oblique perspectives, with minimum changed-pixel sampling.
- Main game version and the protected Pages candidate path advance to V143 ONLY on this candidate branch. Older Skyway URLs and Unity archive must not be modified.

## Release hold until gates
- [ ] PR CI Godot import, all gameplay regressions, actual landscape image renders and Web export pass.
- [ ] Historical Pages preservation check passes.
- [ ] Inspect original before/after screenshots and ensure the new architecture visibly improves chase and oblique phone views.
- [ ] Merge only after successful checks; then verify main Godot, archive, health, Pages, immutable skyway-v143/build.txt revision and five HTTP 200 build files. Never claim V143 is live before these checks.
- [ ] Real iPhone Safari FPS, clipping and a full manually controlled three-question round are not covered by headless CI.
- [ ] The existing >1GB Pages artifact warning remains open; no historical build deletion is allowed.


## First actual OpenGL image review and sculpt correction
- First candidate CI produced eight isolated real landscape frames ([artifact 13081312119](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41301432702/artifacts/13081312119)); visually inspected chase and oblique. New cascades were prominent but had unnaturally flat rectangular crowns; the icicles sat behind the front surface.
- Measured changed pixels against the identical before state (max RGB-channel delta >25): 1280x720 chase **24,464 / 2.655%**, oblique **21,683 / 2.353%**; 1170x540 chase **13,708 / 2.170%**, oblique **12,105 / 1.916%**. These are visibility metrics, not iPhone FPS or high-end visual acceptance.
- Sculpt revision: uneven serrated ice crowns, tapered/undulating side silhouette and luminous 3D icicles moved to the visible camera-facing surface. Re-run full CI and compare the revised real images before merge.


## Final V143 release verification — 2026-11-01
- [x] Candidate PR [#131](https://github.com/mtothek0703/learnquest-unity-web/pull/131) merged as main release commit **4dbc6827ed4cd2b3041fc4ce82993879fe23eeed**. No experimental PR #111 code was merged.
- [x] [Final candidate Godot CI 41301708099](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41301708099) passed: import, gameplay, 3D geometry/pause/wrap regression, Web export and eight actual landscape images.
- [x] [Main Godot CI 41301966447](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41301966447) **SUCCESS**; [main archive check 41301966469](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41301966469) **SUCCESS**; [health check 41301966458](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41301966458) **SUCCESS**.
- [x] [Pages publication 41301966452](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41301966452) **SUCCESS**. Existing **140 historical version directories** preserved, Unity original archive retained. A brand-new immutable [skyway-v143](https://mtothek0703.github.io/learnquest-unity-web/skyway-v143/) created; the workflow explicitly rejected overwrite if V143 already existed.
- [x] Workflow independently fetched live public **build.txt, index.html, index.js, index.wasm, index.pck**: all **HTTP 200**, and compared build.txt with exact main release SHA 4dbc6827ed4cd2b3041fc4ce82993879fe23eeed.
- [x] [Final real OpenGL comparison artifact 13081807038](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41301708099/artifacts/13081807038) visually inspected. At 1280x720, 22,541 changed pixels (2.446%) chase, 19,982 (2.168%) oblique. At 1170x540, 12,667 (2.005%) chase, 11,183 (1.770%) oblique. Jagged sculpted ice crowns and illuminated icicles are visible in both views.
- [ ] Pages artifact **1,442,926,701 bytes** triggers GitHub's 1-GB warning; deployment succeeded but long-term storage needs a separate archive-safe solution. Do not delete or overwrite older releases.
- [ ] Real physical iPhone Safari FPS, clipping and full manual touch-controlled three-English-question round remain unverified.
