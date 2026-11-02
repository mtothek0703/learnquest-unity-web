# CC0 65-bone jacket shoulder-slope continuation — 2026-11-02

## Scope
DRAFT PR #111 only. Stable `main` / Skyway V153 remain independent and unchanged.
Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` on `main` before editing. Primary GitHub account `mtothek0703` and repository `mtothek0703/learnquest-unity-web` verified.

## Actual change
- In `godot/rider_external_skinned_outfit.gd`, the true imported-four-weight jacket no longer adds a +0.006-unit vertical lift to the outer deltoid. Instead, its shoulder offset falls by up to 0.035 rest-space units from the central neckline to the outer shoulder, on top of the already-sloped original CC0 body.
- In `godot/rider_external_skinned_outfit_test.gd`, a bilateral geometry regression checks a descending outer jacket shoulder, mirrored left/right offset and an undisturbed central neck.
- The original 65-bone Skin, skeleton, body triangles, fitted sleeves, board, collisions, touch gestures, gameplay, old Skyway builds and Unity archive were not modified.

## Reproducible CI and landscape QA
- Code commit: `c5bea641836e9b88df18f61b41b0e2c50ca42f05`. The initial test file had an accidental doubled GDScript continuation backslash; corrected in `4320a5f4403bc451e65aa22c81d2ecbf0fdf11ca`.
- **Final code CI**: [Godot PR validation #41428122014](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41428122014) **SUCCESS**, 52/52 job steps, including headless regressions, Godot web export and genuine 16:9 / 19.5:9 renders.
- Previous comparison: [#41421444953](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41421444953), artifact `learnquest-v124-quaternius-before-after` (132 landscape PNGs).
- New comparison: [#41428122014](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41428122014), artifact `learnquest-v124-quaternius-before-after` (132 landscape PNGs).
- Pixel comparison of **identical `after` views**, 1280x720 RGB, max-channel absolute difference >12/255: front detail **263/921,600 = 0.0285%**; chase detail **3,086/921,600 = 0.3349%**. At 1170x540: front detail **201/631,800 = 0.0318%**, chase detail **2,057/631,800 = 0.3256%**.
- Manual inspection of paired images: the rear jacket contour moves slightly; the broad violet rear neck band and bright blue front collar remain. No convincing commercial-quality silhouette improvement yet.

## Acceptance decision
**VISUAL HOLD. Do not merge PR #111 or publish a new Skyway version for this subtle change.** A passing skinning test and a few thousand changed pixels do not establish a higher-quality overall rider. Real iPhone FPS, clipping and full touch-play QA remain open.

## Next coherent experiment
Address the dominant rear silhouette as a whole: compare the existing `after_no_mantle` isolation frame against the complete hero, then redesign the two genuinely skinned coat-tail profiles / shoulder transition together. Retain smooth action-driven cloth motion and original 65-bone weighting. Test front and chase in both landscape aspect ratios before deciding whether to keep it.
