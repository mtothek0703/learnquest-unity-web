# LearnQuest V133 candidate — Aurora aerial slipstream

31.10.2026, stable-track development on top of immutable V132.

## Player-visible change
The four moving Aurora wind tunnels now have elevated glowing 3D interception rings. A player can steer into a wind lane as before, or **time the existing jump** at the tunnel for +20 XP and +0.75s extra Turbo. Four airborne interceptions in one round grant a one-time +50 XP mastery bonus (330 total tunnel XP), shown in the landscape HUD and results. Ground interceptions still pay their exact original rewards; misses remain harmless. The three vocabulary tasks, four worlds, four power-ups, touch input, boss fights and existing stars are unchanged. No new licensed assets or colliders.

## Release gate (do not bypass)
- [ ] Godot PR validation: import, existing gameplay/skin regressions, updated Aurora regression, web export, actual 16:9 capture.
- [ ] Inspect Aurora 1280x720 and 19.5:9 QA frames for elevated-ring visibility and HUD clipping.
- [ ] Archive-protection CI successful.
- [ ] Only after both pass, update `VERSION_LABEL` and Pages workflow from V132 to next *unused* immutable version, merge, and verify main Godot, archive and Pages deployment with exact build SHA + HTTP 200 for all five files.
- [ ] Real iPhone FPS/clipping and three-quiz-to-full-round touch playthrough remain manual/unverified.

Experimental 65-bone character remains in separate DRAFT PR #111; no merge or release-number reservation.
