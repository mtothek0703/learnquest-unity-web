# 2026-11-02 — Stable track A: Aurora Glacier flowing 3D ice channels (candidate)

## Baseline and account
- Correct GitHub account: mtothek0703 (michael_kohler1@yahoo.de), repository mtothek0703/learnquest-unity-web.
- Main baseline: 97b016098eb45b602278f923b3859f178028daf9, last verified immutable Pages release Skyway V153.
- Read LEARNQUEST_SPRINTS.md and LEARNQUEST_RELEASE_POLICY.md from main before editing.
- Work isolated on feature/v154-glacier-flow-ribbons, PR #143. PR #111 untouched by this track.

## Genuine change
- Six existing Aurora icefalls now have 18 raised, curved 3D meltwater channels (three per icefall).
- Each channel has 384 vertices, raised center ridge and UV flow along the real folded ice geometry.
- Three reusable ArrayMeshes and one opaque unshaded emissive ShaderMaterial with traveling light pulses; no new asset license, collision, lights, touch input, gameplay rules or historical build changes.
- Regression checks actual 3D geometry/depth/height, material reuse, lane clearance, scrolling, pause and wrap.

## Acceptance gate
- Full Godot PR CI and Web export: **pending**, do not claim pass without run evidence.
- Actual 16:9 and 19.5:9 render artifact: **pending visual review**; prior icefalls capture alone does not prove this incremental feature.
- Archive protection, main merge, Pages deployment and build.txt SHA: **not yet completed**.
- **NO RELEASE until all gates pass**. Skyway V153 remains the latest stable; do not overwrite any older Skyway URL or Unity archive.

## Next step
Review CI and actual screenshots. If the incremental channel effect is too small, improve geometry/contrast before merge. Otherwise finish archive check, merge only tested head, verify main and publish the next unused immutable version.