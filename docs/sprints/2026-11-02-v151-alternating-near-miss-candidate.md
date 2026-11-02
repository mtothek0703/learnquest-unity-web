# 2026-11-02 – Skyway V151 candidate: alternating near-miss surfing (stable track A)

## Real playable feature
After the mandatory three English questions, a full race now awards an optional **HAARSCHARF** skill challenge: narrowly pass three *actual* barrier crossings in alternating left/right directions **and change the rider's lane between each pass** at ground height. A successful sequence grants one capped **+70 XP**, **1.75 s Turbo** and a visible, horizontally expanding cyan **3D hoverboard shockwave**. The first and second clean passes give German lane-change and side-switch guidance. A player parked in the center lane cannot earn the mastery from randomly alternating barriers. The challenge works with existing touch lane steering, across all four worlds; no new gesture, collision object or paid asset.

Jumping, active shield, Turbo, attack, temporary damage invulnerability and destroyed hazards cannot farm the reward. A real barrier/boss hit breaks an unfinished chain. The sequence resets between rounds, appears in results only if achieved, and does not alter the three mandatory vocabulary tasks, four power-ups, boss fights or mission stars.

## Changes
- `godot/world.gd`: event handling at real hazard Z crossings, alternating-side streak, exclusion gates, result text and one recycled 3D torus.
- `godot/alternating_near_miss_test.gd`: actual obstacles, passive center-lane RNG rejection, real lane changes, same-side reset, jump/shield exclusion, damage, one-time reward, results and replay after three questions.
- `godot/near_miss_visual_capture_test.gd`: four real 1280×720 and 1170×540 OpenGL before/after frames; compare central gameplay pixels instead of HUD text.
- Both Godot PR and release workflows execute gameplay and visual QA. The release workflow refuses an existing `skyway-v151/` and targets only a new immutable URL. Existing archives remain read-only.
- HUD smoke assertions updated to `V151` rather than accepting a stale label.

## Release gate
- [ ] Full current-head Godot CI and web export successful.
- [ ] Four actual phone-landscape render frames and nontrivial board VFX pixel change verified.
- [ ] Main merge, historical archive guard and Pages deploy successful.
- [ ] Five immutable `skyway-v151/` files return HTTP 200 and `build.txt` equals the released main SHA.
- [ ] Real iPhone Safari FPS and uninterrupted touchscreen playthrough (manual; do not claim automated).

**Status:** Candidate only; do not announce or publish V151 before every automated release gate is verified. The separate 65-bone CC0 PR #111 remains DRAFT and does not block this independent stable gameplay feature.
