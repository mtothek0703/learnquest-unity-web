# LearnQuest 3D — 2026-11-01 — Skyway V150 candidate: 3D slalom lane beacons

## Scope / account
- GitHub Primary `mtothek0703` / `michael_kohler1@yahoo.de`, repository `mtothek0703/learnquest-unity-web`.
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before work. Base main `bc3f9ac1d576d261509c210cf1c39dc60483bff8` (V149).
- Stable track A branch `sprint-v150-weave-lane-beacons`, PR #139. Independent draft track B PR #111 is **not** part of this release.

## Gameplay change
- After the first energy-gate pickup, gates in a **different** lane now display a floating, luminous magenta 3D halo and downward pointer. This teaches the next correct steering choice in a way readable from the chase camera on phone landscape.
- Same-lane, collected, hidden and recycled gates do not display guidance. A completed three-gate mastery, damage reset, results or replay clears it. Guidance is a visual-only Node3D: no collision bodies, input changes or additional power-ups.
- The guide uses shared TorusMesh, PrismMesh and material across seven existing energy gates, avoiding unique mesh allocations per gate. The ring bobs gently and rotates while active.

## Acceptance and validation
- `godot/energy_weave_mastery_test.gd` now checks alternate vs same lane, absence of collision objects, hidden guides on mastery, mandatory three English tasks, damage reset, capped XP/Turbo, result and replay.
- `godot/energy_weave_visual_capture_test.gd` compares real rendered beacon-off/on frames in both 1280×720 and 1170×540 in addition to existing mastery pulse QA; 16 changed color samples are required at each ratio.
- Required before merge: successful PR Godot CI and visual QA, export; on main Godot CI, archive preservation, health check, Pages deploy, five immutable V150 URLs HTTP 200, `build.txt` matching main SHA. Never overwrite V149 or older / Unity archive.
- No real iPhone Safari FPS, clipping or manual full touch playthrough is implied by automated tests.

## Status
- **Candidate only** until workflow checks and release deployment are independently verified. Do not claim V150 released before evidence.
- PR #111 remains DRAFT and its title reserves no version.
