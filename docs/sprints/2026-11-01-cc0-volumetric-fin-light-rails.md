# 01.11.2026 — DRAFT PR #111: closed luminous 3D carve-fin edge rails

## Required policy and target
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before work.
- Verified GitHub Primary `mtothek0703` (profile ID `339490599`, email `michael_kohler1@yahoo.de`) and repository `mtothek0703/learnquest-unity-web` (ID `1427565370`). No Grees Klimatechnik connection used.
- Last confirmed stable release is V140. Independent stable-track V141 sky-terrace candidate is being tested in PR #129; the experimental 65-bone hero does not block it.

## Actual geometry improvement
- The prior carve-fin luminous trim consisted of a flat, two-triangle-per-segment decal. It is now a **closed eight-sided, longitudinally tapered 3D luminous rail** with analytical radial normals, capped ends and a 0.027-unit maximum radius.
- Each rail follows the existing swept upper fin crest on port and starboard; no extra MeshInstance3D, material, texture, external asset, collision or gameplay input is introduced.
- A new regression asserts >1000 actual rail vertices, normals, both radial dimensions and tapered tips on both fins.
- Existing 24 OpenGL before/after frames in 1280x720 and 1170x540 must still pass. A visible change in these captures is not equivalent to manual artistic approval.

## Acceptance
- Geometry commit `c2ccd536`; regression commit `c1e08bb1`.
- [x] Final [Godot CI #41280688224](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41280688224) **SUCCESS**, 52/52 steps, including headless gameplay/rig regressions, Web export and 24 OpenGL landscape frames. The first runs failed due a GDScript inferred angle type and a test variable declared after use; corrected in commits `e8c9a90c` and `e2ea29c6` before the successful run.
- [x] Downloaded [24 current frames](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41280688224/artifacts/13073485525) and [24 previous frames](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41276285234/artifacts/13071582324), compared same-camera PNGs. Pixel threshold max RGB channel >25/255: 1280x720 chase right **512 px (0.0556%)**, chase left **513 px (0.0557%)**, three-quarter right **253 px (0.0275%)**, three-quarter left **666 px (0.0723%)**. The rail geometry is technically volumetric, but its on-screen visual contribution is **very small**; no claim of a significant aesthetic upgrade. The figure remains toy-like and overall quality gate is NOT passed.
- [ ] Manual iPhone Safari FPS, three-English-question-to-full-round touch test, all-pose clipping and overall superior character quality remain outstanding.
- **NO MERGE, NO RELEASE:** PR #111 stays DRAFT / visual hold. V124 in historical branch naming reserves no release number. Preserve main, all immutable Skyway versions, four worlds, bosses, four powers and Unity archive.
