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
