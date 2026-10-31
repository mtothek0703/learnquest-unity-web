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

## Controlled CI and visual QA (same run)
- [x] [Godot CI 41238144672](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41238144672) **completed/success**, including existing 65-bone gameplay and wake regressions, Web export and the 16 phone-landscape wake frames.
- [x] [Actual 16 PNGs, artifact 13056785516](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41238144672/artifacts/13056785516) downloaded and inspected against the preceding [artifact 13054994217](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41234807711/artifacts/13054994217). The helix alpha is technically visible, but the chase-camera right plume still produces a **large mottled purple lobe** near the bottom edge. This is not an approved visual upgrade.
- [x] **Second corrective step:** shorten the actual swept tube from 1.50 to **0.95 world units**, reduce its mid-flare, and tighten the geometry regression while keeping original nozzle anchor and left/right boost steering. Commits `8c7ddf7f` and `53d8438c`.
- [ ] **Final revised head CI and 16-image visual review pending.** Do not claim the smaller jet looks premium until actual frames confirm it. PR #111 remains DRAFT; stable releases are independent.
