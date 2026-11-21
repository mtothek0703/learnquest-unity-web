# LearnQuest Adventure Sprint – 2026-11-08 17:15 CET

## Scope
Continued existing DRAFT PR #157, no new branch, no main/runner/archive changes. Primary GitHub link: mtothek0703 / michael_kohler1@yahoo.de. Repo mtothek0703/learnquest-unity-web; main base SHA b9010294fea1728212bea50d413c465d55706dd2; prior PR head d0b2ca297109445721bde9edc084fbd0927ea516. Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md and docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md from main.

## Implemented
- In Neon City after all three crystals and two switches are collected, while robot remains active, show the approximate 3D distance to the robot and the attack/guard controls in the on-foot mission HUD.
- Added a bridge regression assertion for the robot-distance cue in the mission-complete/robot-active state.
- Gameplay commit 4cd4743fd7ccd21f3f78bfbc5c031d7386057878; test commit b929ce95269672b056732a9c20b26ec00f82984b.

## Acceptance and evidence
- Expected: objective HUD shows "Roboter in ... m – ANGRIFF / ABWEHR" before robot defeat; after robot defeat it still guides to the exit portal.
- The **previous** PR head d0b2ca2 had Godot PR validation success, run 42494061410. This success does not cover the new commits.
- New regression is committed, **not locally executed**. No local Godot 4.4.1 binary execution, no headless gameplay result, no WebGL export, no real 16:9/19.5:9 render or iPhone Safari QA confirmed in this run.
- PR remains DRAFT; no merge, release or immutable Skyway URL issued. Runner gestures, three mandatory English questions, four worlds, power-ups, boss content, archived builds and Unity files untouched.

## Next
Check new CI, fix any failure on this same PR, then tackle isolated licensed walking-character visual integration and real landscape rendering/mobile QA. Do not merge experimental character PR #111 or old camera PR #133.
