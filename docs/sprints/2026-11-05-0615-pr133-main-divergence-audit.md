# LearnQuest 3D — 2026-11-05 06:15 CET — two-track preflight and divergence audit

## Required policy reads
Read `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, and `LEARNQUEST_RELEASE_POLICY.md` directly from `main` using Primary (`mtothek0703`, `michael_kohler1@yahoo.de`) in `mtothek0703/learnquest-unity-web`.

## Track A: PR #133
At this check, main resolves to `6077903f66d440243353058de2f32a182ec12a53`. Comparing main with PR #133's previously recorded head `7e589aa774afe733ace4ec56042482cd648f4d6a` returns **diverged: 22 commits ahead and 33 behind**. This is a substantive integration risk: do not treat old camera validation as a current-main release gate. The changed-file set includes camera world code, smoke test, framing/visual capture tests, and both PR and publish workflows. The commit-associated workflow lookup returns no pull-request runs for `7e589aa`; this endpoint does not cover push runs. It cannot establish CI failure or success.

Acceptance: re-evaluate the exact current PR head against current main; inspect code/workflow conflicts; run full Godot import, gameplay/regression, Web export, archive protection and real landscape image QA including jump, landing, Turbo, board tips and HUD. Only then consider merge. After merge, verify Pages and immutable next-free Skyway URL with build revision and HTTP 200 for five artifacts. **No release or version reservation from this audit.**

## Track B: PR #111
Comparison of main to the previously recorded `6ee7aec` character head returns **1079 commits ahead / 96 behind**. This is a warning that eventual synchronization needs careful conflict and archive review, not an instruction to merge or force-rebase now. Keep the 65-bone CC0 rider DRAFT / visual hold until actual 16:9 and 19.5:9 comparison frames, clipping review, iPhone FPS and complete three-English-question touch round are accepted. Its historical V124 label reserves no version.

## Scope and verified outcome
Repository and policies read; compare API and commit-workflow lookup executed. No Godot process, export, Pages deployment, device test or gameplay modification executed in this run; no success claimed. Historical Skyway builds and Unity archive untouched. Next safe step is to reconcile the stable camera candidate with the 33 main commits and execute its current-head checks before releasing.
