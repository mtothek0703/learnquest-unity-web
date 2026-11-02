# CC0 DRAFT: swept aerodynamic fairing with sculpted dorsal chine

Date: 2026-11-03 (Europe/Berlin). Repository: `mtothek0703/learnquest-unity-web`. Branch: `sprint-v124-quaternius-rigged-hero`; PR #111 remains **DRAFT / visual quality HOLD**.

## Why
The previous deck-to-aerofoil connector was a thin cylindrical spar with a fixed radial lighting normal, even though its centerline rises and sweeps laterally. The hard dark-to-bright material transition and pipe-like shape were visible from the rear three-quarter smartphone camera.

## Actual implementation
- The existing **closed procedural 3D mount mesh** gains a raised dorsal chine peaking midspan, blending to zero at both embedded ends. No extra objects, triangles, imported assets, physics, touch controls or draw calls.
- Every emitted fairing shell vertex uses a normal computed from the actual swept parametric surface, replacing straight-cylinder normals. Existing closed caps remain hard-edged.
- Vertex color blends continuously from graphite deck to the existing satin aerofoil near the fin. The original hinge, root penetration, aerofoil connection and two independent steering animations remain.
- Regression checks a measurable upper/lower sculpted profile, emitted normal alignment, finite outward normals on both sides, and existing root-to-fin overlap. The full 65-bone source model is unchanged.

## Verification / release gate
- **Pending on commit:** GitHub Godot PR validation, headless gameplay, web export and landscape render captures. Record the exact current-head CI run before treating the change as technically tested.
- **Still open:** visual A/B from original Godot landscape frames, entire-character proportion/clipping approval and real iPhone FPS/touch tests. This change alone is **not** sufficient for merging PR #111.
- Stable main and immutable `skyway-v154/` remain untouched. No version reservation; preserve all historical Skyway URLs and Unity archive.
