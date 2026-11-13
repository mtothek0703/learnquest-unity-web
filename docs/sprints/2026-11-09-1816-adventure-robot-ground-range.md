# LearnQuest Adventure Sprint – 2026-11-09 18:16 Europe/Berlin

## Account, branch, and baseline
- Verified GitHub Primary `mtothek0703` / `michael_kohler1@yahoo.de`, repository `mtothek0703/learnquest-unity-web`, target DRAFT PR #157 (`feature/adventure-a1-walkable-neon-testbed-20261106-19`).
- Read on `main`: `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md`.
- PR #157 base SHA reported by GitHub: `b9010294fea1728212bea50d413c465d55706dd2`; previous PR head `7cadacc81acc72da9e0c9a9f9081897845759eb6`.
- Prior head Godot PR validation #42653693234: completed/success. This does **not** validate this sprint's new commits.

## Gameplay change and acceptance criteria
The A3 robot's ground danger decal is a horizontal circle, but previously warning activation, attacks, damage and HUD distance used 3D Euclidean distance. On elevated platforms that made the visual warning disagree with combat reach. Added `_robot_ground_distance()` to compute X/Z distance, used consistently in the robot's warning activation, attack, damage/guard feedback, and HUD. Runner touch and mission state untouched.

Acceptance: a hero 1 m away horizontally remains in range even 5 m above the robot; 4 m horizontally is out of range; warning radius and combat range use the same ground-plane metric. Regression assertions added to `res://adventure/adventure_bridge_test.gd`.

## Changes and evidence
- Gameplay commit: `81c2f21af1703c34ff65b7d3f838b337617e211f`.
- Regression test commit: `a9a6d6e93e0933a9f2b84f21cac2e085af27e7c5`.
- Tests **actually executed for this new head**: none yet. GitHub PR CI must rerun; Godot import/headless gameplay, webexport, real screenshots and iPhone Safari remain unverified for this change.
- PR #160 Blender portal is separate DRAFT, head `751a5c894beb1ec4316134ba255c42a9b521fe76`; Godot PR validation #42661474172 completed/success. Artifact `learnquest-blender-race-before-after` exists (2,744,015 bytes), but images have not been visually reviewed in this sprint. No merge or live Blender portal release.
- No release, main merge, archive edit, Unity edit or immutable Skyway URL change.

## Next
Review the fresh PR #157 CI; inspect Blender portal before/after screenshots in both landscape sizes before any PR #160 merge; conduct real iPhone Safari QA separately. Keep both PRs DRAFT until release gates are evidenced.
