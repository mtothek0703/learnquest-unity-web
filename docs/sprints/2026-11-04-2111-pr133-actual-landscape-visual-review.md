# 2026-11-04 21:11 CET — PR #133 actual landscape artifact review (NO RELEASE)

## Baseline / policy
Read `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, and `LEARNQUEST_RELEASE_POLICY.md` from `main` this run. Authenticated account `mtothek0703`, repo `mtothek0703/learnquest-unity-web`. Main's latest indexed commit: `6077903f` (documentation), last gameplay commit `72651ea1` (V154). Track B PR #111 stays DRAFT / VISUAL HOLD; no version reservation.

## Actual evidence reviewed
Downloaded and extracted original GitHub Actions artifact `learnquest-v145-chase-camera-before-after` (artifact 13085851556, 2,513,215 bytes) from [Godot PR validation run 41312348330](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41312348330), current candidate SHA `97b537f2e29941e1e60366a6f7271d6b3c886b04`. Eight PNGs: before/after for lanes 0 and 1 at 1280x720 and 1170x540. The PR-head [archive guard 41312348337](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41312348337) also completed successfully.

## Visual inspection results (manual review of original PNG contact sheet)
- **Real change visible:** rider and hoverboard are larger in the chase frame in both tested aspect ratios. This is a genuine camera/composition difference, not just a version bump.
- **1170x540 lane 0:** the hoverboard's trailing tips and particles are near the bottom of the image; the visible geometry appears inside the frame in this static pose, but there is little safety margin for bounce/jump/Turbo and device overlays.
- **1280x720 lanes 0 and 1:** board is also fully visible in these captures, and side lane road edges are visible. The rider/board occupy a large portion of the center; approaching rings/obstacles can be partly occluded by the silhouette.
- **QA limitation:** these eight images show only two lanes and neutral captured states, not all three lanes or dynamic Turbo/jump/landing, HUD overlays, device-safe areas, or actual phone FPS. The current images cannot establish absence of clipping in motion or that obstacles remain readable at speed.
- **Decision:** KEEP PR #133 DRAFT; no merge/release based on these frames alone. The current frame set is valuable evidence but not the required full visual acceptance.

## Next concrete acceptance tasks
1. Capture all three lanes at 1170x540 and 1280x720, including Turbo pullback, jump apex, landing and near-miss obstacle approach; compare against current main using identical pose/time/camera.
2. Add or run a Godot framing regression that measures board-tip bottom padding at maximum bounce and HUD-safe-zone overlap in the shortest landscape viewport. Check that upcoming hazards remain readable behind the enlarged rider.
3. If bottom margin is inadequate, tune chase distance/focus in `godot/world.gd` and regenerate actual frames; avoid arbitrary cosmetic changes.
4. Re-run current-head Godot import/gameplay/regression, web export, archive protection and Pages deployment before any *new* immutable Skyway URL. Confirm build SHA and HTTP 200 for all five files. Do not modify old Skyway directories or Unity archive.
5. Track B: continue 65-bone hero/board silhouette work on PR #111 separately; require true rendered comparisons, clipping review, full three-question touch round and real iPhone FPS before merge.

## Changes / verification this run
Documentation-only QA report on PR #133 branch; no game code change, no new Godot execution, no new export or Pages deployment, no release. Evidence is existing successful PR-head CI plus newly inspected original artifact images.