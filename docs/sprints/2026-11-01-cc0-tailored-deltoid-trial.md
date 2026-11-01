# 2026-11-01 — DRAFT PR #111: narrower true 65-bone weighted deltoid trial

## Source and safeguards
Read LEARNQUEST_SPRINTS.md and LEARNQUEST_RELEASE_POLICY.md from main. GitHub Primary account mtothek0703 and repo mtothek0703/learnquest-unity-web verified. Stable V142 remains separate. This is NOT a release; PR #111 stays DRAFT and its old title reserves no version.

## Actual change
- Tailor the two original-CC0-Skin, four-weight sleeves at the shoulder: reduce the previous lateral bulk from approximately 0.116m to 0.092m in a deterministic rest-space sample (~21% narrower), while preserving raised rounded cap, symmetrical front/back curvature, elbow bellows and forearm volume.
- The surface is still extracted from the real CC0 imported triangles and driven by the same 65-bone rig; no rigid primitive, new paid asset, collision or touch-control change.
- Update the existing original-Skin sleeve regression to reject the old oversized shoulder profile, while preserving strict four-weight normalization, left/right symmetry, joint response and rounded cap checks.
- The existing full isolated 108-frame 16:9/19.5:9 sleeve QA remains the comparison pipeline; a technical CI pass does not certify high-end graphics.

## Quality gate
- [ ] Full Godot PR CI, export, skinning tests and 108 actual landscape renders pass.
- [ ] Compare real original frames against previous b960bfcc6d2 build at identical poses. Report source-only drift and any actual clipping/appearance findings.
- [ ] Overall character aesthetic still requires independent manual visual approval; do not merge into main or reserve a Skyway version.
- [ ] Real iPhone FPS, full three-question touch run and all-pose clipping remain unverified.


## Verified technical CI and original landscape comparison
- [x] [Full 52-step Godot CI 41301552434](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41301552434) **completed/success** at source-code commit c7f8961eb5e2c8c9a6ab41b24a79a655862206dd. Original CC0 rig, weighted sleeves, all regressions, Godot Web export and 108 source/garment-isolated landscape frames passed.
- [x] Downloaded and inspected both original Godot 108-frame sets: [previous 13080240484](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41296482557/artifacts/13080240484) and [new 13082101000](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41301552434/artifacts/13082101000). The narrower shoulder changes the genuine sleeve geometry, but the full figure still reads as a toy-like wide-collared model.
- [x] At identical 1280x720 camera/pose with max RGB channel delta >25, full rider front **3,091 px / 0.335%**, chase **3,305 px / 0.359%**; isolated weighted-sleeve front **2,722 px / 0.295%**, chase **3,757 px / 0.408%**. The source-only control itself drifted **1,227 px / 0.133%** front and **807 px / 0.088%** chase, so these numbers are not pure quality proof.
- [ ] **VISUAL HOLD remains:** broad collar/shoulder silhouette is still dominant in full-rider front view. Next meaningful experiment should target the actual four-weight tailored jacket shoulder/collar surface and preserve the 65-bone source. No stable merge, no reserved version and no manual iPhone QA claim.
