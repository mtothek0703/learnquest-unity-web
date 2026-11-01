# DRAFT PR #111 — integrated gull-wing hoverboard relief (1 November 2026)

## Scope and prerequisites
Both mandatory policy files were read from `main`; authenticated GitHub account `mtothek0703` and repository `mtothek0703/learnquest-unity-web` verified. Work remains on the experimental branch, not `main`. The stable release channel is independent; no release number is reserved by PR #111.

## Rejected portrait trial first
A trial reduction of the complete Head-attached portrait from 1.82 to 1.68 was attempted and guarded by a matching numeric test. Godot CI [41348115310](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41348115310) **failed** at the existing independent readability guard: `EXTERNAL HEADGEAR TEST FAILED: portrait too small for the experimental landscape review`. Rather than weakening that guard without actual phone-image acceptance, the portrait code and test were restored to the prior 1.82 proportions (revert commits `37cc71a5` and `7bbe9a0e`). No unverified portrait reduction is being shipped.

## New, independent 3D board trial
The sculpted hoverboard's **existing** port/starboard gull-wing surfaces now have a higher, smoother outboard chine and deeper underside relief: crest amplitude 0.12 → 0.19; undercut 0.028 → 0.040. The same mesh gains a slightly stronger satin highlight along its true 3D ridge. This is geometry in the existing GPU render mesh, not a new decorative primitive, extra collision, texture, draw call or altered physics.

- Code: `godot/hoverboard_sculpted_hull.gd` commit `c6362b57717a8213f068ed262882a9899b51f53a`.
- Regression: `godot/hoverboard_sculpted_hull_test.gd` commit `c4758fe5d09e66d084217b858e0bb3a883c4f5ca`; requires raised outboard crest and unchanged original board symmetry/controls.
- Preserved: original 65-bone CC0 rig, touch steering, three English tasks, four worlds, bosses, power-ups, old Skyway builds, Unity archive.

## Release / visual hold
- [ ] Await final CI for the new board geometry, gameplay regressions, Web export and landscape image generation. Report failure rather than claiming success.
- [ ] Compare real matched chase/oblique Godot images at 1280×720 and 1170×540 against the previous successful DRAFT. Confirm the new ridge is not hidden by the articulated fin and does not make the board too bulky.
- [ ] Real iPhone Safari FPS, full three-question + touch race, and all-pose clipping remain unverified.
- [ ] PR #111 remains **DRAFT / VISUAL HOLD**; no merge or new immutable release until quality approval.
