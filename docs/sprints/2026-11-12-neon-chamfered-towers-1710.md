# Neon City – chamfered skyline geometry (2026-11-12, 17:10 CET)

- Repository: mtothek0703/learnquest-unity-web (1427565370), Primary account mtothek0703.
- Branch: feature/adventure-a1-walkable-neon-testbed-20261106-19
- Main at start: 92d49b100a022d8864112ba38494d3565fca2a4f.
- Gameplay commit: 36880ca329cb2a9b31f875d869c5ed44fa7f3d73.
- Visual change: the six skyline towers now use an eight-sided chamfered footprint and more stepped, recessed architectural tiers instead of a square-section loft. The window shader is retained; each facade remains a single SurfaceTool mesh/surface, without added collision or gameplay changes.
- Acceptance criteria: Godot 4.4.1 import/parser succeeds; headless gameplay and Web export pass; actual camera renders in 1280x720 and 1170x540 show a clear silhouette difference without broken faces, UV artifacts or visible clipping; no runner or archive regression.
- Actually verified before edit: previous branch head 5af8ed673059ec49ac9deb1545d8c98a4c495d36 had successful Godot PR validation run 43246307893.
- New commit tests: not yet verified at documentation time. No in-game before/after screenshot comparison or iPhone Safari test performed in this sprint. Visual quality is not claimed as approved.
- PR #160 remains separate DRAFT. No merge, Cloudflare deployment or public release. V154/V155 preserved.
- Next: inspect fresh CI and downloadable real game-camera captures, fix actual import/UV failures, then prioritize replacing primitive character/environment meshes with licensed detailed Blender assets.
