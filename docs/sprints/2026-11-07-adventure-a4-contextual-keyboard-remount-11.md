# LearnQuest Adventure – Sprint 2026-11-07 11:18 CET – contextual desktop remount

## Verification before edits
- Primary GitHub account: mtothek0703 / michael_kohler1@yahoo.de; repository mtothek0703/learnquest-unity-web; existing DRAFT PR #157, branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`.
- Read on main: `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md`.
- PR base SHA `b9010294fea1728212bea50d413c465d55706dd2`; main comparison SHA `3117869390c6f3dff6409bfde1f64c2d184b0853`; branch diverged, 57 ahead / 1 behind before edits. No merge or main modification.
- Last pre-edit PR head `7c95e5158878c0e152a8eb7b238880cec6130054`: GitHub Actions Godot PR validation run 42359019771 completed success. This does **not** validate the new changes.

## Playable change
Desktop `E` now first tries the normal nearby crystal/switch interaction. If no target is interactable, it requests remount; the existing `_request_return` gate still requires all three crystals, two switches, defeated robot and proximity to the exit portal. The mobile AUFSTEIGEN button is unchanged; runner touch gestures and existing releases untouched.

## Acceptance criteria
1. E near an uncollected mission target collects/activates it without remounting.
2. E at the locked portal never returns to the runner.
3. E at the unlocked portal returns to the same race preserving XP, power, lives and distance.
4. Default-off runner, quiz and original touch path stay unchanged.

## Tests / evidence
- Code change commit: `2bb58889863d1888eed44a4967e2906170a360e4`.
- Bridge regression updated in commit: `967b4e47e0c2a817232bf8e59dafcccbb4ef9657`; its final return path now dispatches a real `InputEventKey` E through `_unhandled_key_input`, and checks the existing race-state and reward invariants.
- Test source edited and committed; **no local Godot import, headless test, webexport, rendered screenshots, iPhone QA or new CI success confirmed for these commits at documentation time**.
- PR #157 remains DRAFT; no merge or immutable Skyway release.

## Next
Check new PR CI and fix failures first. Then integrate the existing licensed character into the walk mode without importing PR #111's experimental rig; capture real 16:9/19.5:9 Godot renders and test on iPhone Safari before release.
