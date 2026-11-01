# 2026-11-02 — Original CC0 shoulder/deltoid silhouette, DRAFT

## Scope / release discipline
- Authenticated GitHub Primary `mtothek0703`; repository `mtothek0703/learnquest-unity-web`.
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before changes.
- Stable main remains `d0f981fd3f681bfd1aa23553e47b64d62e9efd71` / independently verified Skyway V150; no stable-release candidate is claimed by this experiment.
- Work only on `sprint-v124-quaternius-rigged-hero` / [DRAFT PR #111](https://github.com/mtothek0703/learnquest-unity-web/pull/111). The PR title reserves **no** version number.

## Root cause and implementation
The prior genuine 1280×720 isolated `source_only` front/chase captures identified a wide shoulder shelf in the imported CC0 source body even when graphite armor and other overlays were hidden. Recoloring or narrowing those overlays did not fix it.

`godot/rider_external_body_resculpt.gd` now adds a smooth symmetric rest-space contraction of the **original imported, GPU-skinned source triangles** across the outer trapezius/deltoid at normalized height 0.738. A Gaussian height envelope and lateral smoothstep window (normalized `side` 0.25–0.83) contract up to 10.5% of local lateral displacement and 4.8% of depth displacement. The effect fades below the armpit and before the hand tips; original chest/waist, face, feet and board contact remain unchanged.

No new geometry objects, colliders, texture dependencies or external licenses; all original 65-bone skeleton, four weights per vertex, mesh topology, triangle indices and material slots are preserved. The existing finite-difference normal transform follows the modified sculpt Jacobian.

`godot/rider_external_body_resculpt_test.gd` adds explicit geometric regression for outer-shoulder narrowing in both axes, bilateral symmetry, armpit fade and hand preservation, alongside the existing original-Skin, bone, normal, chest, thigh, face, feet and no-collision checks.

## Required validation
1. **CI:** Final branch-head Godot import, source-body geometry regression, 65-bone skinning, gameplay, web export and landscape image capture must pass. Do not equate a green source-code check with visual approval.
2. **Visual QA:** Compare same-pose 1280×720 and 1170×540 genuine OpenGL frames for `source_only`, `skin_layers` and `complete_rider`, front and chase. Check that the source shoulder and final silhouette actually improve without armpit seams, shoulder collapse or clipping.
3. **Mobile QA:** Real iPhone FPS, full three-English-question touch round, four worlds, bosses and four power-ups remain **unverified on hardware**.
4. **Release:** Keep PR #111 DRAFT / VISUAL HOLD. Do not merge or publish a new Skyway URL until the full high-quality character acceptance passes. Keep all historical Skyway builds and Unity archive untouched.

## Initial commits
- Source-body sculpt: `830556b4fb7f1aad85b76a5b43923ad5ab3f9e42`.
- Regression: `abdc2c404dfdf92ecb8228f78dd5d5b61432dc20`.

## Outcome
Pending final CI and actual rendered-frame comparison; no release claimed. If the full character remains toy-like or visually worse, retain DRAFT status and adjust/revert only after inspecting the actual CI artifacts.
