# LearnQuest Adventure A2 – reward ledger (2026-11-06 04:10 CET)

## Basis and account
Primary GitHub mtothek0703 / michael_kohler1@yahoo.de; repository mtothek0703/learnquest-unity-web; fresh feature branch from main 0e01246620d33a9afcbb617152748adac4402993. Read on main: LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md.

## Change
Added a pure, session-local Neon City mission reward gate. It grants 40 XP and one star once per unique session/world pair, only after the caller explicitly verifies completion. Unknown worlds, incomplete objectives and empty session IDs are rejected. Reset affects only the specified session. Existing runner state, XP, quiz, touch gestures, builds and archive are untouched. This is a building block; **not wired into world.gd**, so there is no playable reward yet. PR #146's arena/mission work must be checked and integrated before use.

## Acceptance criteria
- Completion gate required; exactly one reward per session.
- No cross-session contamination, retry resets the correct session.
- Unknown world rejected; no changes to existing runner or historical builds.

## Test status
Added godot/adventure/adventure_reward_ledger_test.gd. Intended command: `godot --headless --path godot --script res://adventure/adventure_reward_ledger_test.gd`.
**Not executed:** no Godot test, import, export, real 16:9/19.5:9 render, iPhone Safari, Pages or HTTP checks performed in this run. Code committed only. Do not merge/release without those gates.

## Follow-up
Inspect PR #146 current branch and CI; integrate ledger only after mission/portal completion and verify XP/stars are applied by the existing runner once, not twice. Then add end-to-end transition and headless tests. PR #111 stays draft; #133/#144 not merged.
