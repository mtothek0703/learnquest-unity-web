# Adventure A4 – contextual mobile portal interaction (2026-11-07 12:14 CET)

## Ausgangslage
Primary GitHub mtothek0703 / michael_kohler1@yahoo.de, repository mtothek0703/learnquest-unity-web, DRAFT PR #157, main 3117869390c6f3dff6409bfde1f64c2d184b0853. Four mandatory main documents reviewed. PR head before change 874b032edfb6539b70008fea45b6e82be2429b60, 60 ahead / 1 behind main. Existing PR CI run 42363451176 concluded success for that previous head.

## Änderung
Mobile INTERAKTION previously collected crystals/activated switches only, while desktop E also remounted at the completed exit. Both now use _contextual_interact(): try nearby objective, otherwise request exit. Exit still requires five objectives, robot defeat and portal proximity; separate AUFSTEIGEN remains available. Runner touch gestures and legacy files untouched.

## Akzeptanzkriterien und Tests
- Locked exit rejects E and mobile remount; three crystals, two switches and robot defeat remain required.
- Real mobile INTERAKTION button pressed signal returns to the same race at unlocked nearby exit, with XP and progress preserved and no duplicate reward.
- Existing Godot headless bridge test updated to exercise button signal, plus keyboard E locked gate.
- Commits: cbb5ff5 (gameplay), 6653735 (test), e8def2a (actual button signal).
- Actually executed this run: repository/PR/main comparison and prior CI status read; code changes committed. **New headless Godot execution, web export, real 16:9/19.5:9 render and iPhone Safari QA not yet verified.** PR remains DRAFT; no merge/release.

## Next
Check CI for the new head; fix failures first. Then prioritize existing licensed rider visual integration and genuine mobile landscape screenshots, without touching PR #111 or archived Skyway versions.
