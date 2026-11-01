# 2026-11-01 — Track A candidate: V145 landscape chase camera composition

## Preflight
- Mandatory `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` read from `main` this run.
- Verified Primary GitHub login `mtothek0703`, repository `mtothek0703/learnquest-unity-web` (ID `1427565370`), base `main` commit `c9ca7b4854916aef72852fc82d6863f2d26de407`.
- Last verified immutable stable release **V144**, Pages workflow `41306881518`. DRAFT PR #111 remains separate, unapproved and does not reserve V124.
- The actual V144 original QA images show a small central game environment against large dark margins; next priority is an actual chase camera composition improvement rather than more tiny decorations.

## Candidate changes
- Smartphone landscape race camera is closer to the rider and road (9.0 -> 7.55 units), with tighter 64 -> 58 degree FOV. Turbo remains a distinct pullback (10.1 -> 8.65 units, 74 -> 70 degree FOV).
- A slightly lower camera and focus preserve visibility of the track and upper racer. Desktop 1920x1080, all menu/quiz/results cameras, physics, lane widths, gestures, bosses, abilities, vocabulary and archive are unchanged.
- Separate Godot headless test checks three phone ratios, desktop preservation, rider visibility in all three lanes and Turbo.
- New OpenGL QA renders the **actual main game scene and chase camera**, not isolated scenery, with original V144 vs candidate framing at 1280x720 and 1170x540, center/right-lane/Turbo. Twelve PNGs and sampled image-difference gate are uploaded for real inspection.

## Release gate — candidate is NOT a published V145
- [ ] PR Godot CI import, smoke/functional regression, camera test, Web export and actual image QA pass.
- [ ] PR archive protection passes.
- [ ] Download and visually inspect actual twelve images for rider/road size, clipping and HUD overlap at both phone ratios. Pixel differences alone are not approval.
- [ ] Confirm V145 unused and main current; only then set V145 label and release workflow, merge, verify main CI, archive, Pages, HTTP 200 for five files and exact `build.txt` SHA.
- [ ] Physical iPhone Safari FPS, all-pose clipping and complete touch-controlled round still require a real device.
- [ ] Existing Pages artifact >1 GB warning is still unresolved. Do not delete historical Skyway directories or Unity archive.

## Track B
- PR #111 (CC0 65-bone character) stays DRAFT until meaningful full-figure visual QA. It does not block independent camera feature releases.

## Actual QA, correction and release candidate gate
- First [full PR Godot CI run 41313070121](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41313070121) passed import, gameplay, Web export and 12 original Godot gameplay camera renders. Actual 1280x720 chase image inspection showed substantially larger racer, board, road and buildings: center 491,597 pixels (53.34%) changed with max RGB-channel difference >25; right lane 457,961 (49.69%); Turbo 352,598 (38.26%).
- **Important real visual defect found before release:** at 1170x540 the initial 16:9 zoom moved the board partly behind the lower touch buttons. No release was made.
- Corrected the camera to use two phone-landscape safe areas: 1280x720 keeps the more cinematic 7.55-unit / 58-degree chase view; short screens below 620px height use a conservative 8.5-unit / 63-degree view (Turbo 9.7 / 73) to preserve the mission HUD and two rows of controls. Desktop remains exactly unchanged.
- [Corrected PR Godot CI 41313459496](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41313459496) **completed/success** before release wiring changes; full Godot smoke/landscape regression, Web export, all existing 3D QA and 12 original game frames passed.
- Downloaded and visually inspected corrected 1170x540 center, right-lane and Turbo before/after. Touch buttons remain legible and usable; rider and board remain visible in the central play corridor with no *new* obvious control overlap. Preexisting HUD/hair overlap on short screens remains a separate UI improvement opportunity.
- Corrected 1170x540 image differences (>25 max RGB channel): center 110,631 pixels (17.51%); right lane 109,201 (17.28%); Turbo 74,644 (11.81%). These are camera/world pixels, **not** FPS or a full physical-device visual approval.
- Release wiring now targets the next immutable `skyway-v145/` only, with the original V144 archived and the V145 camera regression and actual gameplay render test included in release CI.
- [ ] Final candidate CI after version label/workflow change and PR archive protection.
- [ ] Merge only after both are green, then verify main CI, Pages deployment, five HTTP 200 files and exact build SHA.
