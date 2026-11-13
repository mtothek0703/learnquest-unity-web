# 2026-11-07 06 – A3 robot attack cooldown

## Verified before change
- GitHub Primary account mtothek0703 / michael_kohler1@yahoo.de, repository mtothek0703/learnquest-unity-web, existing DRAFT PR #157 on feature/adventure-a1-walkable-neon-testbed-20261106-19; no other branch or account used.
- Main SHA b9010294fea1728212bea50d413c465d55706dd2, PR head 0c1d1280498e38650be55602c70bd1b69ba3b067 before modifications.
- Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md and docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md on main.
- Godot PR validation for previous head 0c1d128: successful run 42337462155. This is **not** evidence for the new changes.

## Implemented
- Robot attack now has a 0.65-second cooldown, preventing two immediate taps from defeating it without a combat interval.
- Timer advances during physics frames; mission reset clears it.
- Integration test asserts rapid repeat is rejected, reset clears cooldown and a subsequent attack is accepted. Existing robot/portal flow tests adjusted for the timer.
- Code commits: b5c07156ee91b1a8ed0ca92f4682783669809d41 and 6af94a96f5d8e476d1425533aaee097419ae4519.

## Acceptance and tests
- [x] Static code review of changes and test expectations.
- [x] Previous head CI successful (42337462155); does not cover this sprint.
- [ ] New head Godot import/headless test and webexport CI result pending.
- [ ] Actual 16:9/19.5:9 render and iPhone Safari QA.
- [ ] No merge, no immutable Skyway release, no changes to archived builds or Unity.

## Next
Check CI of updated PR, fix failures, then improve walk-mode visual hero and real landscape UI validation without touching Runner gestures.
