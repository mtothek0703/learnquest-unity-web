# 2026-11-02 — CC0 65-bone bilateral rear-oblique landscape QA (DRAFT)

## Preflight and two-track release policy
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before editing.
- Verified the **Primary** GitHub account `mtothek0703` (`michael_kohler1@yahoo.de`) and exact repository `mtothek0703/learnquest-unity-web`. Never use the Grees account.
- Stable `main` revision `72651ea1a046e25f885172c14dccc5d39ef32ba0`, Skyway V154. Godot, health, archive and Pages runs `41520977332`, `41520977439`, `41520977456`, `41520977525` completed successfully. No V155 candidate was independently ready in this run.
- PR #111 is still **DRAFT / VISUAL HOLD**. Its historical V124 working name reserves no release number; it must update against the then-current main before any eventual merge.

## Implemented on the DRAFT branch
- `e2ca7b5d`: expanded the reproducible **real Godot OpenGL** bilateral pose capture from four to **six camera directions**. In addition to front, chase and both side profiles, capture left and right **rear three-quarter** perspectives (camera positions ±3.75, 2.25, 4.15). These reveal jacket/shoulder/upper-arm/board depth intersections concealed by front or exact profile views.
- Both phone landscape viewports, 1280×720 and 1170×540, retain neutral, left-carve and right-carve poses: **36 PNGs**, compared with 24 previously. Original 65-bone pose-history reset, shader-time freeze and identical-neutral noise controls are retained.
- `866daa29`: updated the GitHub PR CI capture step and strict expected PNG count to 36, preventing incomplete captures from passing.
- No runtime geometry, original CC0 asset, 65-bone skin, touch input, three English questions, worlds, bosses, power-ups, collisions, old Skyway builds or Unity archive were modified.

## Test and visual acceptance
- Final code/CI configuration commit: `866daa29841dea2d97cf07d9e6b0f2e0a2f88a6c`.
- [GitHub Actions PR validation](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41526781490) started; result **pending at documentation time**. Do not claim the new 36-image capture passed until this specific run completes successfully.
- This is **better visual QA coverage, not a claim of better graphics**. The source model's oversized torso, shoulders and costume silhouette remain a known visual blocker. Real iPhone Safari FPS, all-pose clothing clipping and one complete touch-driven round after three English tasks remain unverified.

## Next step
1. Inspect the new rear three-quarter renders alongside the old 24-frame baseline, identifying which original-skinned garment/mesh creates the widest silhouette. Require a clear improvement in the complete chase/oblique rider, not just isolated pixel differences.
2. Develop and test a coordinated jacket/shoulder/upper-arm redesign on this DRAFT branch. Keep the visual hold until it is convincingly better.
3. Independently continue stable gameplay/world/landscape improvements on main, but publish the next free immutable Skyway URL only for a tested real improvement with Godot, export, archive, Pages and build-revision evidence.
