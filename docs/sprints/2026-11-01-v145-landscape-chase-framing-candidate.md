# 2026-11-01 — Track A: V145 landscape chase camera candidate

## Preflight and scope
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before work.
- Verified authenticated Primary GitHub user `mtothek0703` (ID 339490599), repository `mtothek0703/learnquest-unity-web` (ID 1427565370), and initial `main` head `c9ca7b4854916aef72852fc82d6863f2d26de407`.
- Last independently documented immutable stable build is **V144** (commit `f7a8a9d5`, Pages run `41306881518`). V145 is a **candidate only** until full gates pass. Never overwrite historical Skyway URLs.
- Separate CC0 65-bone PR #111 remains **DRAFT**; no changes or version reservation in that branch.

## Playable improvement
- Reframe the **actual gameplay chase camera** for a more readable 3D rider and race corridor on phone landscape: normal camera distance 9.0 -> 7.15, vertical position 4.3 -> 4.05, field of view 64 -> 58 degrees.
- Turbo retains a deliberate wide-angle pullback: distance 10.1 -> 8.7 and FOV 74 -> 70. Front-facing menu camera and all gameplay/touch/physics remain unchanged.
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
