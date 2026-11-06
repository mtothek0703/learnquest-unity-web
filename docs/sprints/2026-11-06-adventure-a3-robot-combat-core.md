# 2026-11-06 05:11 CET – Adventure A3 robot combat core (DRAFT)

## Baseline and account
Primary GitHub account: mtothek0703 / michael_kohler1@yahoo.de; repository mtothek0703/learnquest-unity-web; fresh branch feature/adventure-a3-robot-combat-core-20261106-0511 from main. Before writing, read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md on main. Main runner currently has TASKS_PER_ROUND=3, four worlds and its own boss logic; this change does not touch it.

## Actual implementation
New standalone RefCounted combat state with idle/warning/recovery/defeated transitions. Attack warning 1.1 seconds, guard blocks damage, range checks, three robot hit points, one defeat event, deterministic reset. No wall-clock timer: only explicit advance(delta) drives attacks, allowing the future AdventureDirector to pause combat. Large frame delta never chains multiple attacks. No new assets or costs.

## Acceptance criteria and test
- Outside range: no attack. Inside range: warning occurs before any hit.
- Guard blocks; unguarded hit counts once; exiting range avoids impact.
- Player attack requires proximity; robot defeat fires once and disables subsequent attacks.
- Retry resets all encounter state; no timer-driven attacks while paused.
- Proposed headless command: `godot --headless --path godot --script res://adventure/robot_combat_state_test.gd`.
- **Actually executed:** GitHub source writes only. Local executable probe `command -v godot || command -v godot4` found neither binary. No Godot import, test execution, Web export, screenshots, iPhone QA, Pages or archive test performed. No claims of pass.
- **Integration pending:** wire robot state into PR #146's arena after CI/import QA, add visible telegraph/attack/guard touch buttons, connect reward ledger PR #147, test full 3-quiz -> race -> walk -> fight -> return loop. Separate draft PRs remain unmerged.
- **Release:** none. Do not merge until checks and visual QA pass. Existing Skyway URLs and Unity archive untouched.

## Scope
Files only under godot/adventure/ and docs/sprints/. No changes to world.gd, touch_gestures.gd, existing boss code, assets, archives or version number.
