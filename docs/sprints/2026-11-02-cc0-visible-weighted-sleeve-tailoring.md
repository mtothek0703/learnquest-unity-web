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

Status: **52/52 CI success, real landscape comparison completed; overall visual acceptance NOT achieved**. No high-end claim or stable release.

## Final CI and actual 108-frame visual comparison
- [Final Godot PR CI 41362731621](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41362731621): **52/52 steps SUCCESS**, including original 65-bone Skin, gameplay regression, Godot Webexport and 108 genuine isolated costume frames. The final documentation-only commit does not change tested runtime code.
- Downloaded the new [108-layer artifact 13105829152](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41362731621/artifacts/13105829152) and the prior [108-layer artifact 13106180271](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41362116915/artifacts/13106180271); inspected matching 1280×720 and 1170×540 front/chase images and computed RGB max-channel >25 pixel differences.
- **1280×720 front:** weighted-sleeves isolated 2,812 pixels (0.305%) changed; source-only control 1,130 (0.123%). Full rider with sleeves 4,925 (0.534%); without-sleeves control 3,801 (0.412%).
- **1280×720 chase:** weighted-sleeves isolated 3,122 (0.339%); source-only control 1,148 (0.125%). Full rider with sleeves 9,841 (1.068%); without-sleeves control 8,804 (0.955%).
- **1170×540 chase:** isolated sleeves 1,743 (0.276%); source-only control 658 (0.104%). Full rider with sleeves 5,530 (0.875%); without-sleeves control 4,969 (0.786%).
- Genuine side-by-side review: the source-skinned sleeve caps are subtly slimmer, but the **complete hero still has a wide jacket/collar/upper-torso shelf and exaggerated head**. Much of the full-frame change is unrelated pose/render drift, as shown by the controls. **No convincing high-end visual quality gain**; PR remains DRAFT and no new Skyway version is justified.
- Keep the slimmer source-weighted sleeve geometry as an isolated, reversible DRAFT groundwork, not a release-approved feature. Next effort must reshape the *combined* upper jacket neckline and sleeve shoulder envelope in one coordinated silhouette, rather than adding more microdetails.
