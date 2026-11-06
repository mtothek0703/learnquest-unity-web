# Adventure A2 – reversible race pause bridge (2026-11-06 10:10 CET)

## Ausgangspunkt
Primary GitHub `mtothek0703 / michael_kohler1@yahoo.de`; repository `mtothek0703/learnquest-unity-web`; fresh branch `feature/adventure-a2-race-pause-bridge-20261106-1010` from main `0e01246620d33a9afcbb617152748adac4402993`. Before writing, read `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md` from main.

## Change
Added `godot/adventure/race_pause_bridge.gd`: explicit allow gate, reversible pausing of supplied runner simulation nodes, duplicate/invalid-node rejection, abort and exit cleanup. Existing `world.gd`, runner gestures, learning tasks, power-ups, worlds, archives and releases remain untouched. The bridge is NOT yet connected to the live race; therefore this is not a playable vertical slice.

## Acceptance criteria
- Disallowed entry changes no node.
- Valid entry disables explicitly supplied race/hazard nodes, without globally pausing the scene tree.
- Return, abort and removal restore original process modes.
- Duplicate entry and duplicate node arguments fail safely.
- Integration must later ensure physics/scrolling/hazards and timers are included in the explicit paused node set; runtime timer ownership needs inspection.

## Tests
Added `godot/adventure/race_pause_bridge_test.gd` for those conditions. Proposed command: `godot --headless --path godot --script res://adventure/race_pause_bridge_test.gd`.
**Executed tests: none** (no Godot runtime or CI run confirmed during this connector-only sprint). No import, WebGL export, actual 16:9/19.5:9 frames, iPhone Safari, archive protection or Pages validation performed. No FPS or touch claims.

## Result and next step
Code committed on isolated feature branch. Next: run Godot 4.4.1 test, identify exact race/hazard owners in `world.gd`, wire only at verified race-safe entry after three questions, then connect arena/portal, ensure resume preserves XP and boss progress. Do not merge/release without required quality gates. PR #111 remains independent; no old camera PR merge.
