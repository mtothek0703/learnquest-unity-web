# LearnQuest 3D – Neon boss warning chevrons (2026-11-01, stable-track candidate)

## Required checks and separation

- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before editing.
- Verified Primary GitHub account `mtothek0703` (`michael_kohler1@yahoo.de`) and exact repository `mtothek0703/learnquest-unity-web`.
- Stable channel: last independently reported live release Skyway V146; no new version number is reserved or claimed in this candidate.
- Experimental 65-bone hero PR #111 stays DRAFT, VISUAL HOLD. No changes to its branch, archives, Unity files or historical Skyway builds.

## Stable-channel improvement

The Neon City conductor's existing flat lane warning receives six **physically extruded directional chevrons** along the warned lane. Twelve closed 3D bars share one ArrayMesh and one emissive satin material; the warning stays attached to the existing beam, inheriting its position and visibility. The raised arrows cover over 24m of track depth while remaining inside the original lane width. This aims to improve boss telegraph legibility in 16:9 and 19.5:9 chase views without changing steering, hit timing, shield-counter windows, damage, or three pre-race English questions.

`neon_conductor_test.gd` now checks 432 actual mesh vertices, complete normals, raised geometry, long-distance coverage, lane bounds, no collisions and the existing boss gameplay regression.

## Acceptance gate

- [ ] Godot PR CI and headless gameplay/boss regression successful on final candidate head.
- [ ] Web export successful.
- [ ] Actual before/after smartphone landscape captures inspected; prove legibility, not just vertex count.
- [ ] Archive protection successful.
- [ ] Only if the improvement is convincingly visible and safe: choose the next unused Skyway number, update version and release workflow, rerun gates, merge and verify Pages build SHA and HTTP 200 for all five build files.
- [ ] Real iPhone Safari FPS, clipping and uninterrupted touch playthrough after three English questions remain manual gates; never claim these automatically passed.

**Current decision:** candidate only, not a release. Keep PR #111 independent and in DRAFT; do not manufacture a new version without proven player-facing value.

## Candidate QA – 2026-11-01, 19:24 CET

- [x] Full [Godot PR CI 41336117295](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41336117295) **completed/success**, 41/41 workflow steps including headless boss/gameplay tests, Godot Web export and real visual capture.
- [x] [Archive protection 41336117158](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41336117158) **completed/success**.
- [x] [Eight actual OpenGL landscape frames, artifact 13095880295](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41336117295/artifacts/13095880295) downloaded and inspected. Raised chevrons are clearly legible against the magenta hazard strip in chase and oblique views at 1280×720 and 1170×540; the pink lane alone has no directional markings. At RGB max-channel difference >25, changed pixels are **1,526 (0.166%)** 1280×720 chase, **1,971 (0.214%)** oblique, **785 (0.124%)** 1170×540 chase, **986 (0.156%)** oblique. This is a meaningful **hazard-readability** improvement, not a broad world/character graphics upgrade.
- [ ] Final release gates after version assignment, merge, main CI, Pages revision/HTTP and archive count still required; never claim V147 live before these pass.
