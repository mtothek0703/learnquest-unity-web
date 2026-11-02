# 2026-11-02 – Real 65-bone relaxed forearm stance (DRAFT trial)

## Why
Actual 1280×720 and 1170×540 front/chase source-only and complete-hero renders of the prior coherent shoulder taper still show the hands unnaturally close to the shoulders. A more natural surfing silhouette should extend the genuine imported skinned forearms beside the torso, rather than hide the wrists behind large weighted sleeve shells.

## Change
- Keep both original 65-bone upper-arm, elbow, hand and finger joints; the original Skin and all four weights remain untouched.
- Reduce neutral elbow flex from 0.73 rad to 0.28 rad while retaining symmetric steer/boost/jump response and wrist articulation. Reduce inside-turn extra elbow flex from 0.24 to 0.16 rad.
- Update original-rest-relative bilateral pose regression, leaving refresh-rate invariance, animation recovery, board physics and touch controls unchanged.

## Gate
- [x] Full [Godot CI 41366942407](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41366942407) completed/success for code commit 79d29a65, including 65-bone pose tests, web export, 12 bilateral landscape pose frames and 108 complete layered captures.
- [x] Compared all 108 original Godot before/after PNGs against preceding b9a682f7 draft. At max RGB delta >25 in 1280×720: complete chase 23,251 px (2.523%), complete front 18,124 px (1.967%), isolated source chase 12,177 px (1.321%). Hands sit lower in the chase view, but the entire figure is still not convincingly high-quality. This does NOT certify clipping-free motion or iPhone performance.
- [ ] Real iPhone Safari FPS, all-pose clipping and complete three-question touch round remain unverified. **PR #111 stays DRAFT/VISUAL HOLD; no merge or release number.**
