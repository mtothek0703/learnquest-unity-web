# LearnQuest Sprint – 2026-11-04 10:11 CET – two-track visual QA

## Required policy
Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md and LEARNQUEST_RELEASE_POLICY.md from main. Work limited to the experimental branch; no stable release or archive writes.

## Track A – stable
No new tested gameplay or visual feature produced on main during this run; do not mint a version or claim deployment. Previous documented stable Skyway V154 remains reference, not reverified in this run. Godot import, regression, web export, Pages HTTP and archive checks not executed here.

## Track B – PR #111 (DRAFT)
Commit 910885b9d038b0c8b0e1b65a4daf13968f65237e enhances tools/character-frame-compare.html. The offline A/B tool now displays intrinsic image dimensions, refuses a visually valid comparison when the images differ in width or height, warns when the chosen 16:9 / 19.5:9 aspect ratio disagrees with image dimensions, and resets metadata when a file is replaced. This prevents mismatched render captures from being mistaken for character progress. No asset, Godot runtime, touch controls or gameplay changed.

## Checks and limits
Static source checks: dimension mismatch warning present; aspect warning present; image load naturalWidth/naturalHeight handlers present; stale metadata reset present (4/4 source-presence checks). No browser interaction, rendered images, Godot tests, real iPhone FPS or visual approval were performed. These source checks do not establish browser correctness or a better character. PR #111 remains DRAFT / VISUAL HOLD; no merge, no reserved version, no release.

## Next
Run browser QA using equal-size and deliberately mismatched image pairs; capture identical-camera 16:9 and 19.5:9 front/chase/action frames; inspect actual clipping and board silhouette. Independently implement and test a meaningful stable gameplay/3D improvement on main before any immutable release.
