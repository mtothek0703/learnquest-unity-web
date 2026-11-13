# LearnQuest Adventure – 2026-11-10 07:19 CET – Robot warning composition

## Verified starting point
- GitHub Primary: mtothek0703 / michael_kohler1@yahoo.de; repository mtothek0703/learnquest-unity-web.
- Main at 46e899a84c500243274badf71255bb2afec3186b, Adventure PR #157 remains DRAFT (233 ahead, 3 behind at start).
- Read on main: LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md.
- Previous Adventure head cc361934: full Godot PR validation #42761105624 SUCCESS. Blender PR #160 head dc5be9f: full Godot PR validation #42734105793 SUCCESS.

## Playable visual change
The existing robot telegraph filled a 3m-radius ground disk and obscured a substantial part of the playable foreground in genuine Godot captures. In the existing Adventure PR #157, replace the filled CylinderMesh with a thin TorusMesh boundary ring (2.82m inner radius, 3.0m outer radius). The ring still indicates the actual ROBOT_RANGE=3m; all combat logic, damage timing, runner, quizzes, rewards and legacy builds are unchanged.

## Acceptance / checks
- Existing robot warning becomes a readable boundary rather than a filled overlay; character and objectives should remain visible.
- The warning outer radius equals the actual strike radius, with an inner radius no more than 0.30m inside it.
- Added checks to res://adventure/adventure_bridge_test.gd for TorusMesh and geometry.
- Source change: 2e7b6480434ebd78a650243f715e8a2944f3848b; regression test: 26f75f2d62cc250fb2efd18dc056f72a798ad737.
- **Executed this run:** GitHub source review, policy reads, PR and branch comparison, previous-head CI inspection. **Not yet executed on new head:** Godot import, headless test, WebGL export, actual before/after renders, iPhone Safari and FPS.
- Release gate: stay DRAFT until complete new-head CI and both actual landscape renders are inspected; no merge or Skyway release.
- Blender PR #160 remains separate, not live; its portal still needs confirmed visual and iPhone QA.
- Next: inspect fresh CI, then actual 1280x720 / 1170x540 gameplay captures to confirm that the robot ring no longer obscures the hero and remains clearly legible.
