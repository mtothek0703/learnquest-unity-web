# 2026-11-06 19:14 CET – Adventure A1: independently launchable Neon City walking testbed

## Basis and scope
Primary account mtothek0703 / michael_kohler1@yahoo.de verified using authenticated profile. Target repository mtothek0703/learnquest-unity-web, branch `feature/adventure-a1-walkable-neon-testbed-20261106-19` created from main `b9010294fea1728212bea50d413c465d55706dd2`. Read on main before changes: `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md`. Main has maintenance merges #155/#156 since the previous adventure reports; old main SHA 0e012466 is not current.

## Implemented
- `godot/adventure/neon_walk_player.gd`: independent CharacterBody3D walking, gravity, jump, floor collision via move_and_slide, fall respawn, focus-loss input cleanup.
- `godot/adventure/neon_walk_testbed.gd`: procedural collidable ground and two elevated platforms, separate third-person follow camera, left-side mobile directional buttons, right-side jump.
- `godot/adventure/neon_walk_testbed.tscn`: directly openable standalone test scene.
- Runner `world.gd`, three-question gate, four worlds, boss mechanics, four powers, Unity archive, immutable Skyway builds and experimental character PR #111 untouched.

## Acceptance criteria and verification
- [x] New test scene and controller source committed on a fresh main-based branch.
- [ ] Godot 4.4.1 import and headless launch; no Godot executable available in this runner environment (`command -v godot || command -v godot4` returned no path).
- [ ] Actual 3D movement, grounded jump/landing, collisions and fall respawn visually confirmed in Godot.
- [ ] Touch controls and camera tested on real iPhone Safari at 16:9 and 19.5:9.
- [ ] Web export, archival safety, Pages HTTP checks; intentionally no release.
- [ ] Existing licensed rider asset integrated (temporary capsule mesh used only in standalone testbed).
- [ ] Runner-to-arena-to-runner integration; this testbed is not yet a complete gameplay loop.

## Next
Run Godot import/headless tests in CI, fix any parser/runtime errors first, then replace the capsule visual with the existing licensed rider and integrate the existing A2 mission and runner transitions without touching runner gestures. Keep character PR #111 and camera drafts #133/#144 isolated.
