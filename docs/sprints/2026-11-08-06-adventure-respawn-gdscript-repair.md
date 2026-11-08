# LearnQuest Adventure – 08.11.2026, 06:14 – GDScript respawn syntax repair

## Scope
Primary account: mtothek0703 (michael_kohler1@yahoo.de). Repository: mtothek0703/learnquest-unity-web. Existing DRAFT PR #157, branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`. Main before edit: `46bfea3ecbfa4db8cc755df8d7fab201706d8059`. All four required main policy/roadmap files read before editing.

## Defect and change
The previous facing-reset commit accidentally embedded **literal backslash-n sequences** inside `godot/adventure/neon_walk_player.gd` after `respawn()`. This makes the affected GDScript invalid rather than inserting newlines. Replaced the malformed span with actual GDScript lines; the visual now resets to yaw zero without rotating CharacterBody3D. No runner, world, release or archive files changed.

## Acceptance criteria
- Godot imports the walking player script without a parser error.
- `respawn()` clears velocity, jump, touch and sprint and resets only `WalkingVisual.rotation.y`.
- `res://adventure/adventure_bridge_test.gd` checks the respawn visual and unchanged collision-body rotation.
- Runner's original three-question gate, four worlds, four power-ups and old builds remain untouched.

## Evidence and limitations
- GitHub file contents were fetched and the literal `\\n` defect was directly verified; source correction committed as `82bfa677901afdd9a8a0a4d2e9bd73610e56217a`.
- **Not executed in this automation environment:** local Godot import, headless gameplay, web export, 16:9/19.5:9 renders, iPhone Safari QA. PR CI on the repaired head still needs confirmation; prior CI must not be attributed to this commit.
- Keep PR #157 DRAFT. No merge or release until all applicable gates pass. PR #111 remains independent.
