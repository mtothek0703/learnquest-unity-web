# Adventure A4 – background physics guard (2026-11-08, 09:18 CET)

## Baseline and scope
Primary GitHub account: mtothek0703 / michael_kohler1@yahoo.de; repository mtothek0703/learnquest-unity-web. The four mandatory planning/release files were read from main before changes. Main baseline: `46bfea3ecbfa4db8cc755df8d7fab201706d8059`. Existing DRAFT PR #157, branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`, original head `ecd81c3fa105604a4cda55a84784df6dca0ee738`, 113 ahead / 2 behind main. No parallel A1 branch.

## Change
The independent on-foot CharacterBody3D now exits `_physics_process` when `input_paused` is true, including direct invocations. This avoids applying stale gravity or movement while the browser is backgrounded. The separate arena focus handler and runner touch logic are unchanged.

## Acceptance criteria
- A directly invoked walking physics tick during focus loss must preserve position and velocity.
- Existing focus-in clears queued inputs; ordinary movement and checkpoint physics remain functional.
- Runner, three entrance questions, four worlds, bosses, power-ups, historical Skyway and Unity archives unchanged.

## Verification
- Previously confirmed PR CI: GitHub Actions run #42453978445, success for former head `ecd81c3` only.
- New regression assertion added to `res://adventure/adventure_bridge_test.gd`.
- New code/test commits: `770363234e6557bcd53d0f42e8b413cb6f468901`, `0e01610cc61d1364a7cf58877951301268d10ff9`.
- **Not yet executed for the new head:** Godot import, headless gameplay regression, web export, real landscape screenshots, iPhone Safari QA. A committed test is not a passed test.

## Decision / next
Keep PR #157 DRAFT; do not merge or release. Await fresh CI, then integrate the existing licensed rider appearance without importing its runner controller; perform genuine 16:9/19.5:9 visual and device QA before any immutable release.
