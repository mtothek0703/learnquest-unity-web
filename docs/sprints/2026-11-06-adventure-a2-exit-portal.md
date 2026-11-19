# 2026-11-06 – A2 exit portal (03:11 CET)

## Scope
Primary GitHub link (mtothek0703 / michael_kohler1@yahoo.de), repository and PR #146 adventure branch verified. Read on main: LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md (filename contains a space), LEARNQUEST_RELEASE_POLICY.md and docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md.

## Implemented
- ExitPortal placed in Neon City arena, with visible cylinder marker and separate PORTAL touch button.
- Requires three unique crystals and two switches, proximity <=2.2m and one-shot use; desktop F interaction.
- Emits exit_requested only; **no** unverified transition into the runner or reward writes. Existing runner remains untouched.
- Regression test for locked, partially complete, complete, duplicate, distance and reset cases.

## Acceptance / verification
- Source commits: 3859020990c2d4c436198482bc47cd77f5a14c8d, c68886a31fdbf2efaf0e273bb8d4928199308aed, 4193c42a5fd7b0963d95438148be0c54c66abae0.
- Test command: godot --headless --path godot --script res://adventure/adventure_exit_portal_test.gd
- **Not run**: Godot 4.4.1 binary not installed in this execution environment. No import, physics, web export, screenshot, iPhone QA, Pages or archive protection claim.
- No merge or release; DRAFT PR #146. Experimental character PR #111 remains independent.

## Next
Run Godot import and portal regression, inspect touch layout in 16:9/19.5:9; then integrate exit_requested into the existing session controller with a verified race pause/return and one-time reward logic.
