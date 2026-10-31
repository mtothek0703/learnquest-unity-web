# 31.10.2026 – DRAFT PR #111: sculpted hoverboard turbine channels

## Preconditions and isolation
- Read both mandatory files `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` on `main`.
- Verified connected GitHub identity `mtothek0703` (Primary account `michael_kohler1@yahoo.de`) and exact repository `mtothek0703/learnquest-unity-web` before writing.
- Latest verified stable release remains **Skyway V134**, main CI/Pages/archive passed in runs 41214483562 / 41214483525 / 41214483490. PR #111 remains DRAFT and visual quality HOLD; its title reserves no version. Do not merge or publish as V135 on this evidence.

## Genuine 3D change (experimental branch only)
- Commit `3775f367` sculpts four longitudinal recessed cooling flutes into **each of the two existing closed 3D turbine housing meshes**. The flutes are actual displaced vertices, not decals or decorative cubes. Their depth is 0.036 board units at the central body, with smooth taper at front/rear closed caps.
- Each flute also receives a darker integrated vertex-color treatment. Existing analytic smooth normals follow the deformed shape, and the original 16-section/24-length surface, materials, draw-call count, parent animation and boost halos are retained.
- Commit `2be8f54b` adds a Godot regression checking the 3D depth difference, front cap fade and actual mesh vertex positions on **both mirrored engines**.
- No new asset license, gameplay rules, collisions, input controls or changes to the imported CC0 65-bone skeleton/Skin. Historical Skyway URLs and the Unity archive remain untouched.

## Verification gates
- **Pending:** complete Godot PR validation on the latest code-and-test head `2be8f54b` including import, gameplay, skinning regressions, Web export and real landscape render capture. Earlier green CI on `4a99be10` validates the prior traction deck only and does not certify this change.
- **Pending:** compare original rendered board chase/close-up PNGs with the previous PR head. A mesh assertion alone does not prove that the flutes are visible in the player-facing view.
- **Still open:** complete iPhone Safari 16:9/19.5:9 touch playthrough after three English questions, actual FPS, all-pose clipping and visual approval of the whole character/board.
- Stable V134 continues independently; no forced V135. Pages size >1 GB remains a risk.

## Next steps
1. Fix any failing Godot CI, inspect images, and record the final exact head SHA and workflow evidence.
2. Continue a coherent character/hoverboard silhouette redesign rather than minor percentage tweaks.
3. Develop a separate complete gameplay feature for the stable channel; require all PR/main/Pages/archive checks and a new immutable URL before announcing it.
