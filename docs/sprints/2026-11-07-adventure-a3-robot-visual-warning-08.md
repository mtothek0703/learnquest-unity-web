# LearnQuest Adventure A3 – 3D robot attack warning (2026-11-07 08)

## Baseline and safety
- Authenticated Primary GitHub profile: mtothek0703 / michael_kohler1@yahoo.de.
- Repository: mtothek0703/learnquest-unity-web; existing DRAFT PR #157, branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`.
- Read on main before changes: LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md.
- Compare main...branch: diverged, 48 ahead / 1 behind; merge base b9010294; current main from compare 31178693. No new A1 branch.
- Prior head c8bc364: Godot PR validation run 42345979474 completed successfully.

## Concrete change
- Existing robot now uses a dedicated StandardMaterial3D, cyan when idle and red during its 1.2-second telegraphed strike. The material returns to cyan after strike resolution or mission reset; attacks that interrupt a warning also clear the red tint.
- Expanded res://adventure/adventure_bridge_test.gd to assert visible warning color and reset after strike. Runner, old releases, Unity archive, learning gate and touch_gestures.gd not modified.

## Acceptance criteria and evidence
- A warning in the real 3D scene is visible without reading the HUD: implemented, not yet visually approved.
- Material returns to idle after strike: covered by newly committed headless test; CI for new commits pending.
- Existing 3-question gate, collision, robot damage/guard, five mission interactions, exit gate and one-time XP: existing regression remains present; new head not yet validated.
- Actual executed checks this sprint: GitHub Primary profile and PR metadata, main document reads, main/branch comparison, previous-head workflow result; no local Godot import, render capture, Web export, iPhone test or new-head CI success claimed.

## Commits and release decision
- Gameplay commit: 37d3a0f71da5fbc99bfa84c91a0d9c3ab9d82ab0.
- Test commit: a7efb518ff7f98b85ea4df48af999b9db90089fb.
- PR #157 remains DRAFT. No merge, Pages deployment or Skyway version change.

## Next
Check new-head Godot CI, fix any failure, then capture actual 16:9 and 19.5:9 Godot frames and validate iPhone landscape controls before release consideration.
