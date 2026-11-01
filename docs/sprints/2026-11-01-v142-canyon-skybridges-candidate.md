# 2026-11-01 — Stable track A: Crystal Canyon sculpted sky bridges (V142 candidate)

## Scope and safeguards
Read both mandatory main policies. Verified GitHub Primary account mtothek0703 (ID 339490599) and repository mtothek0703/learnquest-unity-web (ID 1427565370). Starting main 4b6bf0e2, last verified immutable release V141. PR #111 is independent DRAFT / VISUAL HOLD; its title reserves no version.

## Implementation
- Four substantial continuous faceted rock arches span the Crystal Canyon racing corridor at high clearance. Each has a 32-segment fully volumetric shaded mesh, including top, underside, front and rear, with normals and vertex colors.
- 28 hanging crystalline keystones (seven per bridge) are batched into four MultiMeshes. One rock mesh is reused across all arches, no new textures, third-party assets, lights, collision bodies or physics.
- All bridges scroll at level speed, wrap without accumulating objects, and freeze during the mandatory three English questions.
- The existing three-lane touch controls, four worlds, bosses, four powers, historic Skyway directories and Unity archive are untouched.
- Existing canyon regression now validates real 3D volume, shading, safe vertical clearance, batched crystals, collision absence, movement and pause.
- Existing 16:9 / 19.5:9 capture pipeline now produces eight additional **isolated** bridge-before/after PNGs at identical cameras, alongside eight existing geode comparisons. The PR and release workflows enforce all 16 frames and a nontrivial visible-pixel threshold.

## Release gates
- [ ] Full PR Godot import, gameplay, regression, OpenGL images and Web export pass.
- [ ] Historical archive protection passes.
- [ ] Review real landscape frames and visible difference before considering merge.
- [ ] Only then select next free immutable version (expected V142), update version/build workflow, merge, verify main CI, Pages and exact build.txt SHA plus five HTTP 200 files.
- [ ] Real iPhone Safari FPS, full touch-controlled three-question round and all-pose clipping require manual device QA. Do not claim those passed.
- [ ] Pages artifact is already over 1.4 GB; preserve existing builds and address storage separately.

No release has been claimed at candidate creation.
