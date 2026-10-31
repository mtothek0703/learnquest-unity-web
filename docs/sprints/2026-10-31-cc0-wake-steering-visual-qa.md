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

## First controlled CI and actual visual diagnosis
- [x] [Godot PR CI 41233730238](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41233730238) **completed/success** for the 16-frame QA code. Headless boost-wake regression and all 52 workflow steps passed; the actual renderer reported **2,131 sampled boost-on/off chase pixels** and **3,356 sampled left/right chase pixels** at a per-channel threshold of 0.08.
- [x] [Original 16 PNGs, artifact 13054832845](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41233730238/artifacts/13054832845) downloaded and **visually inspected**, not merely counted. In the chase view the old broad transparent exhaust surfaces form **oversized cyan/violet balloon-like lobes** that dominate the board edges and run beyond the lower camera frame. The left/right difference is real, but the visual design is not premium quality. Front-view jets are largely hidden behind the board.
- [x] **Second, substantive visual correction implemented in the same run:** the two existing procedural exhaust meshes are slimmer, shorter and more tapered, with less alpha overdraw. Original nozzle root, two draw calls, boost/lean steering, 65-bone rider, touch and gameplay remain untouched. The shape regression was adjusted to require a 2.2m+ jet and a positive tapered midsection instead of the old 2.5m+ oversized plume.
- [ ] **Second code-head CI and new 16-frame visual comparison still required.** Do not claim the slimmer jets are better until the revised Godot test, web export and actual chase/front frames are checked. No stable release or PR merge.

## Second controlled CI, visual review, and further refinement
- [x] [Godot PR CI 41234307593](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41234307593) **completed/success** with 52/52 steps including web export and 16 phone-landscape frames. Renderer counted **1,043 boost-on/off** and **2,363 left/right** sampled chase pixels.
- [x] [16 real revised PNGs, artifact 13055031889](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41234307593/artifacts/13055031889) downloaded and inspected side by side with artifact 13054832845. The cyan/violet surfaces are slimmer and more transparent, and steering asymmetry is preserved. **However**, their long perspective tails still reach the lower frame edge and visually read as oversized translucent sheets.
- [x] **Third correction:** shorten the continuous 3D trail from 2.25 to **1.50 world units** while preserving its nozzle anchor and left/right outside scaling, and soften alpha slightly. The test still requires a nonzero 1.45m+ real trail. No touch, physics, 65-bone, mission or release changes.
- [ ] Third code-head CI, web export and new 16-frame visual review pending. PR #111 remains DRAFT; no stable V136 or visual acceptance claim.

## Final verification — 31 October 2026, 20:40 CET
- [x] **Final code/test head `0ca316194223880fe2d69fed926967d05d5bd935` passed [Godot PR CI 41234807711](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41234807711): 52/52 steps SUCCESS**, including gameplay, original 65-bone skinning, sculpted-board/boost-wake geometry regression, Web export and all existing 16:9/19.5:9 visual capture gates. Documentation-only commits followed; they do not change tested code.
- [x] [16 final original PNGs, artifact 13054994217](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41234807711/artifacts/13054994217) downloaded and inspected in a controlled 1280x720 chase-camera before/after montage against the initial artifact 13054832845. The large cyan/violet plume lobes are now **visibly narrower, shorter and less dominant**. Left/right outside-wake asymmetry remains visible, with the jet root still at the original turbine plane.
- [x] Final same-session render QA measured **686 sampled on/off pixels** and **1,778 sampled left/right pixels** at RGB max-channel delta >0.08, in the two chase captures combined. Lower pixel count reflects the deliberately smaller visual footprint; it does not prove aesthetic superiority.
- [ ] **Whole-character art quality remains below acceptance**: rider silhouette, broad jacket/arms and remaining stylized jet sheets still need coherent redesign. Real iPhone Safari FPS, clipping and full three-question-to-touch-race testing are not done. PR #111 **remains DRAFT / VISUAL HOLD**, with no merge and no version reserved.
- [x] Stable channel remains [Skyway V135](https://mtothek0703.github.io/learnquest-unity-web/skyway-v135/) with previous successful main Godot, archive and Pages checks. No finished independent stable feature was created in this QA sprint; **no V136 release** and no immutable historic URL or Unity archive was modified.
