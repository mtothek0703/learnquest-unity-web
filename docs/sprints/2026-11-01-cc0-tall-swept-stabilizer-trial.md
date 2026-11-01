# 2026-11-01 — Track B: tall aft-raked hoverboard stabilizer experiment

## Policy and account
Read both required policy files on main and verified Primary GitHub account `mtothek0703`, repository `mtothek0703/learnquest-unity-web` (ID `1427565370`). Latest independently confirmed stable release was V143. Experimental PR #111 stays **DRAFT / VISUAL HOLD**, with no reserved version.

## Experimental change
- Increased the *rearward* swept rise of the two original closed 3D carve aerofoils from a quadratic coefficient of 0.18 to 0.30; the front hinge remains seated near the board.
- Preserved narrow tapered chord, smooth analytical normals, four existing mesh instances, time-based steer/boost motion, emissive 3D rails, original board and all touch/physics.
- Strengthened the geometry regression to demand >=0.19 units of aft crest rise. This tests actual geometry, not merely a shader color.
- Existing 24-image 16:9 / 19.5:9 OpenGL fin comparison and full 52-step Godot pipeline must run again.

## Gate
- [ ] New Godot CI and Web export pass; inspect original render artifacts for side/chase silhouette, clipping and whether taller fins genuinely improve art direction.
- [ ] If visually too tall or obstructive, revise/revert on DRAFT branch. Never merge to main without a full-character/board visual acceptance.
- [ ] Real iPhone FPS and full three-question touch-controlled round remain unverified.
- [ ] Stable track A has separate V144 orbital-crane candidate PR #132; do not let this draft block it.

## Actual QA outcome
- [x] [Godot PR CI 41306036023](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41306036023) **SUCCESS** after code and geometry-test commits. Includes the full 52-step Godot pipeline, Web export and 24 OpenGL fin frames.
- [x] [24 real landscape frames (artifact 13082623742)](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41306036023/artifacts/13082623742) downloaded and visually inspected. 1280×720 right-carve A/B (fin hidden versus visible) changes 2,651 pixels (0.288%) in chase and 5,078 pixels (0.551%) in three-quarter camera at >25 RGB-channel difference. This is a fin visibility metric, **not** proof of improvement versus the previous fin geometry.
- [ ] The taller aft vanes are visibly present but the full rider/board remains overly toy-like, with broad shoulder/back hardware and a crowded chase silhouette. **Visual approval withheld; PR #111 remains DRAFT, no merge/release.**
