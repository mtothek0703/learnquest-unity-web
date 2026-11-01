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

## Verified release (01.11.2026)
- Initial candidate's isolated 1170x540 oblique image test **failed**: only ~0.4% of pixels changed and the 12-sample visual threshold was missed. Instead of weakening the test, the existing moving towers were brought into the landscape chase foreground (x = 12.2 + district offset, z begins at -8 instead of -16) and terrace overhangs were widened/deepened. Collision and track-clearance tests were updated; the foreground now has a demonstrably stronger composition.
- [Final PR Godot validation #41280666212](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41280666212) **SUCCESS**, [PR historical preservation #41280668977](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41280668977) **SUCCESS**. Eight real [terrace-only landscape comparison images](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41280666212/artifacts/13073117654) were downloaded and inspected at identical cameras.
- Actual changed pixels, max RGB channel difference >25/255: **1280x720 chase 13,509 (1.47%)**, oblique 11,142 (1.21%); **1170x540 chase 7,587 (1.20%)**, oblique 6,166 (0.98%). The two levels of protruding terraces are clearly visible on the near left/right towers. These measurements prove a visible change, not commercial-grade rendering or mobile FPS.
- [PR #129](https://github.com/mtothek0703/learnquest-unity-web/pull/129) merged by squash as `9a6187d1a101539ecc621877235d43f1b96cc56a`.
- [Main Godot CI #41280907618](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41280907618), [main archive protection #41280907632](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41280907632), [healthcheck #41280907557](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41280907557): all **SUCCESS**.
- [Pages release #41280907588](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41280907588) **SUCCESS**: Godot import, headless gameplay (four worlds, three English questions, bosses, four powers), sky-terrace geometry regression, 8 real landscape renders and Web export passed. **138 historical Skyway directories preserved**, Unity root prepared. New `skyway-v141/` created without overwrite; `build.txt`, `index.html`, `index.js`, `index.wasm`, `index.pck` each **HTTP 200**, with build.txt compared against exact main release SHA.
- Immutable playable URL: https://mtothek0703.github.io/learnquest-unity-web/skyway-v141/
- GitHub Pages upload size **1,421,958,293 bytes**, above 1-GB warning; deployment still succeeded. Prior versions untouched. Separate preservation-safe size optimization remains necessary.
- DRAFT PR #111 remains unmerged and does not reserve V124. Its separate tubular fin-rail sprint passed [52/52 Godot CI #41280688224](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41280688224), but actual visual effect was tiny (0.028–0.072% changed pixels in selected 1280x720 oblique captures). No character quality approval.
- **Still open:** physical iPhone Safari FPS, clipping and uninterrupted real touch playthrough after the three English questions; no claim that automation replaces these manual tests.

