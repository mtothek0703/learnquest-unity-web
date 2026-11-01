# 01.11.2026 — Skyway V140 candidate: aerial energy mastery (stable track A)

## Starting point and release policy
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` on `main` before changes.
- Verified authenticated GitHub account `mtothek0703`, ID `339490599`, repository `mtothek0703/learnquest-unity-web`, ID `1427565370`; used only Primary connection, never Grees Klimatechnik.
- Base: `main` commit `2f90449c`, last verified immutable release Skyway V139; main Godot, Pages, historical archive and health checks successful.
- PR #111 remains DRAFT / visual hold; this independent feature does not merge the unapproved 65-bone character.

## Gameplay change
- Existing energy gates in all four worlds now show a raised cyan 3D aerial target, sharing one low-poly TorusMesh/material across all seven pickups. Visual only, no collision and no new mobile input.
- Jump through a regular energy gate (existing touch jump, rider height at least 0.90) for +20 bonus XP and at least 1s Turbo, in addition to the original +15 XP/+18 energy and Star Harbor crystal count.
- The first three airborne pickups per race count towards mastery; third gives +40 XP and at least 2s Turbo. Total additional mastery reward: **100 XP**. Ground pickups are unchanged; repeated pickups beyond the three-airborne cap cannot farm extra XP.
- The existing landscape HUD displays `LUFT 0/3`, and the result screen records completed mastery. Reset on training and every new race. Existing clean-flight streak, boss fights, four powers, three mandatory English questions and four worlds remain intact.

## Acceptance / release gate
- New `godot/aerial_energy_mastery_test.gd`: three correct vocabulary tasks, real landscape touch jump, 3D ring/no-collision assertions, ordinary pickup compatibility, three aerial rewards, capped fourth catch, result and next-round reset.
- PR Godot CI and release workflow both require the new regression; smoke HUD assertions updated to V140.
- Release workflow targets only new `skyway-v140/` and explicitly refuses overwrite; existing Pages archive-preservation process and Unity root remain unchanged.
- **Release gate completed** after PR Godot tests, Web export, archive protection, main CI and Pages verification. See evidence below.
- Open independent issues: 1.4 GB Pages artifact growth, manual iPhone Safari FPS/clip/touch round, and the visual-quality gate for PR #111.

## Confirmed release (01.11.2026)
- [PR #128](https://github.com/mtothek0703/learnquest-unity-web/pull/128) merged by squash as `3868b1df8b07610f235b4540e514c28caa79e640`.
- [PR Godot validation 41268812846](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41268812846) and [PR historical preservation 41268812839](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41268812839): SUCCESS.
- [Main Godot CI 41269000533](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41269000533), [main archive protection 41269000605](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41269000605), [health check 41269000535](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41269000535): SUCCESS.
- [Pages release 41269000563](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41269000563): SUCCESS, includes `AERIAL ENERGY MASTERY TEST PASSED`, three-English-question and touch regression, Godot import/export, preserved **137 historical version directories**, and exact immutable `skyway-v140/` creation without overwriting older URLs. `build.txt`, `index.html`, `index.js`, `index.wasm`, `index.pck` each verified **HTTP 200**; workflow compared build.txt with the exact release SHA.
- Playable immutable URL: https://mtothek0703.github.io/learnquest-unity-web/skyway-v140/
- Pages artifact warning remains: **1,411,497,699 bytes**, above 1 GB; deploy nevertheless succeeded. Needs separate preservation-safe size optimization.
- No real iPhone Safari FPS, manual clipping or complete physical-device touch round claimed. DRAFT PR #111 is unchanged by this stable merge and still requires visual approval.
