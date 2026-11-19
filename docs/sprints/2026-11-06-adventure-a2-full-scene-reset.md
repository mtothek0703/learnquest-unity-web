# Adventure A2 — complete scene retry reset (2026-11-06, 17:18 CET)

## Basis and scope
Primary GitHub link: mtothek0703 / michael_kohler1@yahoo.de. Repository: mtothek0703/learnquest-unity-web. Current main: `0e01246620d33a9afcbb617152748adac4402993`. All four mandatory policy/roadmap documents read from main. Existing adventure branch `feature/adventure-a1-walk-arena-20261105-2111` is 51 commits ahead, 0 behind main before this change; this is an integration fix on the existing arena PR rather than a new isolated branch.

## Gameplay change
`adventure_area_controller.gd` now exposes `reset_adventure()`. A retry clears the mission's three crystals and two switches, restores the collectible nodes' visibility and monitoring, clears activated switch flags, resets the exit portal's one-shot state and respawns the walker. Previously `mission.reset_mission()` alone did not restore the physical nodes, leaving a reused scene unwinnable.

## Acceptance criteria
- Reused arena starts with three collectible crystals, two usable switches and locked exit.
- A completed mission can be reset and completed again; no phantom completed objectives.
- No runner gestures, XP, English quiz, bosses, archive or release files are modified.

## Verification
- Source-level check: confirmed `reset_crystal()`, `reset_switch()`, `reset_portal()`, `respawn_at_checkpoint()` APIs exist on the branch.
- New automated scene test: `godot/adventure/adventure_full_reset_test.gd`; invocation `godot --headless --path godot --script res://adventure/adventure_full_reset_test.gd`.
- **Not executed:** Godot 4.4.1 runtime unavailable in this connector session. No claim of passing headless tests, WebGL export, rendered screenshots, Safari touch QA or release.
- Branch remains DRAFT; no main merge or immutable Skyway deployment.

## Commits
- `74ee531822354ed032b3c01e1c18c2eda337199c` — reset API
- `333deae009beeb3e987b321a634c6633c4af5627` — regression test

## Next
Execute Godot import and reset test in CI, repair any parser/runtime issues, then test full hoverboard -> arena -> objectives -> exit -> hoverboard transition before enabling feature flag.
