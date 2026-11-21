# LearnQuest Adventure A3 – Robot danger-zone telegraph (2026-11-09 04:14 CET)

## Scope and acceptance
In the existing DRAFT PR #157, display a transparent red floor warning zone for the robot's 3m attack radius during the 1.2s telegraph. Hide it outside warning and after robot defeat. Keep the damage calculation, race mode, existing quiz, mission targets, historical builds, and experimental character PR #111 unchanged.

## Verified prerequisites
Primary GitHub link: mtothek0703 / michael_kohler1@yahoo.de. Repository: mtothek0703/learnquest-unity-web; default branch main at 46bfea3ecbfa4db8cc755df8d7fab201706d8059; PR #157 head before edits 455eb889b5ce4cd4d56f080cf173ebed05419b0a, DRAFT, base metadata b9010294fea1728212bea50d413c465d55706dd2. Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, and docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md from main. Prior head CI #42549775390 reported success.

## Changes
- Added RobotWarningZone MeshInstance3D under the robot, translucent and without collision; its visibility follows the existing attack warning.
- Extended res://adventure/adventure_bridge_test.gd to assert initially hidden, visible during warning, hidden afterward.
- Gameplay commit 208e13f34c000b0a5adb40e8d192f2ad3aea9ff2; test commit 4f368930bff57c0fddf281b9e13fcf81b5307ad2.

## Tests and result
Static code review and GitHub file reads performed. **No Godot import, headless test, web export, real 16:9/19.5:9 render, iPhone test, or new-head CI success verified in this run.** CI must confirm before treating the warning as working. Do not merge or publish. Next: inspect new PR CI, correct failures, verify real mobile warning readability and the licensed walking character separately.
