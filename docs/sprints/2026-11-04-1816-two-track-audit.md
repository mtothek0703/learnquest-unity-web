# LearnQuest two-track sprint audit — 2026-11-04 18:16 CET

## Scope and policy
Read `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md` (filename contains a space after NEUE), and `LEARNQUEST_RELEASE_POLICY.md` from `main` through the Primary GitHub connection. The separate experimental 65-bone PR #111 remains subject to the visual hold and owns no release number.

## Verified repository observations
- Latest main commit returned by repository commit search: `6077903f66d440243353058de2f32a182ec12a53` (documentation audit).
- Latest gameplay commit in the returned history: `72651ea1a046e25f885172c14dccc5d39ef32ba0` (V154 animated glacial streams).
- Open PR #133: tighter landscape chase camera candidate, still a candidate, not evidence of passed QA or a deploy.
- Open PR #111: experimental CC0 65-bone rider, explicitly DRAFT / VISUAL HOLD / version TBD.

## Actual work and limitations
Read the policy files and inspected recent main commits and open PR search results. No game-code changes were made in this audit. No Godot import, headless gameplay tests, export, archive diff, Pages HTTP check, real rendered A/B comparison, or phone FPS test was executed. Therefore **no new release or character acceptance is claimed**.

## Next safe actions
1. Inspect PR #133's branch, current-head CI and genuine 16:9/19.5:9 comparison frames; only then consider a conflict-free gameplay/camera integration into main.
2. Independently produce and inspect real locked-pose 65-bone rider/board render pairs on PR #111; improve actual character geometry rather than adding more comparison-tool controls.
3. For any stable gameplay release: import + Godot regressions + Web export + archive guard + immutable next-free Skyway URL + Pages exact-SHA/HTTP 200 verification. Preserve historical Skyway directories and Unity archive.
