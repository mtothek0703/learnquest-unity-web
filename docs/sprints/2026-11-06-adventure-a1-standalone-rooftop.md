# Adventure A1 – standalone Neon rooftop – 2026-11-06 18:10 CET

## Base and account
Primary GitHub `mtothek0703` / `michael_kohler1@yahoo.de`; repository `mtothek0703/learnquest-unity-web`; base main `0e01246620d33a9afcbb617152748adac4402993`. Read `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md` on main before writing.

## Implementation
New standalone `godot/adventure/neon_rooftop.tscn` and `neon_rooftop.gd`: real `CharacterBody3D` with capsule collision, static solid rooftop and raised platforms, gravity, WASD/arrows, Space jumping, left-side drag movement and right-side touch jumping, follow camera, fall respawn, focus-loss touch reset. No changes to runner, training, bosses, powers, worlds, archived builds or Unity. Uses temporary procedural capsule as A1 collision prototype; licensed existing character still needs integration before release.

## Acceptance criteria
- Scene loads in Godot 4.4.1, grounded walking and jumping are physically playable.
- Mobile touch input is isolated from runner gestures.
- Rooftop collision and fall respawn function; touch focus loss releases joystick.
- Existing three-quiz runner unaffected (no runner files changed).

## Tests actually executed
- GitHub file creation/commit confirmed.
- Local binary availability: `command -v godot || command -v godot4` -> GODOT_UNAVAILABLE.
- `godot --headless --path godot --script res://adventure/neon_rooftop_test.gd`: NOT RUN; test committed but unverified.
- Godot import, browser export, 16:9/19.5:9 renders, real iPhone-Safari and Pages HTTP checks: NOT RUN.

## Status and next work
DRAFT only, not merged, not released. Execute regression and fix runtime/parser issues before integrating the existing rider mesh and runner race pause/portal. The A1 scene is a standalone playable-intent prototype, not evidence of a verified playable vertical slice. No release number reserved.
