# V155 test preview deployment gate — 2026-11-10 16:13 CET

## Scope / identity
Primary GitHub account mtothek0703 (michael_kohler1@yahoo.de), repository mtothek0703/learnquest-unity-web, isolated branch preview/v155-playtest-20261110. main verified at 46e899a84c500243274badf71255bb2afec3186b. Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md from main before changes.

## Actual results
GitHub Actions run https://github.com/mtothek0703/learnquest-unity-web/actions/runs/42837617302 at preview commit 2dbaff9: **failure**, not a deployed release. Godot import, five gameplay/asset tests, Web export, V154/historical archive preservation, and separate 10.8 MB V155 playable-web-only artifact succeeded. GitHub Pages complete-site artifact was **1,569,925,595 bytes (1.46 GB)**, exceeding the reported 1 GB deployment limit; deployment step failed after timeout. Final HTTP verification was skipped. No evidence of a live skyway-v155-test/ URL. The prior environment-gated run 42837341833 did not deploy either.

## Acceptance / unresolved
- [x] Preview gameplay and GLB automated gates, Web export, archival preservation steps passed in run 42837617302.
- [x] Isolated web-only artifact generated; not a hosted playable page.
- [ ] Publish without removing, overwriting, or changing any historical Skyway/Unity files; full Pages artifact exceeds deployment limit.
- [ ] Verify five HTTP 200 files, exact build SHA, V154 byte preservation, real 16:9/19.5:9 visuals and iPhone-Safari performance.

## Next safe engineering path
Investigate a separate **isolated preview host** (e.g. a new Cloudflare Pages preview deployment under the user's Primary account), using only the web-only export and no modification to existing stable GitHub Pages or Cloudflare production sites. Confirm destination account/project ID and secure deployment authentication before changes. Do not rerun the unchanged 1.46 GB Pages deployment; do not remove historical builds to force the artifact below 1 GB. A GitHub Pages V155 URL cannot be claimed until verified.

## Blender and adventure status
Adventure PR #157 and Blender portal PR #160 remain distinct DRAFT quality tracks. The isolated V155 candidate combines them for playtesting only; no stable merge, no iPhone QA, no live release.
