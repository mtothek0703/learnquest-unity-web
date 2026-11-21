# LearnQuest Adventure sprint — 2026-11-07 17:16 CET

## Scope
Continue existing DRAFT PR #157, no parallel A1 branch or release. Primary GitHub identity mtothek0703 (michael_kohler1@yahoo.de), repository mtothek0703/learnquest-unity-web, branch feature/adventure-a1-walkable-neon-testbed-20261106-19 confirmed before write. Read on main: LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md. Main 46bfea3ecbfa4db8cc755df8d7fab201706d8059; comparison before change: 76 ahead, 2 behind. Prior PR head ca27ed42452667a8f563c6144dc92f81b722312a had successful PR Actions run 42385692784.

## Gameplay change
Mission retry now clears held walking touch directions, zeroes velocity, and respawns the CharacterBody3D at the arena-local checkpoint. Prevents retry from leaving the hero at a previously dangerous location or carrying momentum. Runner state, quiz, boss mechanics, archived builds and shared touch gestures untouched.

## Acceptance and tests
- Acceptance: after reset_mission from a displaced, moving hero, position equals arena-local checkpoint (transformed to world), velocity zero, mobile_axis zero; existing mission/robot counters still reset.
- Added a regression assertion in res://adventure/adventure_bridge_test.gd covering these conditions.
- Prior CI success is only for **old** head ca27ed4. **No new Godot import, headless gameplay execution, Web export, actual 16:9/19.5:9 render, Safari test, or Pages deployment verified for this change at documentation time.** New PR CI must be checked separately.

## Commits and release status
- Gameplay: 33cd8e997d0746db8878af1c1a905e437c7da68d
- Test: ed1fb2a6e5701241a93612097d3d87a934af8f17
- PR: https://github.com/mtothek0703/learnquest-unity-web/pull/157 (DRAFT)
- No merge, no release, no new skyway-vN/ path. Next: verify fresh CI; integrate licensed existing hero in walking mode and obtain real landscape renders before any release gate.
