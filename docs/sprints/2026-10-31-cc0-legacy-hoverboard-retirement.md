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
- **CI on final head pending.** Do not claim tests, export or image comparison passed until the final GitHub Actions run completes. A code diff or image count alone does not establish improved overall visual quality.
- Inspect the paired rendered frames; if the cleaned silhouette is not clearly better, keep PR #111 DRAFT.
- Stable channel stays V134 unless a separate completed playable or genuinely visible feature is tested, merged and deployed with exact Pages revision and archive proof.
- Real iPhone Safari FPS, clipping, complete three-English-question + touch-race playthrough, and >1 GB Pages artifact remain unresolved.
