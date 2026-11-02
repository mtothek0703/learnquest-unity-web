# 2026-11-02 – V153 candidate: 3D skill progression for alternating near-miss surfing

## Why
V151's alternating three-barrier challenge rewarded a correct 3/3 streak but its 1/3 and 2/3 hints vanished quickly from the mobile landscape HUD. During a fast chase the player could not see how many valid touch lane dodges remained.

## Implemented (stable-track candidate, no PR #111 dependency)
- Three lightweight, genuinely triangulated cyan **3D arc sectors** are positioned behind the existing hoverboard, visible in the chase view. Exactly one appears after a qualifying first dodge, two after a valid opposite-side lane switch, and none while the final full 3D shockwave plays. No new asset, collision, input, camera, or paid service.
- Invalid repeats keep the count at 1; barrier/boss damage clears the arcs. Jump/shield/turbo/attack exclusions, once-per-race XP/Turbo reward, three English tasks and four worlds are unchanged.
- Added assertions to the actual hazard-crossing test and four stages per resolution to OpenGL visual QA (8 original 16:9 / wide-landscape frames).
- Updated PR/release CI to demand eight rendered frames and reserved **new** immutable `skyway-v153/` only if full CI, web export, archive protection, Pages and exact build SHA pass.

## Gates
- [ ] Current-head Godot gameplay/visual CI and Webexport green.
- [ ] Actual identical-camera PNGs show 1/3 and 2/3 arcs and 3/3 shockwave in both landscape ratios.
- [ ] Main merge, main CI, archive gate and Pages deployment succeed.
- [ ] New V153 build files HTTP 200 and build.txt equals main commit.
- [ ] Real iPhone Safari FPS/clipping and full touch round (manual; do not claim automated).

The independent 65-bone CC0 PR #111 remains DRAFT/VISUAL HOLD. No historical Skyway or Unity archive is modified.

## First real candidate CI and visual review
- [Godot PR CI 41414063467](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41414063467) SUCCESS on candidate commit `5bbbe853d29f0e2e6de1a63e7b3beae3ded544f0`, including gameplay, webexport, archive-related PR checks and all eight OpenGL images.
- [Original eight-frame artifact 13126208743](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41414063467/artifacts/13126208743) downloaded and manually inspected: 1280x720 board crop shows first cyan rear arc at 1/3, two arcs at 2/3 and the expanding full 3D shockwave at 3/3. Full-frame pixels changed from the identical baseline (max RGB difference >35): 1,303 (one), 3,791 (two), 13,896 (after). These are *visibility* measurements, not evidence of high-end graphics or real-device FPS.
- Follow-up cleanup: hide unfinished arc progress upon entering results; added a gameplay regression for the interrupted-run case. **Re-run CI on the follow-up commit before any merge.**
