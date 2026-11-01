# 01.11.2026 — CC0 aerial ribbons: actual 1280×720 QA follow-up (DRAFT PR #111)

The completed 52-step CI from the prior landing-cloth sprint was followed by an actual inspection of the 1280×720 `boost_jump_chase_after.png` capture in artifact `13063555936` from run `41255899158`. The CC0 rider and hoverboard are visible, but two enormous striped V87 jump arcs still loop far outside the character and overwhelm the chase silhouette, even after the older V83 plasma wake cleanup.

**Change:** when the verified external 65-bone hero is installed, keep both existing real 3D aerial ribbon meshes and landing sparks but scale the arcs to 27% width and 35% length, move them to shoulder-side positions and fade them by 50%. The original rider/fallback retains the full V87 effect unchanged. No new geometry, collider, shader pass, input or physics.

Extend the actual CC0 rig regression to assert both compact translucent meshes, their placement, and the untouched original fallback. New action screenshots and independent before/after visual inspection are still required before any visual approval. PR #111 remains DRAFT. Stable Skyway V139 is independent.
