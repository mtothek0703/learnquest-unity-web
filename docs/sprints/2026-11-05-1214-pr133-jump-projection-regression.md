# 2026-11-05 12:14 CET — PR #133 jump trajectory camera regression

## Scope and acceptance
Track A only, camera candidate branch `sprint-v145-landscape-chase-framing-20261101`. Policies `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md` were read from main. Account Primary `mtothek0703` and repository ID 1427565370 were verified before writing.

Added synthetic vertical rider positions (0.45, 1.25, 0.65, 0.0 world units) for rise/apex/descent/landing to `godot/chase_camera_framing_test.gd`. For each of three lanes and two landscape sizes, the test projects rider head and approximate two board endpoints and rejects clipping/behind-camera points. This extends the previous static/Turbo projection assertions without changing gameplay, touch, quizzes, worlds, or historical builds.

## Evidence and limitations
Code commit: `a331f28567fdccf6791e6bcaa6a3f9ac1b43e136`. At audit, branch was 33 commits behind main `6077903f66d440243353058de2f32a182ec12a53`. No Godot execution, rendered jump frames, Web export, Pages verification, archive check, or device FPS test was completed in this run. Synthetic positions are **not** actual jump animation and board endpoints are approximate. CI must run before claiming this test passes.

## Release gates
PR #133 stays DRAFT until synced with main, Godot and visual QA pass, Web export and historical archive protection pass, and Pages verifies a new immutable Skyway URL. No release number is reserved. Track B PR #111 (65-bone CC0 rider) remains independent DRAFT/VISUAL HOLD and must not block separate stable features.
