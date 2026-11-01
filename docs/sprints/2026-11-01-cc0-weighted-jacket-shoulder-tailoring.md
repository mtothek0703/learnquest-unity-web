# 2026-11-01 — DRAFT PR #111: original-Skin jacket shoulder tailoring

## Scope and safeguards
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before the sprint. Verified GitHub Primary `mtothek0703` / `michael_kohler1@yahoo.de` and exact repository `mtothek0703/learnquest-unity-web`.
- This experiment remains isolated on DRAFT PR #111. No stable release, no reserved V124, no new external assets, no gameplay/touch/collision/Unity archive changes.
- Stable track A independently merged PR #132 for V144; check its deployment separately before claiming a live URL.

## Actual experimental geometry
- Refine `godot/rider_external_skinned_outfit.gd`: reduce the broad original-65-bone-Skin jacket shoulder spread from 0.060 to 0.043, deltoid spread 0.039 to 0.031, rear dorsal shoulder spread 0.039 to 0.036, and shoulder normal relief 0.050 to 0.040.
- Preserve source glTF triangles, imported four-bone Skin weights, collar, pectoral ridge, waist taper, original animation and shoulder symmetry. The new profile is a reversible source-weighted geometry change, not a rigid box or shader-only recolor.
- Fixed rest-space 1.4×3.0 AABB analytic sample: lateral shoulder offset approx. 0.0575 → 0.0416 (27.6% narrower); rear scapular offset approx. 0.0837 → 0.0655 (21.8% narrower). These are **geometry samples**, not claims of rendered image improvement.
- Strengthen existing jacket regression to reject the former wide front and rear profiles, retaining existing chest, collar, arm-weight, normal and skinning checks.

## Release and QA gates
- [ ] Verify latest PR-head Godot CI (65-bone Skin, gameplay regression, Web export and actual landscape renders).
- [ ] Download/compare original 1280×720 and 1170×540 front/chase images with previous PR-head at identical camera, report measurable visible impact and any clipping.
- [ ] Keep PR #111 DRAFT and visual quality HOLD until full character/hoverboard looks genuinely high quality and manual iPhone checks pass.
- [ ] Do not merge or release merely because tests are green.

## Initial CI correction
- First code commit `390154ee` failed Godot parse because escaped newline characters accidentally entered a comment. Corrected immediately in `93d2b322`.
- CI on corrected code (`41307984359`) reached the real outfit regression and found that the narrower rear shoulder had lost the required 0.018 source-unit dorsal-vs-ventral spread. Restored just enough rear shoulder sweep (0.028 → 0.036) to retain a genuinely sculpted scapular contour while remaining substantially narrower than the prior wide profile. Await a fresh final CI and original render comparison before any quality claim.
