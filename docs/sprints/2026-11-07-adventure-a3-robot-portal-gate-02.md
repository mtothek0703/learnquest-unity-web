# Adventure A3 – Robot gate for Neon City portal (2026-11-07 02:18 CET)

## Identity and baseline
- Primary GitHub account: mtothek0703 / michael_kohler1@yahoo.de, repo mtothek0703/learnquest-unity-web, existing DRAFT PR #157 branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`.
- Read all four mandatory policy/roadmap files on main before edits.
- Before edits: main `3117869390c6f3dff6409bfde1f64c2d184b0853` (comparison base); branch head `0dabb26cdc7f21edf84ca11c96d53834d928e806`; behind main by 1 commit, ahead by 29.
- PR-head Godot workflow run 42317014646 completed successfully **for the previous head only**.

## Change
- The exit portal now requires three crystals, two switches **and** defeat of the training robot. Previously players could bypass combat.
- Mission HUD shows "Roboter besiegen" after completing five objectives until the robot is defeated, then "PORTAL BEREIT".
- Existing attack interaction refreshes mission HUD on robot defeat. No runner code, archives, legacy builds, or external assets touched.
- Extended the existing bridge regression test: completed collection goals alone cannot return even while standing at portal; defeating robot enables return and one-time 75 XP.

## Acceptance criteria
1. Five objectives without robot defeat leave player in adventure phase, even at portal.
2. Two in-range robot attacks disable robot; return from portal resumes race.
3. Runner XP remains single-award; power/lives/distance preserved; existing training and touch controls unchanged.
4. Godot import, headless test, WebGL export, real 16:9/19.5:9 renders, iPhone Safari QA and archival release gates required before merge/release.

## Actual verification
- Reviewed the prior successful Godot PR workflow run 42317014646 for commit `0dabb26`.
- Source-level review and targeted code/test changes committed: gameplay `1f2ca1c2ee04365c91ecb23b84b310afe2fb314b`; integration test `e386fc6ef093a990d7f575e8c7171fefb59b611e`.
- **Not yet executed on new head:** Godot headless test, import, export, real render and device QA. Do not count previous CI as proof for these commits.
- DRAFT retained; no merge or Skyway release.

## Next
Inspect the new PR CI and fix failures. Then improve guard/dodge combat feedback and validate landscape touch layout before considering a stable build.
