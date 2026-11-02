# 2026-11-02 — Original 65-bone lead/trailing surf-arm pose (DRAFT visual hold)

## Mandatory preflight / independent stable track
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` on `main`; verified GitHub Primary login `mtothek0703` and exact repository `mtothek0703/learnquest-unity-web`.
- `main` remains `97b016098eb45b602278f923b3859f178028daf9`, last verified stable Skyway V153. The independent stable release track must not wait for PR #111.
- PR #111 remains DRAFT. Its historic V124 title reserves no version. No merge or new stable release from this experiment.

## Implemented on the existing DRAFT branch
- [`072fdba4`](https://github.com/mtothek0703/learnquest-unity-web/commit/072fdba417bf76dab1132085a867fd200fa9583c): replaced the symmetrical idle shoulder pitch with an original-65-bone **left forward / right trailing** surf-arm pose. Real source-skinned upper arms now respond differently to outside/inside carving; weighted sleeves, imported skeleton, four normalized skin influences and board contact remain intact.
- [`d3adcf30`](https://github.com/mtothek0703/learnquest-unity-web/commit/d3adcf30ae41f5be13ebabbfa1bf1d7d8bf4795c): strengthened the existing athletic-pose regression to assert both genuine imported shoulder-joint orientations, in addition to bilateral carve, recovery, 30/60 Hz and collision checks.
- No changes to Touch gestures, three English tasks, four worlds, bosses, abilities, gameplay collisions, historical Skyway builds or Unity archive.

## Tests and visual QA
- Final **code/test** commit `d3adcf30ae41f5be13ebabbfa1bf1d7d8bf4795c`: [Godot PR CI 41472718871](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41472718871) **completed/success, 52/52 job steps**, including Godot import, gameplay and original-Skin regressions, Web export, and real phone-landscape image captures.
- [New 32-frame action comparison artifact 13156611172](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41472718871/artifacts/13156611172) compared with [previous successful 32-frame artifact 13150730590](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41461855941/artifacts/13150730590), using identical named 1280×720 captures. Both ZIP archives contain exactly 32 PNGs.
- Maximum absolute RGB channel difference >25: complete CC0 **neutral** front 2,905/921,600 pixels (0.315%), chase 7,372 (0.800%); **carve-left** front 24,284 (2.635%), chase 18,411 (1.998%); **carve-right** front 30,630 (3.323%), chase 33,541 (3.640%); **boost+jump** front 32,526 (3.529%), chase 40,107 (4.352%).
- **Important control drift:** the unchanged V123 `before` captures already differ across runs: neutral front/chase 218/5,625 pixels; carve-left front/chase 27,833/24,363; carve-right 36,632/28,252; boost+jump 14,504/42,109. Therefore raw cross-run differences **cannot** prove visual improvement. The action frames are not fully deterministic, especially moving board/hair and pose timing.
- Manually inspected the paired front/chase neutral and left-carve captures. The imported weighted left arm moves visibly across the upper torso in chase views, but the broad shoulders, high collar, face and rigid-looking lower-body stance remain. The asymmetric pose is a **real technical experiment**, not a convincing commercial-quality improvement. **VISUAL HOLD; no merge, no release.**

## Next steps
1. Make pose-locked captures genuinely deterministic, including the unchanged V123 control, so movement can be separated from render drift. Check side-profile and hands/torso intersection, then revise arm reach with evidence rather than guessing.
2. Prioritize a coherent redesign of face, jacket, shoulders, upper arms and board composition at actual gameplay-camera distance. Preserve original 65-bone Skin and mobile performance.
3. Separately continue stable gameplay/landscape improvements on `main` when genuinely complete; validate Godot, export, archive protection, Pages and exact immutable build SHA before any new URL.
4. Real iPhone Safari FPS, all-pose clothing clipping and full three-quiz touch-play remain unverified.
