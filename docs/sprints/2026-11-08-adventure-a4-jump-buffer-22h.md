# LearnQuest Adventure A4 – early-jump input buffer (2026-11-08 22:18 CET)

## Verified scope
Primary GitHub account mtothek0703 / michael_kohler1@yahoo.de, repository mtothek0703/learnquest-unity-web, existing DRAFT PR #157 and its feature branch. Main read from GitHub branches API at `46bfea3ecbfa4db8cc755df8d7fab201706d8059`. All four required main documents read before modification. PR metadata reported a different base SHA `b901029`; no rebase/merge attempted. Prior PR head `222c61b` had a successful Godot PR validation run #42519564142.

## Change and acceptance
Walking-only `neon_walk_player.gd` now holds an early jump input for up to 0.14 seconds, permitting a jump pressed just before landing to activate upon grounding. Buffer expires automatically and is cleared by checkpoint respawn, Safari focus loss and regain. Runner touch code, quiz gating, worlds, rewards, historical builds and Unity archive untouched.

Acceptance criteria: early airborne jump survives one short physics step; checkpoint clears it; original bridge test continues to pass; no unintended runner behavior. The integration test `res://adventure/adventure_bridge_test.gd` now exercises airborne buffer and respawn cleanup.

## Evidence and outstanding gates
Gameplay commits `19dff39`, `bd51af5`; test commits `4b9d9d2`, `360d504`. Existing prior-head GitHub CI success is **not** a test result for these commits. No local Godot import, headless run, Web export, real 16:9/19.5:9 render or iPhone Safari test was executed in this sprint. Await fresh PR CI and fix any failure before integration. No merge or Skyway release. Existing licensed rider appearance still needs isolated inspection/adaptation; do not merge experimental PR #111.
