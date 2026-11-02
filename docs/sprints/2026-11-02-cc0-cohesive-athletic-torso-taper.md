# 2026-11-02 — Original 65-bone torso / weighted jacket: cohesive athletic taper (DRAFT / VISUAL HOLD)

## Preflight and release separation
- Read both `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` this run.
- Confirmed authenticated GitHub account `mtothek0703` (Primary / michael_kohler1@yahoo.de), writable repository `mtothek0703/learnquest-unity-web`, `main` head `97b016098eb45b602278f923b3859f178028daf9`, and independent DRAFT PR #111 on `sprint-v124-quaternius-rigged-hero`.
- Stable Skyway V153 remains the last confirmed release. **No V154 or main merge**: this candidate has not passed the visual quality gate and must not block other independent stable features.
- V124 in the experimental branch name is not a reserved release number.

## Cohesive source-mesh and jacket work
- `godot/rider_external_body_resculpt.gd`: narrow the original source-skinned waist and lower ribs with overlapping smooth Gaussian transitions, slightly reduce upper-chest expansion, and increase the *front-only* sternum recess. Source geometry, four normalized weights, original 65-bone skin, index topology and number of draw calls remain intact. No rigid body overlay, touch or collision changes.
- `godot/rider_external_skinned_outfit.gd`: pull the actual four-weight jacket waist inward and reduce chest depth to follow the original source body's new shape, without removing the dorsal V/scapular contour or sleeves.
- `godot/rider_external_body_resculpt_test.gd`: require real continuous source waist/lower-rib taper and a larger front sternum recess while keeping original foot/face, bilateral shoulder, rig, normals and skin checks.
- Commits: `4c7332ec` (source), `450bab2a` (weighted jacket), `08d0fe08` (regression).

## Validation status
- Previous successful baseline: Godot PR CI [41499427970](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41499427970) on the earlier chest-sculpt code, 52/52 steps. **It does not validate this new redesign.**
- New full Godot PR CI: [41508466645](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41508466645), started for `08d0fe08`. Outcome **pending** at the time of this initial documentation commit; update with the actual result before claiming success.
- Required before merge/release: headless gameplay and all skin regression tests, Web export, real 16:9 / 19.5:9 side/chase/front image comparison, visual approval, archive guard and Pages SHA/HTTP checks. None of these are assumed successful for this candidate merely because code was committed.

## Quality decision
- Keep PR #111 DRAFT / VISUAL HOLD. This is a materially broader original-geometry trial than the prior tiny collar tweaks, **not** a claim that the final silhouette is now high quality.
- Real iPhone Safari FPS, all-pose clipping, and uninterrupted touch play after three English questions remain unverified. Preserve four worlds, bosses, four powers, old immutable Skyway builds and Unity archive.
