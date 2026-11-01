# 2026-11-01 — DRAFT CC0 65-bone hair: tapered source-skinned locks

Mandatory main policies read; verified GitHub Primary mtothek0703, repo ID 1427565370, DRAFT PR #111 branch. Stable channel independently continues via PR #130 (V142 candidate), latest confirmed release V141.

## Geometry change
- The five genuine GPU-skinned original-65-bone rear hair volumes now taper their lower third by up to 34% instead of ending in blunt tubes.
- Their lower ends fan outward symmetrically by up to 0.044 source units while scalp roots remain fixed, and move 0.020 units rearward to give depth.
- Sculpting occurs on actual original hair vertices before rest-pose conversion, preserving imported Skin, original four weights, bind matrices, shader wind, collision, touch and gameplay.
- New deterministic regression checks unchanged roots, tip taper, mirrored fan and vertical continuity. Existing complete 65-bone tests and landscape visual capture remain mandatory.

## QA gate
- [ ] Full 52-step Godot CI and Web export.
- [ ] Compare real landscape chase/front/detail images against previous PR #111 render artifact.
- [ ] No claim of major art quality from geometry metrics alone.
- [ ] Entire figure and hoverboard still require a coherent high-quality silhouette and manual real-iPhone Safari FPS, clipping and three-English-question full touch playthrough.
- [ ] PR #111 stays DRAFT; no merge, no immutable release number reserved.
