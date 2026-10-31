# LearnQuest 3D — DRAFT wake steering visual QA, 31 October 2026

## Scope and release separation
- Read mandatory `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` on `main` at the start of this run.
- Verified authenticated **Primary** GitHub account `mtothek0703`, repository `mtothek0703/learnquest-unity-web`, default branch `main`; the separate Grees Klimatechnik connection was not used.
- Latest separately verified stable release remains **Skyway V135**, main commit `1f64f2f30ace6b1512fa081a960425fe7cb91e42`. Main Godot run [41229294620](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41229294620), archive run [41229294659](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41229294659), Pages run [41229294674](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41229294674) all previously completed successfully. No independent new gameplay feature is ready in this run, so **do not manufacture V136**.
- The 65-bone CC0 figure and board remain in **DRAFT PR #111 / VISUAL HOLD**, no reserved version and no merge. No changes to main, Unity archive, historic Skyway directories, gameplay rules or touch controls.

## What changed
- Replaced the insufficient 8-frame *wake hidden vs wake visible* diagnostic with **16 actual phone-landscape frames**: `off`, `neutral`, `left`, `right`, in both front and chase cameras at 1280x720 and 1170x540.
- The existing wake geometry remains unchanged; this is a necessary controlled image-quality gate for the previous asymmetric 3D wake change, which had only passed headless geometry tests.
- Stop all rider-child animation processing during the comparison, manually drive existing cosmetic wake animation, and compare off/neutral and left/right pixels within the same renderer/session. This avoids claiming an effect solely from changes between unrelated CI runs.
- The test now requires a minimum real chase-camera image difference for both wake visibility and steering direction, rather than only for on/off. It reports sampled pixel counts for audit; pixel differences are **not** aesthetic approval.
- Both DRAFT Godot PR and release-workflow capture gates now require 16 PNGs, with existing archive and gameplay checks intact.

## Validation / acceptance
- [ ] Final DRAFT-head Godot CI (import, all gameplay and 65-bone regressions, 16 real frames, web export) must complete successfully before calling this test accepted.
- [ ] Review left/right PNGs in both phone landscape ratios. A nonzero pixel difference alone does not establish a meaningful visual improvement; manually inspect silhouette, jet attachment, readability and clipping.
- [ ] PR #111 stays DRAFT until the complete character and board pass holistic visual QA; real iPhone Safari FPS, touch, clipping and full three-English-question race remain outstanding.
- [ ] Pages artifact size above 1 GB remains an infrastructure concern; do not touch immutable builds to hide it.

Code/test work in `godot/hoverboard_boost_wake_visual_capture_test.gd`; CI expectations in `.github/workflows/godot-pr-check.yml` and `.github/workflows/publish-unity-webgl.yml`.
