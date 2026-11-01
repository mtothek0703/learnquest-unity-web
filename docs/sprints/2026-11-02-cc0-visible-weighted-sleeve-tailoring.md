# 2026-11-02 — visible original-Skin sleeve tailoring (DRAFT)

## Starting point
- Required `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` read from main; GitHub Primary `mtothek0703`, repo `mtothek0703/learnquest-unity-web` verified.
- Main remains independently verified Skyway V150 (`d0f981fd`), with Godot, archive and Pages success. No main or historical build changes.
- [DRAFT PR #111](https://github.com/mtothek0703/learnquest-unity-web/pull/111) continues under visual quality HOLD; V124 is only its historic title, not a reserved release number.

## Genuine visual root cause
The preceding original-CC0-body sculpt passed [52/52 CI](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41362116915), and its isolated source-only chase shoulder changed 2,097 pixels. Yet the *complete rider* barely changed beyond control drift. Downloaded and inspected all [108 real isolated 16:9/19.5:9 costume-layer images](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41362116915/artifacts/13106180271). They show that the oversized upper shoulder in the visible rider is mainly the actual **original-Skin weighted sleeve shell and tailored jacket**, not merely the hidden underlying source body.

## This experimental change
- `rider_external_skinned_sleeves.gd`: reduce the real imported four-weight shoulder shell from `0.044 * shoulder + 0.015 * cap_crest` to `0.026 * shoulder + 0.012 * cap_crest`, and lateral shoulder sweep from `0.014 * shoulder + 0.007 * cap_crest` to `0.008 * shoulder + 0.005 * cap_crest`.
- Retain genuine curved crest, shoulder/elbow Skin, forearm shaping, normalized original four weights, source triangles, normals, skeleton, face, hoverboard and all gameplay.
- `rider_external_skinned_sleeves_test.gd`: assert the smaller but non-flat real deltoid envelope; existing symmetry, curved lighting, arm bone, elbow, wrist, no-collision and touch-fallback assertions remain.

## Acceptance / decision gate
1. Final-commit Godot PR CI, headless gameplay, 65-bone skinning, web export and landscape capture must all succeed.
2. Download **genuine** 1280×720 and 1170×540 front/chase frames. Compare with prior identical isolated sleeves, complete rider and control captures. Pixel difference alone is not a quality score; assess actual visible shape and clipping.
3. **Do not merge or publish** without clearly improved whole-rider silhouette. Keep PR #111 DRAFT, historical Skyway and Unity archive intact.
4. Real iPhone FPS, clipping and three-English-question full touch round remain hardware QA items.

Code commits: [f5ecc509](https://github.com/mtothek0703/learnquest-unity-web/commit/f5ecc509562438ab1eb81e762fce37ea3d5e7124), [0c16ece9](https://github.com/mtothek0703/learnquest-unity-web/commit/0c16ece94d867586c3eccfdc8cd2ed03ca2769e8).

Status: **experimental / CI and visual comparison pending**. Do not claim high-end acceptance or stable release.
