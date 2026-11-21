# LearnQuest Adventure A4 — separate walking sprint (08.11.2026, 02 Uhr)

## Ausgangslage
Primary GitHub account mtothek0703 (michael_kohler1@yahoo.de), repository mtothek0703/learnquest-unity-web, existing DRAFT PR #157, branch `feature/adventure-a1-walkable-neon-testbed-20261106-19` verified. Main comparison SHA `46bfea3ecbfa4db8cc755df8d7fab201706d8059` (PR behind main by 2 commits before change). Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md and docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md on main. Existing PR head before work: `60065cf3e85a8ce8ef4ff4dd7abdc4352d585a59`. Previous head PR Actions run 42424557834 completed successfully; this is NOT a test result for the new code.

## Change
Added a **walking-only** hold-to-sprint input: Shift on desktop, separate SPRINT button on mobile, 7.5 units/s instead of 5.0. Sprint releases on touch-up, checkpoint respawn and Safari focus loss. Existing runner gestures, 3 mandatory English questions, 4 worlds, boss battles, powers, XP, old Skyway builds and Unity archive were not edited. No new external assets or costs.

## Acceptance criteria and tests
- [x] Source-level implementation committed in `godot/adventure/neon_walk_player.gd` and `godot/adventure/neon_walk_testbed.gd`.
- [x] Regression assertions added to `godot/adventure/adventure_bridge_test.gd`: mobile button exists, hold activates, actual CharacterBody horizontal speed rises, release and respawn clear sprint.
- [ ] Godot 4.4.1 import: NOT run in this automation environment.
- [ ] Headless bridge regression: NOT run locally; wait for exact-head PR CI.
- [ ] Webexport, actual 16:9/19.5:9 render images, physical iPhone Safari touch QA: NOT run.
- [ ] Archive protection and five-file HTTP 200 release verification: NOT run. No release created.

## Commits and gate
Gameplay `2dc4c17`, mobile UI `2c75db6`, test `ca52080` in DRAFT PR #157. Do not merge/release until the new head passes CI and visual/mobile checks. Next: confirm current-head CI, fix any failure, then integrate the existing licensed rider model into walking without importing experimental PR #111 or changing the runner.
