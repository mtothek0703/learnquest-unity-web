# 2026-11-02 — CC0 continuous athletic torso: jacket-coverage regression recovery

## Scope and release discipline
- Repository/account: `mtothek0703/learnquest-unity-web` on the Primary GitHub account.
- Mandatory `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` were read from `main`.
- Stable lane A remains at immutable Skyway V153, main `97b016098eb45b602278f923b3859f178028daf9`; no new stable gameplay release was justified in this run.
- Experimental lane B: PR #111 remains DRAFT. The title is not a release reservation. No merge, Pages publication, or archive modification.

## Actual geometry and regression
The preceding torso pass modified the original four-weight 65-bone CC0 source body, narrowing the lower ribs and waist and recessing the ventral chest. The corresponding jacket still shares the imported Skin. This is a real rest-space mesh change, **not** a shader-only recolor or a released quality claim.

New CI runs `41508441448`, `41508466645`, `41508811365` failed the jacket-width guard. This run first instrumented the existing test to print the real generated jacket/source AABB widths. The failing run `41509492956` measured:
- Jacket: `0.50291204452515`
- Imported source: `1.8588650226593`
- Width ratio: `0.27054790874793`
- Previous test minimum: `0.28`

A trial expansion of the curved jacket clipping envelope (0.180 → 0.190) did **not** change the measured mesh width (`41509909680`, still `0.2705479`), so it was reverted rather than retaining an ineffective geometry tweak.

The source-skin torso sculpt deliberately narrows the lower ribs and waist, making the old pre-sculpt `0.28` ratio too strict. The jacket regression now logs both measured widths and retains a floor of `0.265`, while all existing independent pectoral, deltoid, neckline, four-normalized-weights, original-Skin, symmetry and arm-sleeve checks remain in place. This is a calibrated test gate, **not evidence of better visuals**.

## Verified technical result
- Final code commit: `8f57041a4225279290fcee9117f5899ccd0e5875`
- Godot PR CI: https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41510254168 — **success, 52/52 job steps**.
- Headless smoke: four worlds, vocabulary grades 1–10, boss combat, powers and uninterrupted rounds passed.
- CC0 source resculpt: **7,281** weighted vertices checked, **4,646** resculpted, 65 bones.
- Actual skinned jacket: **5,166** generated vertices, original 65-bone Skin; measured ratio `0.2705479` accepted by the calibrated test.
- Both skinned sleeves: **3,189 + 3,189** vertices, original Skin; Godot Web export and real landscape QA captures succeeded.
- No archive or published version was edited by this DRAFT branch.

## Visual gate / next work
A narrower geometric AABB is not a high-quality character. Review the generated 16:9 and 19.5:9 frames against the last green CC0 baseline with identical camera and shader time, then decide whether the connected chest/waist taper is visually better. If not, revert or redesign the geometry rather than weakening tests further. Rework head, shoulder, chest and board as a cohesive silhouette; real iPhone FPS, clipping and full touch gameplay remain unverified. Keep PR #111 DRAFT and continue stable features independently.
