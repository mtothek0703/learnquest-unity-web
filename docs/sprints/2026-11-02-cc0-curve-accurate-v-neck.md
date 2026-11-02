# 2026-11-02 – CC0 four-weight curved V-neck seam (DRAFT visual trial)

## Problem and actual change
The 65-bone CC0 flight jacket previously clipped original skinned triangles against a curved front V using linear interpolation of the signed endpoint distances. That is not the true intersection with a curved surface, and can leave uneven triangles above the intended neckline. The jacket now uses a **16-iteration bisection against the actual curved front neckline**, interpolating the same original four Skin influences at each new vertex. The front V is deepened from 5.2% to 6.8% of the source height, without changing the original GLB, Skeleton3D, inverse binds, board, touch or gameplay.

The existing `rider_external_skinned_outfit_test.gd` now verifies the deeper bilateral front opening, two precise nonlinear seam intersections within 0.001 source units, normalized four-bone weights and the full original 65-bone rig.

## Evidence
- Code: [445b99d5](https://github.com/mtothek0703/learnquest-unity-web/commit/445b99d52dd651d387b15f9e5acb998767af1b5a), tests: [589bc1cc](https://github.com/mtothek0703/learnquest-unity-web/commit/589bc1cc09716a8303e83a58d0e617f51b86e8b2).
- [Full Godot CI 41371847362](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41371847362): **SUCCESS, 52/52 steps**, including imported Skin/pose regression, gameplay, web export and real landscape capture.
- Compared the identical named 1280×720/1170×540 actual Godot OpenGL images in artifacts `13107697616` (previous draft, 79d29a65) and `13109562426` (new draft, 589bc1cc). At max RGB channel delta >25: **835 pixels / 0.0906%** in complete 1280×720 chase; **353 / 0.0383%** in complete front; **1,812 / 0.1966%** in chase detail. Both renders were inspected; the difference is subtle, not a meaningful overall redesign.
- The initial code-only CI [41371828472](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41371828472) failed because the older synthetic collar test vertices sat above the newly lowered V. The synthetic test was corrected to cross the new curve and to verify the true nonlinear intersection. Do not conceal the intermediate failure.

## Gate
- [x] Original four-weight skin, 65-bone pose, gameplay, web export and render automation.
- [x] Real same-camera front/chase A/B comparison, with limited effect recorded honestly.
- [ ] A visibly higher-quality coherent character/board than the stable V123/V150 reference.
- [ ] Manual all-pose clipping, real iPhone Safari landscape FPS and complete three-question-to-full-round touch playthrough.

**NO MERGE / NO RELEASE.** PR #111 stays DRAFT; no release number reserved. Stable main remains independent and all historical Skyway versions and Unity archive are untouched.
