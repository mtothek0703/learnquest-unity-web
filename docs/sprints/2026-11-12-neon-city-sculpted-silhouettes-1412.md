# LearnQuest 3D – Neon City tower silhouette pass (2026-11-12, 14:12 CET)

## Scope and identity
Primary GitHub account mtothek0703 / michael_kohler1@yahoo.de; repository ID 1427565370; main SHA 92d49b100a022d8864112ba38494d3565fca2a4f. Work branch: `feature/adventure-a1-walkable-neon-testbed-20261106-19`. Previous PR #157 head: 9d8809fb0b9f4389af3ce75e2f2399047eff7226. Existing PR #160 and stable releases remain untouched.

## Actual graphics change
Gameplay commit `3618b9797cd355ce6787e346be2afc560aae3a4e`: the six background tower facades now use UV-mapped, single-surface custom meshes with stepped setbacks and tapered roof shoulders, rather than six plain BoxMesh facade silhouettes. Existing procedural window shader, sign text, lamps, materials, physics and player gameplay remain. Each facade has 4 sides × 5 bands × 2 triangles = 40 triangles; total six facades ~240 triangles, excluding pre-existing trim geometry.

## Acceptance and evidence
- **Intended visible improvement:** stepped silhouettes in the genuine Neon City game camera, with window shader still aligned; no new gameplay or menu content.
- **Baseline CI:** #43200341255 succeeded on prior head 9d8809f.
- **New CI:** no run appeared yet for gameplay commit at the time of this report. **Import, headless gameplay, Web export and screenshot tests are NOT claimed passed.**
- **Required visual comparison:** capture actual Godot camera at 1280×720 and 1170×540 on both previous head and this head. Review facade winding, shader windows, crown alignment, readability and mobile budget. No before/after image was available for review during this run; visual improvement is a hypothesis until inspected.
- **Open:** physical iPhone Safari QA, frame rate, draw-call measurements, hero model quality, model clipping, live build acceptance. No merge or release.
