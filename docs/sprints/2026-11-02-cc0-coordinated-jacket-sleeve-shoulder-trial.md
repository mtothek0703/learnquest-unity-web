# 2026-11-02 — DRAFT CC0 integrated jacket/sleeve shoulder trial

## Baseline and diagnosis
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main`. GitHub Primary `mtothek0703` / `michael_kohler1@yahoo.de`, repository `mtothek0703/learnquest-unity-web` verified.
- Stable `main` remains `09601905af48ff905747ea58f43177aa7f7e2e31` / immutable `skyway-v152/`. The unrelated stable V153 candidate is on its own PR. DRAFT #111 reserves no version.
- Real 132-frame isolation on CI 41405910011 showed the *weighted sleeves* substantially widen the shoulder silhouette, while the fitted jacket makes the horizontal front collar bar. No new rigid pauldrons: those are already hidden when true sleeves are present.

## Experiment (not approved)
- Keep the genuine imported 65-bone Skin and all four original weights. Taper the upper-arm sleeve shell's shoulder-only relief from 0.023 to 0.016 and side sweep from 0.007 to 0.005. Preserve elbow/forearm sculpt and the rounded deltoid crest.
- Reduce the fitted four-weight jacket's shoulder depth from 0.040 to 0.034 and spread from 0.043 to 0.038, retaining chest and back relief.
- Move the sleeve material from glossy cobalt plastic toward a more muted woven textile (lower cobalt blend and metallic response, higher roughness), without new draw calls.
- Tighten the shoulder geometry regression bounds. Do not modify original glTF, inverse bind matrices, Touch, collision, English tasks, worlds, archives or Pages.

## Required gates
- [ ] Current-head full Godot 52-step CI, web export and 132 actual matched landscape captures.
- [ ] Same-camera front/chase before/after images compared; prove a visible improvement without sleeve/neck clipping.
- [ ] Revert this trial if the full figure gets worse or changes are negligible. Keep PR #111 DRAFT until visually approved; no release.
- [ ] Real iPhone Safari FPS/clipping/full touch run remains manual and open.

## Result — tested and reverted
- [Full Godot PR CI 41414215568](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41414215568) SUCCESS on the exact experimental commit `26aa93ee25b39bea903d2971e780d7133e27fff4`: imported 65-bone Skin, gameplay, Webexport and 132 genuine landscape comparison PNGs passed.
- [132-frame original Godot artifact 13126149515](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41414215568/artifacts/13126149515) downloaded and compared with [prior 132-frame baseline 13124070221](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41405910011/artifacts/13124070221). Exact 1280x720 `front_detail_after` difference: **1,414 pixels / 0.153%** with max RGB channel difference >30; `chase_detail_after`: **2,396 / 0.260%**. The broad collar and upper-arm outline remain visibly nearly identical; no meaningful quality leap.
- Because the integrated shoulder trial did not clear the visual quality gate, **revert all four experimental code/test/shader files** to their immediately preceding verified blobs. Keep this record and the previous 132-frame diagnostic. No merge, no V153 release from PR #111, no iPhone acceptance.
- Next: stop iterating tiny shoulder coefficients. Prioritize an actually different cohesive jacket/face/hoverboard design, ideally a new licensed cohesive asset or substantial re-topology, and require large same-camera front/chase improvement before release.
