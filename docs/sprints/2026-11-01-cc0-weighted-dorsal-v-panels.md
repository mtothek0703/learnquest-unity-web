# 2026-11-01 — Track B: original-Skin dorsal V-panel geometry (DRAFT)

## Preflight and scope
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` this run.
- Authenticated as GitHub Primary `mtothek0703`; confirmed repository `mtothek0703/learnquest-unity-web`, ID `1427565370`.
- Stable track: main `aa5709028eb40ec2e5508ff306ed3841652c8e97` already contains the V145 chase-camera change. Its Pages workflow `41314253268` was still **in progress** when this experiment began; **do not claim a published V145 until the exact SHA/HTTP verification completes**. Previously verified stable V144 remains available.
- Experimental track: PR #111 remains DRAFT / VISUAL HOLD, no version reserved, no merge into main.

## Implementation
- `godot/rider_external_skinned_outfit.gd`: two mirrored, converging diagonal back-panel reliefs on the existing **original 65-bone / four-weight GPU-skinned jacket triangles**. A shallow center recess preserves an athletic rather than cylindrical rear torso profile. Relief is limited to 0.024 source units and fades at the waist. No new meshes, textures, rigid decorations, colliders, assets, touch input, or gameplay changes.
- `godot/rider_external_skinned_outfit_test.gd`: numeric 3D geometry assertions for the dorsal raised V, outer taper and bilateral symmetry. Existing skin/weight, headless gameplay and export regressions remain required.
- Code commits: `38f3abc7`, `4289826f`; regression commits: `1f732651`, `d707ba08` (GDScript continuation fix).

## Acceptance gates
- [ ] Final head `d707ba08` Godot PR CI succeeds, including imported original Skin, gameplay regressions, Web export and original smartphone-landscape render artifacts.
- [ ] Inspect identical-camera before/after **actual** 1280x720 and 1170x540 Godot frames. Numeric geometric difference does **not** prove improved overall character art.
- [ ] No merge, release or version reservation until whole-character visual quality, manual all-pose clipping, real iPhone FPS and uninterrupted three-question-to-full-touch-round QA pass.

## Next
- Inspect the latest CI and image artifact. If the new back V reads as a painted ridge, distorts skinning or worsens the silhouette, revise or revert this experiment. Prioritize coherent full-body art and board proportion over tiny cosmetic iterations.

## Actual test and visual QA outcome
- The first test revisions failed due to a regression assertion comparing the *signed* front-facing normal displacement rather than its magnitude. The test was corrected in `c2df7653`; this was a test logic error, not a gameplay failure.
- [Final full Godot PR CI 41315489074](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41315489074): **completed/success, 52/52 steps**, including imported 65-bone skin, gameplay regressions, Web export and real landscape QA captures. The test explicitly checks mirrored, tapered 3D V-relief.
- Downloaded and inspected original [20 character QA frames](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41315489074/artifacts/13086938208) and [108 layer-isolation frames](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41315489074/artifacts/13086813462), compared against pre-change successful CI [41313697519](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41313697519).
- At 1280×720 chase, RGB-max-channel >25: **11,219** changed pixels in the jacket-only view, **21,854** in complete rider, but **9,361** in the supposedly unchanged source-only control. Thus raw pixel counts cannot isolate the effect or establish quality. The 1170×540 chase values are **6,309 / 12,342 / 5,253**, respectively. Front and chase visual inspection shows **no convincing visible improvement to the full rider**: hair, cape and bulky accessories still obscure the subtle original-Skin dorsal geometry. The experiment remains in DRAFT, not visually accepted.
- Stable V145 was independently published by [Pages workflow 41314253268](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41314253268): SUCCESS, five HTTP 200 files, exact main SHA `aa5709028eb40ec2e5508ff306ed3841652c8e97`, **142 historical directories preserved**. This experiment was NOT included.

## Decision
Keep the geometry as an **unapproved draft trial**, not a stable release. The next visual-quality step must address the actual full-rider occlusion and overall silhouette (hair/cape/shoulders/board), with identical-camera source-only control, rather than treating this small relief as a finished upgrade. Physical iPhone FPS, clipping and three-question touch-round remain unverified.
