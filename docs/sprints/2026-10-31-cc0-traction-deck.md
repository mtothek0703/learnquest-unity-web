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

## CI follow-up (17:20 MEZ)
- [Initial full Godot run 41219034094](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41219034094) **failed** at the new traction contrast assertion after the prior gameplay/rig regressions passed. The initial test incorrectly assumed a fixed absolute `Color.get_luminance() < 0.09` for the dark channel, although Godot color luminance is not normalized to that arbitrary threshold. This is a **test calibration failure**, not proof of a gameplay defect.
- [Correction 4a99be10](https://github.com/mtothek0703/learnquest-unity-web/commit/4a99be108651195d2f1bd731f55239412e9bf8fa) now measures the two *actual rendered mesh vertices* and demands that the raised pad is at least 0.15 luminance above the recessed channel. The geometry/vertex colors are unchanged. A fresh full CI is required; do not report success until confirmed.

## Final CI and visual review (17:24 MEZ)
- **Final corrected code/test head `4a99be10`**: [Godot PR validation 41219271959](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41219271959) **completed/success**, all **52/52** job steps successful. Gameplay, original 65-bone rig and skinned regressions, the new traction geometry/vertex-color test, Godot Web export and landscape render workflows passed. [Original 8 hoverboard close-ups](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41219271959/artifacts/13049447259).
- The earlier **code-only** run [41219023384](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41219023384) also completed successfully (original regressions + export + screenshots). The interim **new-test** run [41219034094](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41219034094) failed because of the absolute luminance threshold; corrected by `4a99be10` and revalidated. The failure was not concealed.
- **Actual original CI PNGs downloaded and compared:** baseline [41214216133 / 13047493703](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41214216133/artifacts/13047493703) vs final [41219271959 / 13049447259](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41219271959/artifacts/13049447259). With 1280×720 and max RGB channel delta >25, the *after* chase image differs by **31,828 pixels (3.45%)**, the *before/control* chase image by **5,599 pixels (0.61%)**. Front *after* **29,201 (3.17%)**, front *before/control* **4,505 (0.49%)**. Camera/shader drift exists, so these are **not** isolated quality scores. The close-ups show subtly more contoured traction geometry; **not** a major overall 3D-graphics upgrade.
- **No stable release:** PR #111 remains DRAFT/VISUAL HOLD. V134 remains the last verified stable release; V135 is not reserved. No real iPhone FPS, full touch round or all-pose clipping sign-off. Preserve every immutable Skyway URL and Unity archive.
