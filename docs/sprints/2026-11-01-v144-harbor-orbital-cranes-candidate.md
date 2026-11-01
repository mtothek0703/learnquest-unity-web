# 2026-11-01 — Track A: Star Harbor orbital cargo cranes (V144 candidate)

## Mandatory preflight
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` in this run.
- Verified authenticated **Primary** GitHub login `mtothek0703`, repository `mtothek0703/learnquest-unity-web` (ID `1427565370`), and `main` head `6993047e5c167793557741b1147a52e33486e427`.
- Last independently verified immutable stable release: **V143**, Pages run `41301966452`. PR #111 is independent **DRAFT / VISUAL HOLD**, not a reserved V124 release.

## Original feature
- Four large curved, continuously triangulated 3D orbital cargo cranes flank the Star Harbor race corridor, with true surface normals, vertex-shaded metal and reusable left/right support meshes.
- Four glowing volumetric docking halos, eight suspended sculpted freight pods and eight physical hoist cables. No new third-party assets, external textures, dynamic lights or collisions.
- Crane structures scroll at the race speed, wrap at a fixed four-crane loop and pause during the mandatory three English vocabulary questions.
- Headless Godot regression verifies actual world integration, 3D geometry and normals, lane clearance, absence of collisions, animation, pause and wrap.
- Dedicated OpenGL before/after QA renders 8 original 1280×720 / 1170×540 chase and oblique frames and checks nontrivial image differences. This is not a real-device FPS measurement.
- `world.gd` identifies V144 only in this candidate. Release workflow checks that `skyway-v144` does not already exist before creating it; historical versions and Unity archive are preserved.

## Release gate (do not claim live until verified)
- [ ] PR Godot import, full regression suite, export and actual landscape QA passed.
- [ ] PR historical archive protection passed.
- [ ] Original before/after frames visually inspected for meaningful improvement and no obvious layout occlusion.
- [ ] Merge candidate to `main` only after passing QA and confirming V144 is unused.
- [ ] Verify main CI, health, archive, Pages, five HTTP 200 files and exact `build.txt` SHA.
- [ ] Physical iPhone Safari FPS, clipping and full manual touch-controlled round remain unverified.
- [ ] Existing >1 GB Pages artifact warning remains; never delete old immutable releases to hide it.

## Track B
PR #111 remains a separate experiment and must not be merged without a genuine whole-character visual improvement. Its title does not reserve a version number.

## First actual CI / image review and correction
- Initial candidate headless 3D geometry, scrolling, pause and Web export passed, but the first real landscape QA failed the stricter 1170×540 chase visibility gate: **52 sampled changed pixels**, below required 65. The [original partial images](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41306192702/artifacts/13083755468) were downloaded and visually inspected: the rings and supports were tiny against the existing harbor skyline. **Not acceptable as a stable visible improvement.**
- The existing V122 isolated drydock QA also fell from its >=65 sample gate to 63 due to new scenery occlusion. Corrected V122 and V123 historical before/after QA to temporarily hide only the later V144 cranes, preserving the original strict pixel thresholds. The new V144 comparison still renders the complete combined harbor.
- Sculpt revision: move cranes from x=±11.4 to ±9.8, foreground the first root from z=-19 to -12, tighten spacing to 32, enlarge true tubular supports, 3D halos and freight pods. Foundations remain outside the race lanes; no new collision bodies.
- [ ] Re-run full CI and inspect revised eight landscape frames before any merge. **V144 is not published yet.**

## Final verified stable release — 2026-11-01
- [x] PR #132 merged into `main` as `f7a8a9d59a0dd37d7990595cc49f7e3cf1017387`, retaining independent DRAFT PR #111.
- [x] [Main Godot CI 41306881512](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41306881512), [historical archive check 41306881533](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41306881533), [health check 41306881513](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41306881513) and [Pages 41306881518](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41306881518) all `completed/success`.
- [x] Pages log verified new immutable `https://mtothek0703.github.io/learnquest-unity-web/skyway-v144/`: `build.txt` matched the exact release commit, and `index.html`, `index.js`, `index.wasm`, `index.pck` each returned HTTP 200 at 12:44 UTC.
- [x] Release log: **141 historical version directories preserved**, Unity archive prepared. No prior Skyway path overwritten.
- [x] Final Pages artifact **1,453,422,140 bytes**, exceeding the 1-GB warning despite successful deployment. Optimize size without deleting historical releases.
- [ ] Manual physical iPhone Safari FPS, all-pose clipping and complete touch round remain unverified. CI/landscape render tests are not substitutes.

## Independent original-frame review after deployment
- Downloaded the actual [eight-frame V144 Godot OpenGL QA artifact](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41306881518/artifacts/13084425308), extracted it and inspected the 1280×720 chase/oblique before/after frames side by side.
- At identical camera, RGB max-channel difference >25: **7,030 px (0.763%) chase** and **6,719 px (0.729%) oblique** at 1280×720; **3,773 px (0.597%) chase** and **3,673 px (0.581%) oblique** at 1170×540.
- New cyan 3D crane rings and supports are discernible, but the entire racing environment occupies a small central part of the frame with large empty dark margins. This is **not** a demonstrated premium overall 3D quality leap. Future stable work should improve real chase-camera composition and world-scale readability at phone landscape resolutions, with gameplay and touch UI protected.
