# LearnQuest Adventure CI regression — 2026-11-09 22:10 CET

## Verified baseline
Primary GitHub account mtothek0703 / michael_kohler1@yahoo.de, repository mtothek0703/learnquest-unity-web. Main commit 46e899a84c500243274badf71255bb2afec3186b. Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md on main before editing. Adventure DRAFT PR #157 head before change 8fba23199909b99c303fccea6118b0461b4af53f. Blender DRAFT PR #160 head 7d5fd8cfe0f0eb65d42bd2dd11bd876551a73906.

## CI finding and fix
Godot PR validation run 42690998943 FAILED at `ADVENTURE BRIDGE TEST FAILED: walking camera failed to recover its normal distance`. The prior gameplay change intentionally interpolates the camera toward its unblocked position, but the test required immediate recovery after a single physics frame. Updated `godot/adventure/adventure_bridge_test.gd` to wait 30 actual physics frames after obstacle removal, then assert that camera distance recovers. Gameplay camera smoothing and collision avoidance remain unchanged; runner and archived builds untouched. Code commit: 875af00f2dfc98aaf4f916944d6c0f140ff3d5d4.

## Acceptance criteria and verification
- Obstacle collision still pulls walking camera forward immediately (existing assertion retained).
- Once obstacle is removed, camera recovers beyond 7.5m after 30 physics frames, rather than being required to teleport on the first frame.
- Tests executed this run: GitHub CI log inspection of failed run 42690998943; no local Godot runtime test or new CI success established at documentation time.
- Blender PR #160 latest observed PR CI 42681487769: success, but screenshots have not been visually reviewed and iPhone Safari FPS not tested. Not released live.
- Pending: rerun CI on new PR head, inspect 1280x720 and 1170x540 real in-game screenshots, rig/animation/clipping, WebGL export, manual iPhone QA, immutable release/archive gates. No merge or release.
