# LearnQuest 3D – A3/A4 robot telegraph opacity (2026-11-09, 17:18 CET)

## Baseline and safety
- Authenticated GitHub Primary: mtothek0703 (michael_kohler1@yahoo.de); repository mtothek0703/learnquest-unity-web; existing DRAFT PR #157, branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`.
- Read all four required documents from main before editing. Main at `46e899a84c500243274badf71255bb2afec3186b`.
- Previous PR head `fc56cf69cc4378e08a6d773f33aad099bdff8cc2`; GitHub Godot PR validation run 42643620105 reported success on that prior head only.

## Gameplay change
- The existing robot danger-zone cylinder now increases its translucent red opacity from 0.24 toward 0.62 as the telegraphed strike approaches. The 3D range, pulse size, attack timing and combat mechanics are unchanged.
- Warning completion, robot defeat and mission retry reset opacity to 0.24 and hide the zone. No changes to the runner, quiz, other worlds, existing assets or immutable releases.

## Acceptance and verification
- Criteria: stronger in-world warning near impact; warning radius never grows beyond actual strike range; reset hides ring and restores default alpha; existing bridge/regression tests stay green.
- Added a real-scene assertion in `res://adventure/adventure_bridge_test.gd` checking opacity increase and reset.
- Actually executed this run: GitHub read/identity/PR/branch checks, source inspection and successful GitHub commits. **No local Godot import, headless gameplay execution, WebGL export, 16:9/19.5:9 screenshots, physical iPhone Safari test or Pages HTTP checks were run.** Previous CI success does not validate this new head.
- Commits: gameplay `f9eb0daf5b9dff9d1b621b04eab22550b254f1c9`; regression `dc6e5d87f29cacc91b156c0322d21f70a009da1b`. DRAFT PR #157 remains unmerged. No release.

## Next
Inspect Godot PR validation for this head, fix failures before any further changes, then obtain genuine landscape render evidence and iPhone interaction QA. Keep experimental character PR #111 independent.
