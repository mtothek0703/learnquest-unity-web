# 31.10.2026 – DRAFT PR #111: sculpted hoverboard traction deck

## Coordination and scope
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before editing.
- Verified GitHub identity `mtothek0703`, repository `mtothek0703/learnquest-unity-web`, draft PR #111 head `sprint-v124-quaternius-rigged-hero`.
- Stable channel remains independently released **Skyway V134** (main `e92e17f5`, [Godot](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41214483562), [archive](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41214483490), [Pages](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41214483525)). No independent complete V135 feature yet; no forced release.
- The experimental branch does **not** reserve V124/V135. No merge, no stable release.

## Real 3D geometry change
- [Code f2c18c00](https://github.com/mtothek0703/learnquest-unity-web/commit/f2c18c001255413f0cd02e1b176d52dee65c00c6) sculpts **two longitudinal raised traction footbeds** and a **recessed central channel** directly into the existing curved 3D hoverboard traction deck.
- Smooth nose/tail fades prevent hard steps. The same existing mesh and draw call carry the physical height relief and differentiated vertex colors; analytic surface normals follow the actual changed geometry.
- [Regression 61ce7919](https://github.com/mtothek0703/learnquest-unity-web/commit/61ce79196b251b7083a876d6b914b84350f31e94) checks symmetry, raised pads, lowered channel, end taper, actual rendered vertices and material contrast.
- Original 65-bone CC0 rig, imported Skin and four weights, action poses, touch, collisions, four worlds, three English questions, boss battles, four power-ups, historical Skyway URLs and Unity archive are not changed by these files.

## Verification / quality gate
- At documentation time the new commit's full Godot PR CI, web export and real landscape screenshots are **not yet confirmed**. Do not call them passed without a completed/success workflow and actual artifact review.
- Technical mesh assertions are **not** visual sign-off. Compare the original 1280x720 and 1170x540 front/chase images with prior DRAFT artifacts, including board visibility and clipping.
- Manual iPhone Safari FPS, complete three-question-to-full-touch-level playthrough and all-pose clipping remain open.
- Pages artifact last recorded at 1,348,824,620 bytes (>1 GB warning). Do not alter immutable archives to reduce size.

## Next
1. Check final GitHub Actions on the new PR head, fix any red regression/export; inspect real images before claiming graphics improvement.
2. Improve the coherent character–board chase silhouette, not cosmetic percentage-only edits.
3. Independently develop and gate the next substantive stable gameplay feature; publish only under a fresh immutable Skyway URL after main CI, archive and Pages revision checks.
