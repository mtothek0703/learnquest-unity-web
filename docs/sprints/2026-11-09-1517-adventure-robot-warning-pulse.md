# LearnQuest Adventure A3/A4 – robot danger ring pulse (2026-11-09 15:17 CET)

## Scope and acceptance
- Existing DRAFT PR #157 only; no new parallel A1 branch, no changes to main, runner gestures, quiz, archive, or Unity.
- While the training robot telegraphs a strike, its existing world-space danger marker pulses gently and symmetrically. The hit radius remains ROBOT_RANGE and is not animated.
- Once the warning ends or the robot is stunned, the marker is hidden and its scale returns to Vector3.ONE.

## Preflight
- Primary GitHub link: mtothek0703 / michael_kohler1@yahoo.de, repository mtothek0703/learnquest-unity-web, branch feature/adventure-a1-walkable-neon-testbed-20261106-19.
- Main SHA 46bfea3ecbfa4db8cc755df8d7fab201706d8059; comparison before change: 184 ahead, 2 behind.
- Read all four mandatory policy/roadmap files on main before editing.
- Previous PR head 01ecbe7156c7266720f30532a1553ffe39fb82a9: Godot PR validation workflow 42627846565 concluded success.

## Implementation
- godot/adventure/neon_walk_testbed.gd: scale only the visible danger-ring mesh during the physics telegraph; reset its scale when the ring is hidden.
- godot/adventure/adventure_bridge_test.gd: regression assertions for symmetric live pulse and restored baseline scale.
- Code commits: a7680931a5883547c2be4e73b2867e7a8da24ee9, 21f83c2453b776bde45dbeed93cd3c0fd6de4c98, f153a4e17ed72bb1cc1d7df5edc7942667f6a28e, f34e4eaaa2d3d276eda12b1377c36ea79786cf9.

## Executed checks and limitations
- GitHub connector successfully read the branch source and wrote the four commits. The previous head's GitHub Actions run was verified successful.
- New Godot import/headless regression, web export, real 16:9/19.5:9 captures, device Safari QA and deployment have **not** been executed or verified for this change. The newly added assertions are not claimed to pass until CI runs.
- Keep PR #157 DRAFT; no merge, release number, or skyway publication. Next: inspect new CI and repair if necessary, then actual rendered QA.
