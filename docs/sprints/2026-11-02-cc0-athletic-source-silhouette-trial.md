# 2026-11-02 — Experimental track B: continuous athletic source silhouette

## Baseline
- Correct account mtothek0703; repository mtothek0703/learnquest-unity-web.
- Main baseline V153 at 97b016098eb45b602278f923b3859f178028daf9.
- Read LEARNQUEST_SPRINTS.md and LEARNQUEST_RELEASE_POLICY.md on main.
- PR #111 stays DRAFT; title does not reserve V124 or any release number.

## Implementation
- Resculpted the ORIGINAL imported four-weight CC0 body before fitted jacket/sleeves are extracted, preserving 65 bones, inverse bind matrices, mesh surface count and game physics.
- Outer shoulder/deltoid contraction strengthened 0.19 to 0.25, neckline contraction 0.12 to 0.15.
- Shoulder depth taper strengthened 0.075 to 0.095, neckline depth 0.045 to 0.055.
- Anatomical shoulder descent increased 0.028 to 0.044 of source body height at its mask maximum; front sternum recess 0.095 to 0.125 of source depth.
- Strengthened the geometric regression minimums for shoulder width, downward slope and pectoral recession. Head, hands, soles, touch, board and existing mechanics remain unchanged.

## Gates and risk
- Full PR Godot CI: **pending**; do not count prior green runs as verification of this trial.
- Identical camera front/chase/bilateral profile comparisons and manual clipping assessment: **pending**. Stronger sculpt is an experimental candidate, not a demonstrated visual improvement.
- Real iPhone landscape FPS and uninterrupted three-vocabulary-to-full-level touch playthrough: **pending**.
- **NO MERGE / NO RELEASE**. V153 and all immutable Skyway/Unity archives remain unchanged.

## Next step
Fix any test regressions; compare true 1280x720 and 1170x540 before/after renders with shader time frozen. Revert or adjust the stronger sculpt if seams or silhouette quality worsen. Keep independent stable track A moving.
## Actual results (after CI)
- First CI failed the prior 3.3%-height vertical shoulder displacement limit. The intentionally steeper shoulder slope now uses a 4.7%-height upper bound; separate explicit head/hand/foot, skinning and normals guards remain.
- Full [Godot PR CI 41518718846](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41518718846) **SUCCESS** for code commit `0e02c57a3075246d1448e28d39e64f7adacea90b` including web export and actual image captures. This later documentation-only commit is not separately tested.
- Downloaded and inspected the 24 real landscape images in artifact `learnquest-v124-source-body-sculpt-before-after`. At 1280×720, pixels with maximum RGB delta >25: full-rider front **0.129%**, full-rider chase **0.516%**, source-only front **0.513%**, source-only chase **0.965%**.
- The full-rider still looks bulky at shoulders/chest and is not clearly higher quality. **Visual gate FAILED; PR #111 remains DRAFT. No merge, no release.**
