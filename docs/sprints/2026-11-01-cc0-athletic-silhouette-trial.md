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
