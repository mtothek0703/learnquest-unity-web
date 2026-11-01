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
