# 2026-11-01 — CC0 skinned hair counter-carve inertia (experimental only)

## Scope and quality gate
- Stable main was checked at `2f90449c` (Skyway V139); its latest Godot, Pages, historical-preservation and health-check Actions runs were all reported successful. **No new stable release is claimed or attempted:** this change belongs exclusively to DRAFT PR #111.
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` on main before work. Verified the connected primary account `mtothek0703` and repository ID `1427565370`; did not access the Grees Klimatechnik account.
- Previous experiment: the five true four-weight Head/Neck/Spine rear locks gained phase-offset flutter, but still followed steering immediately. This step adds **critically damped, frame-rate-independent turn inertia** and a bounded opposite-direction tip sweep during rapid left/right reversal. The shader still uses existing GPU-skinned hair vertices; scalp displacement remains zero by construction (`flutter=0` at root). No extra mesh, drawcall, collision, touch/quiz/gameplay change or foreign asset.
- Added explicit 30-versus-60 FPS convergence and direction-reversal regression to the existing real-Skin hair test; verifies the shader uniform is propagated to all six actual skinned volumes. No claim of device FPS or visual quality approval.

## Validation status
- Code and regression committed on the experimental branch; **Godot CI, web export, archive protection and render QA must be checked against the new commit** before calling this validated. A visual before/after using matched 1280x720 and 1170x540 real Godot frames remains necessary to decide whether the improvement is noticeable.
- PR #111 stays DRAFT / VISUAL HOLD. The title V124 reserves no release number. When/if it passes the visual gate, update against then-current main and choose the next unused immutable Skyway number. Keep V139 and every older Skyway URL plus the Unity archive unchanged.
- Open: cohesive high-end rider/hoverboard silhouette, manual full-pose clipping, real iPhone Safari FPS, and a complete uninterrupted touch round after the three English questions.
