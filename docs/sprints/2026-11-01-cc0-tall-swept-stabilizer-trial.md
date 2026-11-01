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
