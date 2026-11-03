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

## Verified result — CI and original-frame comparison
- [Final code-head Godot PR validation 41551873088](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41551873088): **completed/success, 52/52 job steps**, including headless gameplay and skinned-jacket regression, Godot web export, 16:9/19.5:9 rendering and image uploads. This run checks code/test commit `9588a1089858397e983be348583ddbe9234a3cb2`; the later documentation-only commit is not a separate tested code head.
- [New original 132-image hero artifact 13192137802](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41551873088/artifacts/13192137802) compared directly against [previous 132-image artifact 13186574516](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41543572411/artifacts/13186574516), same `1280x720_chase_*` camera/pose.
- RGB per-pixel maximum channel difference >25: full rider `chase_after` **826 pixels** (0.090% of 921,600); isolated upper-jacket layer **886 pixels** (0.096%); unchanged `chase_before` control **292 pixels** (0.032%). Within the 190×110 waist ROI (x=550–739, y=300–409), isolated jacket **709** pixels differ, full rider **648**, control **60**. This localizes the real geometry change to the waistline rather than a shader-time-only shift.
- Human review of the genuine chase close-up: the rear center hem is slightly more tapered but remains visually subtle under other costume layers. The character is still bulky, with unconvincing arms, boots and jacket proportion. **No claim of a high-end visual acceptance**, and no real-device FPS or full-touch-run test.

**Decision:** keep PR #111 DRAFT / VISUAL HOLD; no stable release for this small experiment. Continue larger coordinated silhouette redesign and real iPhone QA. The independent stable release remains immutable V154.
