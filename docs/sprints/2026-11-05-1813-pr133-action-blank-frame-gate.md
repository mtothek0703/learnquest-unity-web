# 2026-11-05 18:13 CET — PR #133 action-frame blank-render gate

## Scope / account
Primary GitHub account mtothek0703 (michael_kohler1@yahoo.de), repository mtothek0703/learnquest-unity-web; camera candidate branch sprint-v145-landscape-chase-framing-20261101. Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md and LEARNQUEST_RELEASE_POLICY.md on main before writing. Main baseline 6077903f66d440243353058de2f32a182ec12a53. PR #133 was 37 ahead / 33 behind main before this change; PR #111 remains separate DRAFT.

## Defect / change
The 12 before/after race frames rejected blank or nearly uniform images, but the six turbo/jump-apex/landing synthetic action frames only checked image dimensions and PNG save status. Extended the same 16x9 coarse luminance range guard (minimum 0.025) to each action capture. This is a **test-only** improvement: no game art, mechanics, camera, UI, touch or archive changes.

## Acceptance / evidence
- [x] File read from the actual PR #133 branch, content updated using original blob SHA; code commit 317af062575bd30e52951356cab4e7b3a40e03cc.
- [x] All three release/sprint policies read from main; correct linked account verified.
- [ ] Godot parser, import, OpenGL visual capture and actual 18 PNG outputs **not executed/verified** in this run.
- [ ] CI: connector query for the new commit and main returned no PR-triggered workflow runs; this does **not** establish absence of push runs.
- [ ] Export, archival preservation, Pages HTTP checks and phone FPS **not verified** this run.
- [ ] PR #133 still needs rebase/sync with current main, full actual render review and release gates before merge.

## Release decision / next
No new Skyway release: no finished gameplay/visual enhancement and no successful CI evidence. Keep PR #111 in DRAFT visual hold, with no reserved release number. Next: execute actual OpenGL capture and all Godot tests, review PNGs and camera clipping, then integrate only if stable and archived versions remain intact. Do not confuse synthetic action positions with animated gameplay or physical iPhone testing.
