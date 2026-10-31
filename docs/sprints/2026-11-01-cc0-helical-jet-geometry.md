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

## Render QA finding and second implementation step
- First complete CI [41251626997](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41251626997) passed Godot tests, Web export, and 16 real wake frames ([artifact 13061059242](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41251626997/artifacts/13061059242)).
- **Actual visual inspection revealed a critical oversight:** the new narrow helices were visible, but the broad striped sheets and floating dots remained **even in the wake-off control**. Their source is the independent older `cinematic_ion_wake.gd` renderer, not the replaced `hoverboard_boost_wake.gd` mesh. The first pass therefore did **not** solve the clutter by itself.
- Second step: `cinematic_ion_wake.gd` now exposes `set_streamlined_mode()`; `hover_hero.gd` enables it only if the sculpted chassis and BoostWake actually exist. Four old broad ribbon meshes and twelve sparks remain present as a **safe fallback**, but are hidden when the modern helix jets are active. The old engine light remains available. The new regression checks this exact hierarchy and conditional visibility.
- This second-step code requires its own **fresh CI and actual off/neutral/left/right image comparison** before any quality claim. Still DRAFT, never merge while visual hold remains.

## Second render inspection — cleanup results
- [Full Godot CI 41252140678](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41252140678) **SUCCESS** on the version with old ion ribbons/sparks and primitive flames/contrails hidden. [16 original landscape frames, artifact 13062275093](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41252140678/artifacts/13062275093) inspected.
- In the actual 1280×720 chase image the former enormous striped exhaust sheets and twelve drifting bright dots are gone. Three distinct luminous helix strands per engine are visible. This is a substantial **local board-silhouette cleanup**, not yet a high-end full-character approval.
- The inspection exposed two additional disconnected cyan rear spheres, visible even in the `off` control. They were identified as older `hover_hero.gd` rear flare primitives, not the new helix. The last cleanup now hides them only when the sculpted chassis and modern wake are ready; nodes remain as fallback and regression checks their presence/visibility. **Fresh final CI and visual QA required.**

## Quality gates
- GitHub Actions full Godot headless suite, import, web export, and landscape visual capture must pass before this can be called technically verified.
- Inspect real 1280×720 and 1170×540 chase/oblique frames against the prior artifact, with attention to wake occlusion and rider silhouette. **No visual acceptance yet.**
- Manual iPhone FPS, Safari, clipping and full three-English-questions-to-race touch playthrough remain outstanding.
- **No merge, no stable release, no change to immutable Skyway archives or Unity archive** while overall CC0 character quality is unapproved.

## Next step
Inspect CI logs and the generated images. If the helices are not visually cleaner, iterate or revert on this DRAFT branch; do not misreport a high-end character improvement.
