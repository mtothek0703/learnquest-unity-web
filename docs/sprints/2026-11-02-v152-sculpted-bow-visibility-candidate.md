# 2026-11-02 — Stable lane A: V152 sculpted 3D bow candidate (PR #141)

## Rules and scope
- Read both mandatory main policies `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` in this run.
- Verified GitHub Primary: `mtothek0703` / `michael_kohler1@yahoo.de`, exact repository `mtothek0703/learnquest-unity-web`.
- Base main `16693217f9cc37b59329cb2e46ce090680b15e9b`, last confirmed stable Skyway V151. PR #111 experimental 65-bone hero remains a separate DRAFT; it reserves no version.
- This PR changes only the existing stable hoverboard visuals and their test/release gate, not the CC0 character.

## Actual 3D work
1. `godot/hoverboard_sculpted_hull.gd`: physically sculpt two symmetric raised chines and a recessed central trough into the **existing closed GPU chassis triangles**. Smooth longitudinal fade before the footbeds, subtle surface-following vertex-color highlight, no extra mesh or draw calls.
2. `godot/hover_hero.gd`: remove six outdated rectangular/flat nose and deck overlays from the *visible* render only when the sculpted hull has successfully built. The large purple legacy nose prism was covering the new 3D bow. Original meshes remain in the scene and reappear automatically when sculpted-board initialization fails.
3. `godot/hoverboard_sculpted_hull_test.gd`: assert bilateral 3D relief and real mesh vertices, retained fallback meshes and visible new hull/deck.
4. `.github/workflows/publish-unity-webgl.yml`: prepare **new** immutable `skyway-v152/`, refuse existing URL, preserve historical Skyway and Unity files.

## Release gate
- PR #141 starts DRAFT. Full Godot PR CI, headless gameplay, Webexport, archive protection and actual landscape image comparison must pass before merge.
- After merge: main Godot/Pages/archive CI, published five build files HTTP 200, `build.txt` equal to merged main SHA. If visual improvement is insufficient or tests fail, **do not publish**.
- Never overwrite V151, older Skyway URLs or Unity archive. Preserve three English questions, four worlds, boss fights, four abilities and mobile touch input.
- Real iPhone FPS, clipping and full end-to-end touch run remain a separate manual QA gate.

## Code commits
- 3D geometry: `3a09faef3d33e66041f82a8e0ff049f595741221`
- Flat overlay retirement: `54f796ce6177b3ad5590301346e68ca3b43f9f64`
- Geometry/fallback regression: `263e8c4e8127efcd1e67b9628b69e072c68e585a`
- New immutable URL release gate: `450042fe0bea01acbed887479b47a80b02159984`

## Technische PR-Abnahme und echte visuelle QA (02.11.2026)
- [Godot PR-CI 41382799008](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41382799008): **SUCCESS**, inklusive Headless-Gameplay, Godot-Import, Webexport und Querformat-Renderbilder.
- [Historischer Pages-Archivschutz 41382799113](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41382799113): **SUCCESS**.
- Originalbilder aus V151 [CI 41372959002](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41372959002/artifacts/13110496167) gegen den neuen Kandidaten [CI 41382799008](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41382799008/artifacts/13113374531) verglichen: gleiche 1280x720 Front-/Chase-/Profilkamera, Pose `idle`.
- Frontbild: **11.073 / 921.600 Pixel (1,201%)** unterscheiden sich um mehr als 25 RGB-Werte; Chase: **8.695 / 921.600 (0,943%)**. Diese Rohzahlen enthalten mögliche Kontroll-/Animationsdrift und sind **kein alleiniger Qualitätsbeweis**.
- Tatsächliche Frontbilder zeigen den zuvor sehr großen violetten flachen Bugkeil durch eine zusammenhängende dunkle, skulptierte 3D-Bugform ersetzt. Das ist eine deutlich sichtbare, zusammenhängende Verbesserung der Frontansicht; die Verfolgeransicht ist nur moderat verbessert. Kein High-End-Gesamtcharakter beansprucht.
- V152 erst nach grünem Main-CI, erfolgreichem Pages-Deployment und exakter Buildrevision als veröffentlicht kennzeichnen.
