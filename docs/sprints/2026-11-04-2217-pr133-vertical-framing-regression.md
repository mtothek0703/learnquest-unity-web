# 2026-11-04 22:17 CET — PR #133 projected rider/deck clipping regression (DRAFT; NO RELEASE)

## Required preflight
Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md and LEARNQUEST_RELEASE_POLICY.md directly from main. Verified repository mtothek0703/learnquest-unity-web (repo id 1427565370), Primary account mtothek0703 / michael_kohler1@yahoo.de. PR #133 is open DRAFT on sprint-v145-landscape-chase-framing-20261101. PR #111 is open DRAFT, VISUAL HOLD, no reserved release number.

## Track A — change
Extended godot/chase_camera_framing_test.gd: after positioning the actual rider and updating the camera, project rider head (3.5m) and deck origin (0m) into viewport space. Fail if head is above the image or deck is below it, for all three lanes at 1280x720 and 1170x540. Existing horizontal-safe-area, normal camera, Turbo pullback and menu assertions remain. This is a regression guard against vertical framing loss, not an actual hoverboard-tip or HUD overlap measurement.

Code commits: 58d62c5b9d07dd6bcc7272156e66741aa840b6a4; newline correction 8672e4d451b02b05a62ed302e335653ac8cdace2. Source re-fetched and confirmed the new GDScript lines have proper line breaks. The workflow-run lookup for the latter commit returned no PR runs at inspection time. Therefore this new assertion is NOT yet proven to pass Godot CI. Prior successful CI on 97b537f2 does not certify these new commits.

## Track B
PR #111 left untouched, DRAFT. Actual 65-bone character visual acceptance, clipping, real iPhone FPS and uninterrupted three-quiz touch round remain unproven.

## Gates / next actions
1. Run full current-head PR Godot import, gameplay regression, Web export and archive guard; if new vertical assertion fails, diagnose actual projected positions before adjusting camera.
2. Extend genuine visual capture to all three lanes and jump/Turbo/landing, then measure trailing board-tip padding and HUD overlap; confirm hazards remain readable.
3. Keep PR #133 DRAFT until visual and CI gates pass; do not merge or publish. No new Skyway directory, Pages deploy, archive or Unity modifications this run.
4. Continue actual rider/board improvement on PR #111 independently, with visual hold intact.

Outcome: test-code improvement only; no verified gameplay/3D rendering improvement, no new release.