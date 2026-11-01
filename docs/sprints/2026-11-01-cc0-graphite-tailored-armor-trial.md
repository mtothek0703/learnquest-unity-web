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
**Godot CI passed for code + regression commit `4b98bfaf`:** [52/52 steps, run 41356436231](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41356436231), including import, gameplay, original 65-bone Skin, web export, and 108 isolated costume landscape frames ([artifact 13103476655](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41356436231/artifacts/13103476655)). The following documentation-only commit does not alter tested runtime code.

**Actual image QA (compared with previous green run 41353334715, artifact 13102836005):** 1280×720 front full rider: 9,461 pixels (1.027%) changed by RGB max channel >25; chase full rider: 9,758 (1.059%); isolated front skinned armor: 7,507 (0.815%); isolated chase armor: 3,967 (0.430%). Unchanged source-only chase control also drifted 1,376 pixels (0.149%), so raw pixel difference alone is **not** a quality score. Visually the chest is a little narrower/darker and the back shield less wide, but the face, collar, shoulder volume and total silhouette still look toy-like. **VISUAL HOLD continues; no merge, no release.**

**Follow-up:** solve the broad upper-sleeve/collar geometry as one coherent source-skinned silhouette, not another cosmetic color change; compare genuine 16:9/19.5:9 frames and perform actual iPhone FPS/clipping/full-touch-round QA before any acceptance.

## Root-cause isolation for the next sprint
Inspected the **actual CI isolated 1280×720 front costume frames** (`head_hair`, `other_costume`, `tailored_jacket`, `skinned_armor`, `weighted_sleeves`, `pauldrons`). The broad bright-blue neck/shoulder shelf remains present even with the new anatomical armor hidden: it belongs to the underlying original source-skin torso and is emphasized by `rider_quaternius_suit.gdshader` (bright cobalt/violet shoulder palette and emissive collar). Therefore further shrinking only `rider_external_skinned_armor.gd` cannot fix the main inflated shoulder silhouette. Next experiment must address **original source-weighted collar/upper torso surface** and matching jacket neckline coherently, preserving imported 65-bone weights, four worlds and controls. Capture the same isolated groups after any change to distinguish true geometry improvement from color-only differences.
