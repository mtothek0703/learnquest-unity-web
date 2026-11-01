# 2026-11-02 — Original CC0 shoulder/deltoid silhouette, DRAFT

## Scope / release discipline
- Authenticated GitHub Primary `mtothek0703`; repository `mtothek0703/learnquest-unity-web`.
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before changes.
- Stable main remains `d0f981fd3f681bfd1aa23553e47b64d62e9efd71` / independently verified Skyway V150; no stable-release candidate is claimed by this experiment.
- Work only on `sprint-v124-quaternius-rigged-hero` / [DRAFT PR #111](https://github.com/mtothek0703/learnquest-unity-web/pull/111). The PR title reserves **no** version number.

## Root cause and implementation
The prior genuine 1280×720 isolated `source_only` front/chase captures identified a wide shoulder shelf in the imported CC0 source body even when graphite armor and other overlays were hidden. Recoloring or narrowing those overlays did not fix it.

`godot/rider_external_body_resculpt.gd` now adds a smooth symmetric rest-space contraction of the **original imported, GPU-skinned source triangles** across the outer trapezius/deltoid at normalized height 0.738. A Gaussian height envelope and lateral smoothstep window (normalized `side` 0.24–0.98) contract up to 16% of local lateral displacement and 6.5% of depth displacement. The effect fades below the armpit and before the hand tips; original chest/waist, face, feet and board contact remain unchanged.

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

## Actual first-trial results and corrective second pass
- [Godot CI 41361582346](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41361582346) **52/52 steps SUCCESS**, including imported original 65-bone skin, gameplay, web export and 24 real paired landscape source-body frames ([artifact 13106130299](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41361582346/artifacts/13106130299)).
- Downloaded those 24 PNGs and compared them with the preceding green [CI 41356436231 source-body artifact 13103890578](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41356436231/artifacts/13103890578). At 1280×720 the original-only chase `sculpted` frame differed by 967 pixels (0.105%) but the unchanged `original` control itself drifted by 572 pixels; the complete rider changed 4,169 pixels while its unchanged original control drifted by 4,067. **No convincing full-rider quality gain was visible.** This first taper therefore **failed the visual effectiveness gate** despite green CI.
- Root cause of weak effect: lateral mask faded at normalized side 0.83, before the actual wide outer deltoid edge. Second code pass [19885ee3](https://github.com/mtothek0703/learnquest-unity-web/commit/19885ee3bccee45e4eaa38462ec5bf960cd1bdd6) extends the taper to 0.98 and strengthens width/depth contraction to 16% / 6.5%; [27fb73b8](https://github.com/mtothek0703/learnquest-unity-web/commit/27fb73b8c5aa047dd3d18e7d9cff36a7a3130f81) requires real outer-edge contraction and untouched hand-height geometry.
- **Second pass is NOT accepted until its own final CI and genuine rendered frame comparison pass.** If visually ineffective, revert experimental sculpt/test while retaining this honest trial record. DRAFT #111 remains unmerged, no stable release.
