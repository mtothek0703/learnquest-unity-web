# LearnQuest Adventure – 2026-11-09 13:11 CET – Crystal animation simulation clock

## Scope and acceptance
Continue existing DRAFT PR #157 only; preserve runner, archive, mandatory three questions, four worlds and original touch input. Correct the Neon City crystal floating animation to advance by the simulation delta instead of global wall-clock time. A paused/backgrounded arena must not jump its float phase, and mission retry must restart the phase at zero. Rotation and visibility behavior remain unchanged.

## Verified baseline
Primary GitHub link: mtothek0703 / michael_kohler1@yahoo.de; repository mtothek0703/learnquest-unity-web. Main SHA `46bfea3ecbfa4db8cc755df8d7fab201706d8059`. Before editing, read on main: LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md. Existing PR #157 head `5db814dcbbf110712f3a813e6de54e06f5ca0389`, 177 ahead/2 behind main, still DRAFT. Godot PR validation run 42607376211 completed success for that **previous** head.

## Changes
- `godot/adventure/neon_walk_testbed.gd`: increment `crystal_float_phase` with physics delta only when the arena is active; derive crystal bob from this phase; reset phase on retry.
- `godot/adventure/adventure_bridge_test.gd`: check exact phase increment for a manual 0.1-second tick, no float change at delta zero, and phase reset after retry. Use a relative phase check because initial startup frames may have advanced the clock.
- Gameplay commit `37bb6c9d8e088533990a48fbdbd6c13090a96463`; test commits `1050acbc5092614892cfb8fc9810a61809de7c66`, `0684cfd1475c87c54672f0b05d5e7374e822f706`.

## Actual tests and result
Static source and GitHub baseline reviewed. Prior-head Godot PR CI success is **not** validation of these new commits. No local Godot import, headless test, Web export, real 16:9/19.5:9 render, iPhone Safari QA or Pages deployment performed in this sprint. New CI must be checked before treating this change as tested. No merge or release authorized.

## Next
Check new-head CI; repair failures on the same PR. Then prioritize real landscape render QA and end-to-end touch gameplay before any immutable Skyway release. Keep experimental PR #111 and camera drafts separate.
