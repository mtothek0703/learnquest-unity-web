# LearnQuest Adventure Sprint — 2026-11-08 15:14 CET

## Scope and verified baseline
Primary GitHub identity `mtothek0703` (Primary account), repository `mtothek0703/learnquest-unity-web`, existing DRAFT PR #157 and branch `feature/adventure-a1-walkable-neon-testbed-20261106-19` checked before writing. Read `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, and `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md` from `main`. Main commit `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; prior PR head `74e156a1e1b91a435160ec2dab11842badcaf6ab`, 124 ahead and 2 behind main.

## Concrete failure and change
PR workflow [42484116022](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/42484116022) **failed** in the headless Adventure bridge test: `walking mission needs a visible mobile objective hint`. The test still required the obsolete text `Kristalle sammeln`, whereas the current HUD intentionally shows `INTERAKTION: Kristall in N m` for the nearest mission object. Changed the test to check the actual on-screen objective hint `INTERAKTION: Kristall` instead of the outdated phrase. This is a regression-test expectation repair, not a new gameplay feature. Code commit: `422ca0de2dc6df3bb8d096e8110f0bf932cce72c`.

## Acceptance and actual validation
- Source inspection confirmed `_update_objective_guidance()` selects a visible nearest crystal and renders `INTERAKTION: Kristall` plus distance when outside interaction radius.
- The failing CI log was read; its Godot 4.4.1 headless test reached the outdated assertion and exited 1.
- **Not yet verified:** successful CI on this new head, subsequent assertions, Godot Web export, 16:9/19.5:9 actual render, manual iPhone Safari QA.
- Do not merge PR #157 or release Skyway until the required gates pass. Existing Runner, four worlds, three questions, old Skyway builds and Unity archive untouched by this test-only change.

## Next
Review fresh PR CI and repair any next genuine failure. Then improve playable walking visuals using a safe isolated adapter for the existing licensed Rider, with independent visual QA; keep PR #111 experimental and separate.
