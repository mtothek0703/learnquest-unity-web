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
