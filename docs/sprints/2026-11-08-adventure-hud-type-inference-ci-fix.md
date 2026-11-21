# LearnQuest 3D – Adventure HUD CI parser fix (2026-11-08, 19:11 CET)

## Account / scope
Primary GitHub mtothek0703 (michael_kohler1@yahoo.de); repository mtothek0703/learnquest-unity-web; existing DRAFT PR #157 branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`. PR head before change `0fd6f2389644f4145a12ffd0030de2bf8ecdb4d4`; PR base main SHA `b9010294fea1728212bea50d413c465d55706dd2`. The main ref lookup independently returned `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; therefore main changed/was inconsistent across connector views and no rebase or merge was attempted.

## Mandatory reading
Read `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, and `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md` from main before modifying the existing PR.

## Actual failure
GitHub Actions Godot PR validation run [42504148869](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/42504148869), job `godot-test` (128803056036), **failed** while loading `res://adventure/adventure_bridge_test.gd`. Godot 4.4.1 reported `Cannot infer the type` for the four local variables `top`, `bottom`, `left`, `right` at lines 99–102 of the compact-landscape touch-zone test. The script did not run; artifact upload warnings are downstream and not proof of other gameplay failures.

## Change
Explicitly typed these four local HUD rectangle coordinates as `float` in the existing bridge regression test. No production gameplay, runner, historic Skyway or Unity files modified. Code commit: `9265440a3e0ea825d7ccf442e61b8ca133519d3c`.

## Acceptance criteria and evidence
- Godot 4.4.1 must parse the bridge test without the four type-inference errors.
- The actual HUD rectangle overlap and 390px bounds assertions must execute and pass.
- Existing quiz, race, 3-crystal/2-switch/robot/portal transition, reward and touch regressions must pass.
- Godot import, headless tests, WebGL export, real 16:9 and 19.5:9 renders, iPhone-Safari QA and archive checks must be independently verified before release.

**Actually executed:** GitHub PR metadata and current main lookup, mandatory document reads, failed Actions job/log inspection, file content inspection, and GitHub commit of four explicit type declarations. **Not executed/confirmed:** a successful new Godot CI run, local Godot, real render, export, iPhone test or Pages deployment. PR #157 remains DRAFT; no merge or release.

## Next
Read the new Actions log for the updated PR head. If the test now runs, fix any actual HUD overlap detected; then render both landscape ratios and integrate the existing licensed rider visual via an isolated adapter without touching runner controls.
