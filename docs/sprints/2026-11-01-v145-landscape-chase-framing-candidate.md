# 2026-11-01 — Track A: V145 landscape chase camera candidate

## Preflight and scope
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before work.
- Verified authenticated Primary GitHub user `mtothek0703` (ID 339490599), repository `mtothek0703/learnquest-unity-web` (ID 1427565370), and initial `main` head `c9ca7b4854916aef72852fc82d6863f2d26de407`.
- Last independently documented immutable stable build is **V144** (commit `f7a8a9d5`, Pages run `41306881518`). V145 is a **candidate only** until full gates pass. Never overwrite historical Skyway URLs.
- Separate CC0 65-bone PR #111 remains **DRAFT**; no changes or version reservation in that branch.

## Playable improvement
- Reframe the **actual gameplay chase camera** for a more readable 3D rider and race corridor on phone landscape: normal camera distance 9.0 -> 7.75, vertical position 4.3 -> 4.15, field of view 64 -> 60 degrees.
- Turbo retains a deliberate wide-angle pullback: distance 10.1 -> 9.1 and FOV 74 -> 71. Front-facing menu camera and all gameplay/touch/physics remain unchanged.
- New headless regression `chase_camera_framing_test.gd` checks all three lanes at 1280x720 and 1170x540, Turbo widening and unchanged menu view.
- New real OpenGL `chase_camera_visual_capture_test.gd` renders eight actual race before/after images (center/right lane, both ratios) and checks >=15% projected rider-size increase plus nontrivial image difference.
- PR CI integrates both tests and uploads the eight screenshots for **human visual QA**. A rendered-image threshold alone does not establish no clipping, premium quality or physical iPhone FPS.

## Release gate — not yet met
- [ ] Headless Godot gameplay, skinning, camera and boss regressions pass.
- [ ] Web export and PR historical-archive protection pass.
- [ ] OpenGL screenshots from both landscape ratios pass and are **actually inspected** for rider cropping, HUD overlap, world visibility and no obvious geometry defects.
- [ ] Only after approval, update release workflow to next genuinely unused version (V145 if still free), add release gates, merge PR and verify main CI, Pages, exact build revision, HTTP 200 for five build files and archive preservation.
- [ ] Real physical iPhone Safari FPS, touch-run and clipping tests remain unverified and must never be claimed as automated.
- [ ] Existing >1 GB Pages artifact warning persists; do not remove any old immutable versions or Unity archive.

## Next step
Review real CI logs and screenshot artifact; adjust composition if necessary. If visual quality fails, retain as candidate rather than publishing a number-only release.

## Actual V145 image inspection and corrective pass
- [x] Initial candidate passed full PR CI and archive protection: [Godot run 41311046684](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41311046684), [archive run 41311041739](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41311041739). Eight actual before/after OpenGL frames were downloaded from artifact `13085675191` and inspected at both 1280x720 and 1170x540.
- [x] The original 7.15m / 58-degree zoom was clearly more legible, but **too aggressive**: helmet nearly touched the top and the hoverboard ion-wake tails were clipped at the bottom, especially at 1170x540. Do **not** release this version.
- [x] Corrected the camera to 7.75m / 60 degrees and 4.15m elevation; Turbo uses 9.1m / 71 degrees. Kept the >=15% larger projected rider gate and all three lanes visible.
- [ ] Repeat full CI, download the revised eight frames, visually check actual margins, then release only if the composition is better without cropping.

## Second image review — edge-lane clearance
- [x] [Godot CI 41311462004](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41311462004) and [archive check 41311461858](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41311461858) passed on the 7.75m / 60-degree revision. Downloaded and inspected all eight actual [frames 13086045577](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41311462004/artifacts/13086045577).
- [x] The center lane now retains helmet and wake margins, and the world/rider are visibly larger. At 1280x720 the new framing changes 55.61% of RGB pixels (>25 channel difference) in center lane, 52.72% in right lane; at 1170x540 it changes 54.76% / 52.34%. These large changes are from the camera projection, **not** proof of a premium character.
- [ ] **Remaining QA issue:** at the outer right lane the trailing hoverboard ion-wake ribbons still approach the bottom edge, particularly at 1280x720. Do not merge this iteration.
- [x] Third correction: adaptive normal camera pullback from **7.75m / 60° in center** to **8.15m / 61° at outer lanes**. Keep Turbo at 9.1m / 71° and menu unchanged; the camera follows the rider's actual lane position, not a new input mechanism.
- [ ] Re-run all checks and inspect the new lane1/center 16:9 and 19.5:9 screenshots before merging.

## Third image review — final edge-lane focus adjustment
- [x] Adaptive distance revision passed [Godot PR CI 41311954192](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41311954192) and [archive protection 41311954044](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41311954044). Downloaded [eight actual frames 13085566597](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41311954192/artifacts/13085566597) and inspected all lane/aspect combinations.
- [x] At 1280x720, the adaptive center/right-lane views differ from the old chase camera by 55.61% / 45.27% of pixels (>25 RGB-channel difference); at 1170x540 by 54.72% / 44.61%. The rider and road are clearly larger; all three steering lanes remain available.
- [ ] The **outer-lane wake ribbons still nearly touch the bottom frame edge**. Preserve the more readable zoom but lower the edge-lane focus by 0.25 world units (1.5 -> 1.25), shifting the board upward without moving menu, controls or physics.
- [ ] Run the updated headless focus assertion and all visual/export/archive checks, inspect the new final frames, and only then decide on immutable V145 release.
