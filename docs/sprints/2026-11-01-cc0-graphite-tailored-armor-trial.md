# 2026-11-01 — CC0 source-skinned graphite armor tailoring (DRAFT trial)

## Scope and policy
- Repository `mtothek0703/learnquest-unity-web`, branch `sprint-v124-quaternius-rigged-hero`, PR #111, experimental lane only.
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before changes. Stable `main` was at `d0f981fd3f681bfd1aa23553e47b64d62e9efd71` (Skyway V150; last confirmed Pages run 41351901021).
- **No stable release, no main merge, no reserved version.** The 65-bone character remains visual-QA HOLD.

## Problem from genuine prior portrait frames
The broad glossy cobalt chest and rear shield visually inflate the shoulders and torso, obscuring the imported CC0 anatomy. A shader-only recolor is not sufficient.

## Experimental changes
- `rider_external_skinned_armor.gd`: reduce the actual curved, clipped source-skinned pectoral envelope from `0.16 + 0.16*shoulder - 0.105*neckline` to `0.125 + 0.145*shoulder - 0.105*neckline` and the rear shield from `0.105 + 0.105*shoulder - 0.070*neckline` to `0.085 + 0.095*shoulder - 0.060*neckline`.
- Keep the original CC0 Skin and four weighted influences per generated vertex. No new mesh instances, collisions, textures, licenses or game-control changes.
- Switch the panels from shiny cobalt toward rougher graphite blue (metallic 0.29 → 0.17; roughness 0.47 → 0.61). Narrower true 3D panel geometry is the main intended silhouette change.
- `rider_external_skinned_armor_test.gd`: new normalized torso-width checks for both front pectorals and rear shield, alongside existing Skin/geometry/clip checks.

## Acceptance gates
1. The PR's Godot regression, gameplay, Web export and actual landscape render captures must succeed on the **final commit**.
2. Compare actual before/after Godot 1280×720 and 1170×540 front/chase/action frames at identical pose and camera. Determine whether the change is meaningfully better, not merely different.
3. Do not merge PR #111 until high-end overall character, clipping and real iPhone landscape QA pass.
4. Stable main and all immutable Skyway URLs / Unity archive remain untouched.

## Status
**Experimental implementation committed; final CI and visual comparison pending.** Do not interpret changed constants or a green geometry test alone as a visually approved result.
