# LearnQuest 3D – DRAFT airborne propulsion articulation (2026-11-01)

## Scope and safety

Both mandatory main-branch policies were read before this sprint. Primary GitHub identity and exact repository were checked. Last confirmed stable release before this work: Skyway V146. The experimental 65-bone CC0 character remains **PR #111 DRAFT / VISUAL HOLD**. No merge, release number reservation, archive or Unity modification.

## Actual 3D motion change

The two existing GPU-rendered triple-helical hoverboard exhaust meshes now respond to the real LegacyRider `jump_pose` state. During jumps they pitch up to **0.24 radians downward** relative to the board, as expected for active airborne propulsion. Both meshes pivot around their **existing turbine outlet coordinates** rather than the board origin, so the initial filament rings remain attached while the jets expand/contract on boost and outside-lane carving.

The adjustment uses only transforms on the two already-existing meshes; no extra geometry, draw calls, physics, input gestures, or asset licenses. The original 65-bone Skin and all four power-ups are untouched.

`hoverboard_boost_wake_test.gd` extends the existing geometry/boost/carve regression to check both outlet anchors, real downward jet displacement, landing return, and 30/60 FPS frame-rate consistency.

## Extended visual evidence

The existing wake visual capture now produces **20 actual 16:9/19.5:9 frames** (off, neutral boost, left carve, right carve, airborne boost) rather than 16. It compares airborne vs. neutral with a frozen rider pose and the same camera. Both PR and release workflow counts were updated; this is still a DRAFT-only quality gate.

## Acceptance

- [ ] Final Godot PR CI, 65-bone and gameplay regression, web export.
- [ ] Compare real 16:9/19.5:9 chase and oblique images at airborne boost poses. A successful geometry test alone does **not** prove improved visual quality.
- [ ] iPhone Safari FPS, touch and clothing/board clipping still require manual validation.
- [ ] Do not merge until the complete character/hoverboard passes visual review; later rebase on then-current main and use the next genuinely free immutable Skyway release number.

**Decision:** independent experimental improvement; not published.
