# 01.11.2026 — Skyway V141 candidate: Neon City sculpted sky terraces (stable track A)

## Mandatory policy and account check
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` on `main` before changes.
- Verified GitHub Primary: `mtothek0703`, profile ID `339490599`, email `michael_kohler1@yahoo.de`; target repository `mtothek0703/learnquest-unity-web`, repository ID `1427565370`, default branch `main`. Grees Klimatechnik connection was not used.
- Baseline `main` SHA `62d7e0f60d3932d8898661ac4ebe16cbf77a5005`, last confirmed immutable Skyway V140. Draft PR #111 head `070101e6` remains visually unapproved and is not included.

## Real 3D graphics improvement
- Neon City's 12 existing sculpted towers gain **24 solid annular cantilevered sky terraces** in two height tiers, with shaped 3D outer/inner rims, vertex colors, normals, and distinct cyan/pink/green district palettes. Each tower combines both tiers in **one** procedural ArrayMesh draw call.
- **96 vertical glass/lighting support fins**, eight per tower, are batched as one MultiMesh per building. Geometry is created once, has no collisions, introduces no new external assets, and remains beyond the three racing lanes.
- New structures inherit the existing tower scroll/pause behavior, so scenery does not move while answering English questions.
- 16:9 and 19.5:9 comparison script toggles **only the new geometry** to avoid falsely attributing the existing Neon City visuals to this change. PR CI uploads eight before/after frames and fails if the new architecture is not visible in either landscape view.
- Existing three mandatory English questions, four worlds, bosses, four abilities, touch input, historic Skyway releases and Unity archive are untouched.

## Acceptance gates
- [ ] New city geometry and collision/clearance regression in `cinematic_city_districts_test.gd`.
- [ ] Godot headless gameplay, imported resources, existing regressions and web export.
- [ ] Eight real rendered 1280x720 and 1170x540 chase/oblique terrace-only comparison frames.
- [ ] PR historical Pages preservation check.
- [ ] Only then merge to `main` and verify main CI, immutable `skyway-v141/` Pages publication, build.txt revision and five HTTP 200 build files.
- [ ] Real iPhone Safari FPS, clipping and full touch playthrough are still manual tasks and must not be claimed as automated.
- [ ] Pages artifact growth (V140 1,411,497,699 bytes) needs separate preservation-safe work.

## Experimental track B
PR #111 stays DRAFT, without a reserved release number. It needs a substantial coherent 65-bone hero/hoverboard visual quality improvement and manual device QA before any merge. Stable V141 candidate does not depend on it.

## Outcome
Pending GitHub Actions verification; **do not call this a published release until tests, merge and Pages evidence exist**.
