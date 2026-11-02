# 2026-11-02 — CC0 65-bone landscape QA: pose-history reset and neutral-noise control

## Two-lane scope and safety
- Verified GitHub account: Primary `mtothek0703` / `michael_kohler1@yahoo.de`; target repository `mtothek0703/learnquest-unity-web`.
- Read both mandatory `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before writing.
- Stable lane A: main has advanced to `72651ea1a046e25f885172c14dccc5d39ef32ba0` for the **V154 glacial-stream gameplay/world visual candidate** (PR #143). Its main Godot validation `41520977332`, archive guard `41520977456` and healthcheck `41520977439` passed. Pages deployment `41520977525` was still running when this sprint started; **do not claim V154 is live without successful deployment and exact build.txt SHA verification**. V153 was the previous verified stable URL.
- Experimental lane B: only the existing `sprint-v124-quaternius-rigged-hero` branch for DRAFT PR #111 was modified. No merge, release, legacy Skyway rewrite or Unity archive change. PR title does not reserve V124.

## Concrete problem
Previous original Godot landscape comparisons sometimes counted unchanged-pose shader/inertia drift as altered pixels, despite very small true differences in the shoulder and chest silhouette. The previous 24-frame bilateral capture reset lean only; `elapsed`, `torso_follow`, jump/landing state, and the actual 65 imported bone rotations could carry history between frames. This made A/B visual measurements less trustworthy.

## Implemented change
Code commit `35840fd1d8923f0f6c60f293a16bf76be3518bb3` changes `godot/rider_external_bilateral_pose_visual_capture_test.gd`:
1. Before every neutral, left-carve and right-carve frame, restore all **original imported bone rotations** and zero the animation-history variables, then settle into the same neutral 65-bone surf stance.
2. At both 1280×720 and 1170×540, for each of front, chase, left-profile and right-profile cameras, render the **same neutral pose twice** and measure changed samples on a fixed 160×90 screen-space grid (14,400 samples). Fail if an unchanged control exceeds 180 samples.
3. Compare real left/right carve pixels against the measured same-pose control noise, not only a fixed 8-sample minimum. This prevents calling rendering drift a pose improvement.
4. Preserve all **24 original PNG filenames and image count**, real imported Skin, source meshes, gameplay, touch, collision and historical release paths. No new 3D graphics or visual acceptance is claimed by this test change.

## Validation and release gate
- CI run for code commit: https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41522581951
- **Pending when this document was authored**: confirm all Godot tests, actual 24 landscape renders, Web export and archive protection. A passing test is a reproducibility improvement, not evidence of a more attractive character.
- If neutral controls fail, diagnose animation/shader state or adjust capture to eliminate real nondeterminism; do not weaken the visual-quality gate simply to obtain green CI.
- Keep PR #111 **DRAFT / VISUAL HOLD** until coherent head/torso/shoulder/hoverboard art direction and true device QA pass. Real iPhone Safari FPS, all-pose clipping and a complete touch-controlled round after three English tasks remain unverified.

## Next
Use the now-controlled neutral/left/right images to measure the *actual* silhouette of the complete rider in both landscape aspect ratios. Prefer a coherent torso/shoulder/board redesign over another subpixel costume edit. Continue separate finished stable features on main without waiting for this experimental PR.
