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
- The 36 PNGs are already available in [GitHub Actions artifact 13180118549](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41526781490/artifacts/13180118549); extracted and checked all 36 actual images (not a simulated preview). The new rear-oblique neutral and both carve angles show a protruding front chest, large side cape/upper-arm overlays and a visually bulky board/boot composition. This is a **visual quality blocker**, not a passed aesthetic gate.
- Quantitative signal at a maximum RGB channel delta >25/255: opposite-carve poses differ in **5.70% left / 5.84% right** of 1280×720 oblique pixels and **4.68% / 4.79%** at 1170×540. These are pose differences, **not proof of better art**. Compared with the previous 24-frame successful baseline, unchanged 1280×720 neutral views differ by only **0.0001% front, 0.025% chase, 0.022% left profile and 0.038% right profile**, showing low cross-run control drift.
- The CI step **“Capture 36 bilateral CC0 carve poses including rear oblique views”** completed successfully, as did Godot import/gameplay and the existing regression steps. The overall workflow may still be finalizing artifacts; report its final conclusion separately.
- This is **better visual QA coverage, not a claim of better graphics**. The source model's oversized torso, shoulders and costume silhouette remain a known visual blocker. Real iPhone Safari FPS, all-pose clothing clipping and one complete touch-driven round after three English tasks remain unverified.

## Next step
1. Inspect the new rear three-quarter renders alongside the old 24-frame baseline, identifying which original-skinned garment/mesh creates the widest silhouette. Require a clear improvement in the complete chase/oblique rider, not just isolated pixel differences.
2. Develop and test a coordinated jacket/shoulder/upper-arm redesign on this DRAFT branch. Keep the visual hold until it is convincingly better.
3. Independently continue stable gameplay/world/landscape improvements on main, but publish the next free immutable Skyway URL only for a tested real improvement with Godot, export, archive, Pages and build-revision evidence.
