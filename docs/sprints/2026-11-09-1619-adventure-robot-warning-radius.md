# LearnQuest Adventure A3 – Robot warning radius accuracy (09.11.2026, 16:19 CET)

## Baseline and account
Primary GitHub link: mtothek0703 / michael_kohler1@yahoo.de; repository mtothek0703/learnquest-unity-web; existing DRAFT PR #157, branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`. All four mandatory main documents were read before changes. Main at verification: `46e899a84c500243274badf71255bb2afec3186b`; PR head before change: `ddccbb051f0d87ef1e55e38e10560738e8042511`, three commits behind main. Prior PR workflow run #42633469128 concluded success.

## Gameplay correction
The robot's telegraph ring previously scaled between 0.92 and 1.08 of ROBOT_RANGE, visually showing a danger area up to 8% beyond the real hit range. The ring now pulses inward between 0.92 and 1.00 of the actual radius. Robot strike logic, cooldown, touch controls, runner, quizzes, rewards, four worlds and archived builds remain unchanged.

## Acceptance criteria
- While the warning is visible, its ring remains within the true strike radius and still pulses.
- When warning ends, ring is hidden and scale resets to Vector3.ONE.
- Existing robot dodge/guard/attack behavior and runner integration are unaffected.

## Changes and verification
- Gameplay commit: `41f1aa6322a69ce0125a3ca62f407c5ced0ef59e`.
- Regression commit: `f85dc440cff9af5e5cfb2eb8c00855a49fa9f375` extends `res://adventure/adventure_bridge_test.gd` with ring bounds assertion.
- Prior CI success applies **only to previous PR head**; no new Godot import/headless tests or web export executed in this run. New CI must be checked against final head. No visual 16:9/19.5:9 render evidence or iPhone-Safari QA.
- PR #157 remains DRAFT. No merge, no Pages deployment, no Skyway release. Next: validate updated PR CI and perform real render QA, then address any observed defects.
