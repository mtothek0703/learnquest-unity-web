# LearnQuest – 05.11.2026: smartphone steering-bank candidate (Track A)

## Verified baseline and scope
- Repository: `mtothek0703/learnquest-unity-web` with verified Primary account `mtothek0703`.
- Clean branch based directly on main `6077903f66d440243353058de2f32a182ec12a53` (stable published V154). Do not merge the stale DRAFT PR #133 camera implementation; its branch was 33 commits behind main and current main already has `_race_camera_targets()` with distinct 16:9 and compact 19.5:9 modes.
- The existing 65-bone character in DRAFT PR #111 remains untouched and unapproved.

## Concrete change
- The real 3D chase camera banks its horizon by **at most 1.4 degrees** when the rider steers left/right on mobile landscape. Center lane is exactly level. Rider position already eases between lanes; bank consequently animates with steering.
- Desktop and portrait menus are unaffected; the bank is applied only during the race. Camera distances, FOV, touch gestures, geometry, three English tasks, world layouts, power-up balance, boss logic and archived releases are not changed.
- The existing `landscape_chase_camera_test.gd` now validates all three phone landscape ratios, mirrored left/right limits, center neutral, desktop/portrait exclusion and actual camera-basis rotation in addition to its existing visibility, lane, Turbo and three-task assertions.

## Acceptance gate – not yet a release
- [x] Isolated feature code and regression test committed to a fresh branch from current main.
- [ ] Godot import, all headless gameplay tests and web export on this exact candidate commit green.
- [ ] Real 16:9 and 19.5:9 before/after graphics reviewed. Ensure the mild roll does not cover HUD, rider or hoverboard in left/right lanes, Turbo or jumps.
- [ ] Historical Skyway/Unity archive check and exact immutable Pages deployment only **after** all previous gates pass.
- [ ] Manual iPhone landscape touch playthrough/FPS and clipping remain unknown (cannot be inferred from CI).

This is an experimental V155 candidate with **no version number reserved and no stable release yet**. The successful PR #133 CI on head `6dd0adca` does not test this new main-synced change.
