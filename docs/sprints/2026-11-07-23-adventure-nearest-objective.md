# Adventure Sprint — 2026-11-07 23:14 CET

## Scope
Existing DRAFT PR #157 only. Account Primary (mtothek0703 / michael_kohler1@yahoo.de), repository and feature branch confirmed before edits. Four required policies/roadmap read from main. Comparison baseline main `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; before this sprint the PR was 91 commits ahead, 2 behind.

## Gameplay change
In `godot/adventure/neon_walk_testbed.gd`, INTERAKTION / desktop E now selects the closest *visible* crystal or switch within 2 m instead of the first created target. Prevents the player collecting an unintended farther object when mission interaction radii overlap. No runner input, XP or legacy build files changed.

## Acceptance criteria
- With two visible objectives in range, nearest objective is collected.
- A second, farther objective remains available.
- Mission retry restores both objectives.
- Existing three-question gate, runner/foot bridge, five objectives, robot and portal regressions remain passing.

## Test implementation and actual execution
Added nearest-target selection and retry assertions to `res://adventure/adventure_bridge_test.gd` (test commit `6217911f863f9d63c2032c7c25ebc50c461647ce`). Gameplay commit `e23e343f69652198fe7d84414a91c229cf8db6b6`.
Previous head `338a37f76c540afb4081501a2f9659c47e51303c` had GitHub Actions Godot PR validation success, run `42414729432`. **No local Godot import/headless execution, web export, screenshot, Safari device test or successful CI for the new head has been verified at documentation time.** Check new PR CI before any merge or release.

## Release decision
Keep PR #157 DRAFT. No merge, no immutable skyway-vN release, no claim of iPhone QA. Existing Skyway archives, Unity archive and runner untouched. Next: verify new CI, then work on existing licensed rider appearance in foot mode without importing experimental PR #111.
