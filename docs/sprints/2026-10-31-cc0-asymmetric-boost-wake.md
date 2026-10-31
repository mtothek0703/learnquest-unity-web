# LearnQuest 3D — DRAFT 65-bone board wake / 31 October 2026

## Source and separation
- Mandatory `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` read from **main** before work.
- Verified repository: `mtothek0703/learnquest-unity-web`, Primary GitHub account (`mtothek0703`); never Grees Klimatechnik.
- Stable channel independently advanced to **Skyway V135** (main `1f64f2f30ace6b1512fa081a960425fe7cb91e42`), with successful main Godot, archive and Pages runs `41229294620`, `41229294659`, `41229294674`. Pages log checks HTTP 200 for build.txt, HTML, JS, WASM and PCK and exact main revision. This draft does not modify main, existing releases, or Unity.
- Experimental PR #111 remains **DRAFT / VISUAL HOLD**; its V124 history does not reserve a release number. Do not merge before whole-character visual acceptance and rebasing against the then-current main.

## Implemented in the experimental branch
- The two **existing volumetric 3D boost wake meshes** now visibly change their actual geometry transform during steering: the *outside* exhaust trail stretches by up to 30% and widens by up to 20% horizontally / 12% vertically, while the inside trail retains its shorter profile. Reverse steering swaps sides.
- The start ring remains attached to the existing nozzle plane (local z=1.58), by compensating the z-scale with z-translation. This avoids an obvious gap or drifting wake origin.
- Changes use only two existing mesh draw calls, no per-frame mesh generation, no new materials, no collisions, no physics, no new assets and no changes to touch, three-English-question gating, bosses, worlds or power-ups.
- Regression `hoverboard_boost_wake_test.gd` now checks outside vs inside **actual 3D scale**, nozzle anchoring, left/right reversal and equivalent 30/60-FPS trail length in addition to prior geometry and fade checks.

## Release gate
- [x] **Technical CI completed:** [Godot run 41230570598](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41230570598) on code/test commit `0ffb467ecc0e7ed6adc1a10abe1c0e3d72d3c169` passed **52/52 job steps**: headless gameplay, 65-bone/skinning regressions, extended asymmetric-wake assertions, web export and the real landscape capture jobs. The [eight original boost-wake frames](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41230570598/artifacts/13053936020) were produced. They have **not** been independently inspected as a controlled visual before/after of the new steering-dependent length; no visual quality approval is claimed.
- [ ] **Not a stable release:** PR #111 remains DRAFT / VISUAL HOLD. Do not merge without holistic character/board render review and manual phone QA. CI success does not prove high-end art quality.
- Remaining visual gate: cohesive 65-bone rider proportions, jacket/arm/hair clipping and board silhouette in real chase/portrait images. Manual iPhone Safari FPS, touch and full three-question-to-race round remain unverified.
- Pages package above 1 GB remains an infrastructure risk; do not duplicate or overwrite immutable builds.
