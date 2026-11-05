# 2026-11-05 11:13 CET — PR #133: Blank-frame visual QA guard

## Scope
Track A only. Keep experimental PR #111 DRAFT, independent, and unversioned.

## Actual change
The landscape visual capture test now samples a 16×9 grid of pixel luminance and rejects uniform/blank output (range < 0.025) before saving each of its twelve before/after frames. This prevents a renderer producing empty yet correctly sized PNGs from being accepted as visual evidence. All three lanes and both landscape resolutions remain covered.

## Acceptance criteria
- Nonblank, correctly sized 1280×720 and 1170×540 frames in all lanes.
- Existing 15% projected rider-height and image-difference checks still pass.
- Godot import, gameplay, web export, immutable archive checks and Pages pass before any stable release.
- PR #111 requires separate real visual, clipping, FPS and touch-round approval.

## Verification status
- Source edit committed: 30c164b87ac61929aa327a7696373eaa49db6683.
- Static source check: inserted guard before save_png; existing twelve-image capture and thresholds retained.
- Godot/OpenGL run, image review, web export, archive protection and Pages: NOT executed or proven in this run.
- PR #133 remains DRAFT; branch compared against main 6077903f: 29 ahead / 33 behind at inspection.
- No merge, no new release, no new Skyway URL.

## Next
Run Godot/Xvfb visual capture and inspect artifacts; if CI passes, rebase camera candidate on current main and revalidate before any release. Continue separate character visual quality work without blocking independent stable features.
