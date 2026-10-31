# LearnQuest 3D — DRAFT hoverboard silhouette cleanup (31.10.2026)

## Mandatory release discipline
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` on **main** before this run.
- Last verified stable release remains **Skyway V134**, main build `e92e17f5b624ca75b8a6f4dd233ddd013e4afb11`. Earlier [main Godot CI](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41214483562), [archive check](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41214483490) and [Pages](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41214483525) succeeded. This DRAFT sprint **does not** modify main, reserve V135, or publish a new Skyway URL.
- [PR #111](https://github.com/mtothek0703/learnquest-unity-web/pull/111) remains **DRAFT / VISUAL HOLD**. The title V124 reserves no version.

## Spur B: coherent board silhouette instead of adding more tiny decorations
- In `godot/hover_hero.gd`, retain the two legacy cylinder+torus turbine groups and two tall vertical fin prisms **as hidden fallback**, but do not render them when the replacement sculpted hull is successfully built.
- The real, smooth-shaded, four-channel turbine housings, rear exhaust halos, curved wing shells and articulated carve fins remain visible. Keep original independent animated flames, turbo trails, ion wake, board lean, hover, jump and collision/touch controller.
- This removes **six duplicate static MeshInstance3D renderers** from the successful sculpted-board view (four legacy turbine primitives plus two fin prisms) without removing their fallback scene objects or adding new materials/colliders.
- Extend `hoverboard_sculpted_hull_test.gd` to require the four original groups/prisms to remain present and hidden, both turbine fallback groups to retain their cylinder and torus, and all six redundant meshes to be accounted for.
- Extend the existing turbine render QA from eight to **16 real phone-landscape frames** (1280×720 and 1170×540, front and chase): original new-turbine A/B plus `legacy_before` / `clean_after` pairs. The QA now freezes the rider subtree during paired captures to prevent animation drift from masquerading as geometry improvement.
- CI workflow requires all 16 images and uploads them as a dedicated artifact.

## Gates and open risks
- **Final code head `431ba6e3` technically green:** [Godot PR CI 41228397745](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41228397745) completed/success, including existing gameplay/65-bone/hoverboard regressions, Web export and **16 real landscape frames**. [Original 16-frame artifact 13052447203](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41228397745/artifacts/13052447203). The following Markdown-only commit does not alter tested code.
- **Actual visual A/B inspected:** compared `legacy_before` and `clean_after` at the same frozen camera and rider pose. For RGB maximum-channel absolute difference >25: **20,134 pixels** in 1280×720 chase (2.18% of frame), **2,856 pixels** in 1280×720 front; 1170×540 chase **11,328**, front **1,619**. The original large white duplicate rear torus rings disappear in the chase view, leaving the new sculpted cyan turbine openings and trails. This is a genuine visible board silhouette cleanup, not a high-end total-character transformation. The paired `after` and `clean_after` frames are byte-identical in both camera sizes, confirming the A/B scene restores the intended clean final state.
- Inspect the paired rendered frames; if the cleaned silhouette is not clearly better, keep PR #111 DRAFT.
- Stable channel stays V134 unless a separate completed playable or genuinely visible feature is tested, merged and deployed with exact Pages revision and archive proof.
- Real iPhone Safari FPS, clipping, complete three-English-question + touch-race playthrough, and >1 GB Pages artifact remain unresolved.
