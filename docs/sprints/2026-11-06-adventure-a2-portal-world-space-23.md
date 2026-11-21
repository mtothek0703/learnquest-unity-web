# Adventure A2 – Portal world-space CI repair (2026-11-06 23:14 CET)

## Baseline and scope
Primary GitHub account: mtothek0703 / michael_kohler1@yahoo.de; repository: mtothek0703/learnquest-unity-web; branch: feature/adventure-a1-walkable-neon-testbed-20261106-19, DRAFT PR #157. Main HEAD verified before modification: 3117869390c6f3dff6409bfde1f64c2d184b0853. Read on main: LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md.

## Observed failure
PR head d1e30baaa2aa43cba44852fe317724d05facc3bf: Godot PR validation run 42295799262 failed in the actual adventure_bridge_test.gd with `ADVENTURE BRIDGE TEST FAILED: on-foot signal did not return to active race`. Godot 4.4.1 installation succeeded; game import/test stage failed. Later image artifact uploads also failed because prior rendering steps were skipped. Those secondary failures do not prove gameplay regression.

## Change
Commit 530e99faa8688cb419eea5619e28044c98efe520 fixes the coordinate-space mismatch in `godot/adventure/neon_walk_testbed.gd`: the walkable arena is positioned far away in world space to isolate it from the race, but `_request_return()` previously compared the player's global position to a *local* portal coordinate. Now the local portal position is transformed through `to_global(EXIT_PORTAL_POSITION)` before applying the existing 2m gate. No change to runner input, quiz, XP, archive, or release paths.

## Acceptance criteria and verification
- After 3 English questions, opt-in and 100m Neon City progress, enter the walkable area.
- All 3 crystals and 2 switches must be activated; remote remount remains blocked.
- Walking to the actual visible portal returns to the same race, with a single 75 XP reward and preserved race state.
- Execute `res://adventure/adventure_bridge_test.gd` in Godot 4.4.1 CI on this new commit; **pending** at documentation time.
- Existing PR validation, WebGL export, both landscape render ratios and real iPhone Safari remain **unverified** for this new commit. Do not merge or release.

## Result
Code fix committed; no successful post-fix CI or manual mobile validation claimed. DRAFT PR #157 remains unmerged. Next: inspect fresh CI; if green, add the first telegraphed child-friendly robot encounter in the same integrated vertical slice.
