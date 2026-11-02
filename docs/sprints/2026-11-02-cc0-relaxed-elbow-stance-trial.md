# 2026-11-02 – Real 65-bone relaxed forearm stance (DRAFT trial)

## Why
Actual 1280×720 and 1170×540 front/chase source-only and complete-hero renders of the prior coherent shoulder taper still show the hands unnaturally close to the shoulders. A more natural surfing silhouette should extend the genuine imported skinned forearms beside the torso, rather than hide the wrists behind large weighted sleeve shells.

## Change
- Keep both original 65-bone upper-arm, elbow, hand and finger joints; the original Skin and all four weights remain untouched.
- Reduce neutral elbow flex from 0.73 rad to 0.28 rad while retaining symmetric steer/boost/jump response and wrist articulation. Reduce inside-turn extra elbow flex from 0.24 to 0.16 rad.
- Update original-rest-relative bilateral pose regression, leaving refresh-rate invariance, animation recovery, board physics and touch controls unchanged.

## Gate
- [ ] Full Godot CI, 65-bone pose tests, web export and 12 genuine bilateral smartphone landscape pose frames pass.
- [ ] Visually compare same-camera front/chase full-rider and source-only frames against preceding b9a682f7 draft. Keep only if hands visibly sit more naturally, without new shoulder, chest or board clipping.
- [ ] Real iPhone Safari FPS, all-pose clipping and complete three-question touch round remain unverified. **PR #111 stays DRAFT/VISUAL HOLD; no merge or release number.**
