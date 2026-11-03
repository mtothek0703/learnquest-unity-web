# LearnQuest CC0 DRAFT: original-skinned dorsal V-tail hem

Date: 2026-11-03 (Europe/Berlin). Repository: `mtothek0703/learnquest-unity-web`, experimental branch `sprint-v124-quaternius-rigged-hero`, DRAFT PR #111.

## Goal and actual change
The 65-bone character's rear jacket had a horizontal waistline in the real 16:9 chase/oblique QA, compounding the boxy upper-body silhouette. Sculpt a **continuous downward V at the back center**, blending to both hips, instead of another decorative line or extra rigid piece.

- `godot/rider_external_skinned_outfit.gd`: the existing four-weight imported-skin jacket surface receives a rear-facing, height-localized and symmetric center-hem displacement. The mask is based on the source glTF bounds and surface normal, so the front hem is unchanged.
- No new mesh, triangle, material, draw call, asset, collision, input, or rig. Original 65 bones, weighted geometry, animations, touch, quiz/gameplay and historical releases remain untouched.
- `godot/rider_external_skinned_outfit_test.gd`: new geometric regression samples the real jacket offset at rear spine, both hips and front, requiring a visible rear V-tail with bilateral symmetry and unchanged front.

## Verification status
- Code commit `d58863ad977fbffa697f9858b853cb9d192a5e44`; regression commit `9588a1089858397e983be348583ddbe9234a3cb2`.
- **Godot PR CI, Web export and actual landscape PNG comparison: pending** at documentation time. The geometric regression is not proof of improved visual quality. Compare same-pose 1280×720 chase and both oblique views, including source-only noise control, before any acceptance claim.
- Entire character silhouette, clothing/boot clipping, iPhone Safari FPS and complete three-English-questions-to-touch-round test remain **unapproved**.
- Keep PR #111 **DRAFT / VISUAL HOLD**, no merge, no V124 reservation, no release. Independently stable `main` remains on verified `skyway-v154/`; preserve all immutable Skyway URLs and Unity archive.
