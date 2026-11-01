# V148 candidate – Star Harbor overhead transit arches (1 November 2026)

## Scope / stable track A
Starting point: verified main `11c2a54a5bc0df55723ff218108df8c17972d2e2` (V147). The next candidate is V148 **only if** tests, image review, archive protection and deployment succeed. PR #111 remains an independent DRAFT; it owns no release number.

The four orbital cargo cranes now carry **four closed, curved, three-dimensional transit arches** across the upper racing corridor. Each arch is built from a reusable procedural ArrayMesh (36 longitudinal sections, 12 radial sections), with per-vertex color shading, smoothed normals, closed end caps and subtle shared emission. Their crest reaches roughly 9.8 units above the road; their feet stay above 7.65 units. The centerline spans 10.3 units from one side of the course to the other. These are visual-only: no CollisionObject3D, no added light nodes, no changes to touch controls, English questions, world progression or abilities.

## Validation
- Extended existing `godot/cinematic_harbor_skycranes_test.gd` (already executed in PR/release CI) to check four real meshes, >=2500 vertices, colors/normals, non-flat 3D bounds, full lane crossing, vertical clearance, unchanged pause/wrap and collision absence.
- Required: green PR Godot CI + Web export, actual 1280×720 and 1170×540 chase-image inspection, main CI, archive/Unity preservation and successful Pages deployment with exact `build.txt` SHA before publishing V148.
- If any gate fails or the new arches do not look better in landscape, keep as candidate and do not release. Historical URLs must remain immutable.

## Experimental track B
PR #111 remains DRAFT / VISUAL HOLD. Its 65-bone CC0 character is not included in this candidate. Continue separately after the stable candidate is assessed. Real iPhone FPS, clipping and full touch-play QA remain open.
