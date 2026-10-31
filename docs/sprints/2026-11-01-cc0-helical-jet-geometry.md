# LearnQuest 3D — 01.11.2026 — Experimental triple-helix propulsion (Spur B)

## Preconditions
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main`.
- Verified GitHub account `mtothek0703` (Primary, michael_kohler1@yahoo.de), repository `mtothek0703/learnquest-unity-web`.
- Stable channel remains independently published at `skyway-v138/` (main release `3200b304`, CI/Pages `41248186601`, `41248186623`, `41248186611`). **No V139 claimed.**
- Experimental PR #111 remains **DRAFT / VISUAL HOLD**, and its historic V124 label reserves no version.

## Problem identified from actual prior render QA
Earlier chase/turbine frames show two broad, semi-transparent, striped wake sheets that obscure the sculpted board and can become balloon-like. Merely shortening those translucent tubes did not remove their broad filled silhouette.

## Implementation
- `godot/hoverboard_boost_wake.gd`: replace each continuous wide translucent wake surface with **three distinct, narrow, physically modelled 3D helix tubes**, all packed into the existing one ArrayMesh per turbine. Two mesh draw calls remain; no collision, touch, animation, power-up, or gameplay changes.
- Each tube follows a separate 2.25-turn trajectory around the original nozzle axis, with a radius tapered to the tip. Vertex alpha now fades each **real narrow tube**, instead of painting high-contrast stripes across a wide translucent exhaust sheet.
- Keep the original exhaust attachment, 0.95-unit base length, asymmetric turn extension, frame-time response, and mobile boost fade.
- `godot/hoverboard_boost_wake_test.gd`: verify all three helix tubes exist in actual uploaded mesh vertices on both sides, mirrored spatial separation, narrow taper, no collisions, unchanged boost and steering at 30/60 FPS.
- Performance trade-off: 2 wake draw calls unchanged, 3×32×8×6 = **4,608 vertices per wake**, compared with 40×12×6 = **2,880** previously. Reduced overdraw is the intended trade-off; real iPhone FPS not yet measured.

## Quality gates
- GitHub Actions full Godot headless suite, import, web export, and landscape visual capture must pass before this can be called technically verified.
- Inspect real 1280×720 and 1170×540 chase/oblique frames against the prior artifact, with attention to wake occlusion and rider silhouette. **No visual acceptance yet.**
- Manual iPhone FPS, Safari, clipping and full three-English-questions-to-race touch playthrough remain outstanding.
- **No merge, no stable release, no change to immutable Skyway archives or Unity archive** while overall CC0 character quality is unapproved.

## Next step
Inspect CI logs and the generated images. If the helices are not visually cleaner, iterate or revert on this DRAFT branch; do not misreport a high-end character improvement.
