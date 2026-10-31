# LearnQuest V133 candidate — Aurora aerial slipstream

31.10.2026, stable-track development on top of immutable V132.

## Player-visible change
The four moving Aurora wind tunnels now have elevated glowing 3D interception rings. A player can steer into a wind lane as before, or **time the existing jump** at the tunnel for +20 XP and +0.75s extra Turbo. Four airborne interceptions in one round grant a one-time +50 XP mastery bonus (330 total tunnel XP), shown in the landscape HUD and results. Ground interceptions still pay their exact original rewards; misses remain harmless. The three vocabulary tasks, four worlds, four power-ups, touch input, boss fights and existing stars are unchanged. No new licensed assets or colliders.

## Release gate (do not bypass)
- [x] Godot PR validation: [run 41209360051](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41209360051) succeeded; import, existing gameplay/skin regressions, updated Aurora regression, web export, actual landscape capture.
- [x] Inspected original Aurora 1280x720 and 1170x540 chase/oblique frames against V132 (same capture). The elevated ring is visible (649/768 changed pixels at 1280x720 chase/oblique, threshold >20/255); the HUD string is covered by the integration test, but no real iPhone safe-area/FPS approval.
- [ ] Archive-protection CI successful (release workflow wiring updated to unused V133; awaiting run).
- [ ] Only after both pass, update `VERSION_LABEL` and Pages workflow from V132 to next *unused* immutable version, merge, and verify main Godot, archive and Pages deployment with exact build SHA + HTTP 200 for all five files.
- [ ] Real iPhone FPS/clipping and three-quiz-to-full-round touch playthrough remain manual/unverified.

Experimental 65-bone character remains in separate DRAFT PR #111; no merge or release-number reservation.

## Smartphone landscape HUD QA
The mobile HUD splits Aurora jump, wind, streak and aerial counters across two compact rows instead of adding another long line. A Godot regression checks each row is at most 48 characters in the narrow layout; physical Safari safe areas still require device testing.

## CI correction
Release-version wiring moved the HUD label from V132 to V133, exposing four intentional V132 assertions in `godot/smoke_test.gd`. The PR checks [41209623040](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41209623040) failed on this version-label mismatch (not on Aurora gameplay). Updated all four expectations to V133; rerun full PR CI before merge. Archive-preservation PR check [41209623030](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41209623030) already succeeded.
