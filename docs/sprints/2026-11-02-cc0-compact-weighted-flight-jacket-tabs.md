# CC0 65-bone compact weighted flight-jacket tabs — 2026-11-02

## Intent and separation
Continue DRAFT PR #111 without merging it or blocking the independent stable Skyway V153 channel. Read both required `main` policies before editing and verified the Primary `mtothek0703` account / `mtothek0703/learnquest-unity-web` repository. All modifications are limited to the experimental branch.

## Genuine 3D geometry change
- Shortened the two existing, closed, **four-weight, 65-bone-Skin-bound** flight-mantle meshes from 39% to **31% of the imported CC0 body height**. Their lower edges now end near the hips rather than over the thighs, revealing more of the skinned legs in the chase camera.
- The change is in the real `_mantle_point` 3D geometry and measured `mantle_span`, **not a material tint or 2D overlay**. Existing smooth normals, wind, landing recoil, steer/jump/boost vertex animation, skin binds, board and collision system remain.
- Updated the mantle and integrated shoulder/pauldron geometry regression thresholds to the new proportion; no modifications to main, touch, English rounds, four worlds, bosses, power-ups, historical Skyway builds or Unity archive.

## Verified runs
- Initial code commit: `eafb5a4d539e696751f71b75fe4038bfddae6af3`. [CI #41429095515](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41429095515) **FAILED** at the *integrated pauldron* regression, which still expected the former 38–40% mantle length. The dedicated mantle geometry test itself passed. This was a test expectation mismatch, not a successful build.
- Fix: `86b78ab3e8a71b0d8b5d7520c3868948f7e93bd9` updates that integrated test. [Final code CI #41429407739](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41429407739) **SUCCESS, 52/52 job steps**, including Godot headless regressions, Web export, 132 genuine landscape comparison images and unchanged gameplay checks.
- Previous image baseline: [CI #41428122014](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41428122014), artifact `learnquest-v124-quaternius-before-after` (132 PNGs).
- New: [CI #41429407739](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41429407739), artifact `learnquest-v124-quaternius-before-after` (132 PNGs).
- Paired RGB comparison, identical 1280×720 `after` chase-detail frames, max-channel absolute difference >12/255: **10,591/921,600 = 1.1492%**; front-detail **369/921,600 = 0.0400%**. At 1170×540: chase-detail **6,132/631,800 = 0.9706%**, front-detail **225/631,800 = 0.0356%**.
- Manual paired image inspection: both rear coat fins are clearly shorter and expose more thigh/hip space. The upper fins, wide violet neck band, bulky shoulder sleeves and toy-like face still dominate. Improvement is localized, not a high-end character acceptance.

## Release / QA gate
**PR #111 remains DRAFT / VISUAL HOLD. No merge and no new stable release** for this experiment. Real iPhone Safari FPS, full touch play and clipping QA remain outstanding.

## Next steps
1. Design a cohesive shoulder/collar/face silhouette rather than more tiny offsets; compare front and chase with identical pose/camera in 16:9 and 19.5:9.
2. Preserve the compact, actually weighted mantle and its action-driven deformation while testing whether the remaining broad shoulder fins can be integrated into the fitted sleeves.
3. Keep independent stable gameplay/world improvements eligible for their own future immutable Skyway release once they pass all release gates.
