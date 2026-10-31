# LearnQuest CC0 DRAFT — helical thruster filament experiment (31 October 2026)

## Scope
- Mandatory main-branch sprint and release policy read; correct Primary GitHub account and repository verified.
- This is only experimental DRAFT PR #111, with original 65-bone CC0 Skin and character unchanged. Stable V135 is independent, while a separate V136 vocabulary candidate is under CI review.
- Previous controlled 16-frame Godot chase QA showed the two energy wakes still looked like flat translucent sheets after shortening them.

## Actual geometry/material change
- Keep the same two curved volumetric ArrayMeshes and the original turbine-root attachment, boost response, carve asymmetry and draw-call count.
- Change the per-vertex alpha field into **three intertwined helical luminous filaments** around each existing tube, fading to zero at the tail, instead of a broad uniformly translucent surface.
- New Godot regression tests the angular brightness contrast, tail fading and existing steering/boost/30-60-FPS invariants.

## Gates
- [x] Code commit `8b46d652` and geometry-test commit `eb354e48` pushed to PR #111.
- [ ] Final PR CI including Godot, 65-bone and wake regressions, Web export and 16 actual landscape wake frames.
- [ ] Inspect true front/chase 1280×720 and 1170×540 PNGs before claiming an aesthetic improvement. Numerical pixel change alone is not approval.
- [ ] Overall CC0 rider silhouette and hoverboard art gate remain blocked; **no merge, no stable release, no reserved V124 number**.
- [ ] Real iPhone Safari FPS, clipping and full touch playthrough after three English questions remain open.

PR: https://github.com/mtothek0703/learnquest-unity-web/pull/111
