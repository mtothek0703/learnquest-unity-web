# LearnQuest 3D — focused CC0 portrait trial (2026-11-01, DRAFT)

## Scope and release isolation

Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` on `main`; verified the Primary GitHub account `mtothek0703` / `michael_kohler1@yahoo.de` and repository `mtothek0703/learnquest-unity-web`. The independent stable channel has already published **Skyway V148** on main `522d43dc451cb727737e163848bfb8007297ebca`; [Pages 41340498328](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41340498328), [Godot 41340498309](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41340498309), [archive protection 41340498313](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41340498313) are completed/success. Pages checked all five files HTTP 200 and the exact build SHA; artifact size **1,495,451,549 bytes**, above its 1-GB warning. No need to force V149 in this run.

## Actual experimental modeling

The original 65-bone CC0 portrait is visually over-wide-eyed, with very bright cyan irises and an exaggerated grin in real 1280×720 / 1170×540 frontal QA. On the DRAFT branch only, refit the **existing** two modeled almond eyes, convex irises and pupils together: eye half-width 0.106 → **0.088** of fitted head width, eye center offset 0.225 → **0.195**, iris 0.044 → **0.036**, pupil 0.027 → **0.022**. Upper/lower lids and brows are refitted to the smaller openings, catchlights reduced, smile span 0.47 → **0.40**, curve and lip thickness softened, and cyan/white facial materials made less toy-like.

This modifies **existing procedural geometry and materials**, not the CC0 source GLB, imported 65-bone Skin, original GPU skinning, three-question launch, touch, four worlds, bosses, four abilities, collisions, old releases or Unity archive. No additional meshes, textures or dependencies. The actual four-weight skinned face remains installed by `rider_external_skinned_portrait.gd`.

## Regression and visual gate

- `rider_external_headgear_test.gd` now rejects the old oversized eye half-width and broad grin, enforces symmetrical tighter eye spacing, preserves convex layered iris/pupil proportions and original 65-bone Skin.
- Existing expression/blink/gaze, weighted-face, pose, Godot webexport and landscape-capture tests must pass on the **final code commit** before any quality claim.
- Inspect actual paired 1280×720 and 1170×540 front/profile/chase renders for eye occlusion, iris/eyelid alignment, grin, helmet/hair overlaps. Pixel differences alone are not aesthetic approval.
- **Pending CI and image review at commit creation.** No merge, no release, no reserved V124; PR #111 remains DRAFT / VISUAL HOLD. A future merge must update against then-current main and use the next unoccupied immutable Skyway number.
- Real iPhone Safari FPS, clipping and complete touch playthrough after three English questions remain open.
