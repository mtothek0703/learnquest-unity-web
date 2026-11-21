# LearnQuest – 08.11.2026 07:14, Adventure checkpoint physics

## Preflight
Primary GitHub profile verified: mtothek0703 / michael_kohler1@yahoo.de. Repository mtothek0703/learnquest-unity-web, main 46bfea3ecbfa4db8cc755df8d7fab201706d8059, existing DRAFT branch feature/adventure-a1-walkable-neon-testbed-20261106-19. Branch before changes: e9ab29c99e9763486f791b710b65bc4f7a030627, 110 ahead / 2 behind main. Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md and docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md on main. Previous PR-head CI run 42450005525 reported success.

## Change
On-foot CharacterBody3D fall respawn now returns immediately from its physics tick, avoiding a fresh gravity/movement step immediately after zeroing velocity. Added a regression to adventure_bridge_test.gd that invokes the falling tick with stale velocity and asserts the checkpoint position and zero velocity.

## Acceptance and evidence
Expected: checkpoint position and velocity remain reset in the respawn tick; no changes to runner gestures, quiz, XP, power-ups, boss fights, Skyway archive or Unity. Code commits: d1ed7ff5eb96f22a2cecb7dc01747dd5ec904524 and fa9ee2ddaa386c53bd2efbab87c2edfcde937de2. Tests actually executed in this run: source-level preflight and test insertion only; Godot headless test, import, Web export, real 16:9/19.5:9 captures and iPhone Safari QA NOT executed. Await CI for new head. PR #157 remains DRAFT; no merge or release.

## Next
Check new CI, then implement safe reuse of licensed rider visuals in on-foot scene without importing runner controllers or experimental PR #111; keep gameplay and character tracks independent.
