# CC0 DRAFT — Hoverboard fairing physically joins the carved fins (02.11.2026)

## Scope and intent

Track B only, PR #111 `sprint-v124-quaternius-rigged-hero`. Real 1280×720 chase/oblique captures exposed detached outboard leaves. This sprint changes the actual existing procedural 3D meshes and their placement, **not** the stable release, controls, physics, collisions, historical Skyway folders, or Unity archive.

- Move both hinge roots inward by 0.10 and down by 0.065 board units, preserving mirrored 65-bone rider composition.
- Resculpt the existing closed, 10×10-section fairing: its inner root overlaps the deck top; its outer tip intersects the actual swept aerofoil near 42% span. A brighter satin upper face improves legibility without a new mesh or draw call.
- Preserve the original swept, capped aerofoils and independently animated emissive signal edges; keep the same frame-time smoothing at 30/60 FPS.
- Strengthen the existing headless board regression to check actual mount-to-fin proximity and hull embed, not just separate mesh existence. Update deployment bounds to the new compact neutral stance.

## Release gate

Run Godot PR checks (gameplay, original skin, fin geometry, landscape capture, Web export) and archive protection. Inspect the new 16:9/19.5:9 fin screenshots before any visual acceptance. **Visual QA remains HOLD; no merge, no release, no reserved V124.** This is a physically connected board-art candidate, not a claim of iPhone-tested graphics or a high-end character.

## Outcome

Code and tests committed to DRAFT branch; CI and rendered-frame review must be recorded separately once available. Stable main remains on its latest independently verified immutable Skyway release.
