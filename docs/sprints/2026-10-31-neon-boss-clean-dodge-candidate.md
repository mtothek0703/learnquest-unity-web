# LearnQuest 3D — Neon boss clean-dodge candidate (31.10.2026)

## Mandatory policy and separation
Read both `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before editing. Last verified stable release is **Skyway V134** (main `e92e17f5b624ca75b8a6f4dd233ddd013e4afb11`, [Godot](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41214483562), [archive](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41214483490), [Pages](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41214483525)). Experimental 65-bone PR #111 remains DRAFT and is not involved.

## Spur A — playable candidate in DRAFT PR #123
- Neon Conductor's existing three-beat lane sweep now offers an optional **clean steering dodge** challenge. Three consecutively avoided warned lanes award **+60 XP** and **2 seconds of existing Turbo**, exactly once per round. A real hit resets the streak; a shield or jump still saves the rider but cannot substitute for safe-lane steering.
- Compact boss HUD shows `AUSWEICH x/3`, and a completed round recognizes `NEON-TANZ` in the result. No new touch buttons, collisions, assets, costs, vocabulary interruptions or other-world rule changes.
- Existing `neon_conductor_test.gd` expanded to cover actual three-beat safe-lane choices, shield exclusion, no repeat farming, exact XP/Turbo, HUD, result and reset.
- **Release not staged:** version string deliberately remains V134 on the candidate branch, which is not a published build. Branch and PR title do not reserve V135. After tests, visual QA and archive checks, select the next unused version, update all release/smoke expectations, and only then merge and verify main/Pages build revision. Never overwrite old URLs.

## Current acceptance gates
- [ ] Candidate Godot PR CI on code/test head `ab3475cf` must finish green; headless gameplay, export and 16:9/19.5:9 render images must be reviewed.
- [ ] Release candidate must have version/path checks and archive protection passing.
- [ ] Main Godot/Pages and five-file HTTP 200/build.txt SHA checks required after merge; no release claim before that.
- [ ] Real iPhone Safari FPS/clipping and complete touch round after three English questions still unverified.
- [ ] Pages artifact >1 GB remains a known infrastructure risk.
