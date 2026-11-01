# 2026-11-01 — Track B: CC0 original-skin athletic silhouette trial

## Preflight
- Read both mandatory policy documents from `main`; verified the **Primary** GitHub account `mtothek0703`, repo `mtothek0703/learnquest-unity-web` (ID 1427565370).
- PR #111 remains DRAFT and on its separate branch. The title does not reserve V124 or any later release number.
- Track A is independently testing a tighter playable landscape camera in PR #133. No CC0 work is included in that stable candidate.

## Original geometric changes
- Reprofile the **actual 65-bone CC0 source body's GPU-skinned vertex geometry**: reduce broad chest/shoulder inflation, narrow hips, and change thigh width/depth from extra expansion to a restrained athletic taper. Keep imported skeleton, Skin, four normalized weights, topology and material count intact.
- Adjust the separately four-weighted real skinned trouser/knee shell so the old balloon-like knee cylinders do not restore the oversized silhouette. Keep the sculpted boots, feet, touch and collision logic unchanged.
- Expand `rider_external_body_resculpt_test.gd` to assert that the actual original skinned thigh contracts in both width and depth; adjust the knee dimensionality threshold to match the less bulky but still sculpted armor.

## Quality gate
- [ ] Full Godot PR validation, 65-bone rig/skin, body/lower-garment geometry, Web export and visual capture suite green.
- [ ] Inspect actual new and previous 16:9/19.5:9 images (front, chase, jumps, Turbo) and check whether the **whole** rider looks substantially better, not just numerical pixel differences.
- [ ] Confirm no shoulder/hip/knee clipping or silhouette loss in motion. Physical iPhone Safari FPS and touch play-through remain unverified.
- [ ] Do **not** merge PR #111 or claim a stable release until visual QA clearly passes; old Skyway URLs and Unity archive remain untouched.

## Follow-up
Compare the complete character in menu and chase views, especially collar/shoulder and thigh-to-boot transitions. If the silhouette still reads as toy-like, keep PR #111 in DRAFT and continue broader visual redesign.

## Actual validation and visual decision
- [x] First candidate CI failed the new thigh-taper assertion because its absolute depth threshold was too aggressive for the imported CC0 mesh's original bounds. The test was corrected to require **real contraction in both axes**, independent of source proportions.
- [x] Final [Godot PR CI run 41311222108](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41311222108) completed **success**, including original 65-bone skin, gameplay regressions, Web export and landscape render steps.
- [x] Downloaded actual [24-frame current character QA artifact 13085194546](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41311222108/artifacts/13085194546) and compared identical `*_after.png` views with the prior successful [artifact 13084013447](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41308097794/artifacts/13084013447).
- At 1280x720, max-channel RGB difference >25: **5,120 px (0.556%) front detail**, **2,948 px (0.320%) chase detail**, **2,522 px (0.274%) front wide**, **1,427 px (0.155%) chase wide**.
- [ ] **VISUAL HOLD RETAINED:** thighs/knees are marginally less balloon-like, but the oversized collar/shoulder silhouette and cartoon-like whole-character proportions still dominate. These actual screenshots do **not** establish the high-quality character gate. PR #111 stays DRAFT and is not merged.
- [ ] Real iPhone FPS, clipping in all poses and manual touch run still need device testing.
