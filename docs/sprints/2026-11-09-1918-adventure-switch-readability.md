# LearnQuest Sprint – 2026-11-09 19:18 CET – Mission switch readability

## Ziel und Änderung
Existing Adventure DRAFT PR #157 only. The three floating cyan crystal pickups retain their spherical mesh and animation; both orange mission switches now use a low, wide BoxMesh (0.85 × 0.35 × 0.85 m) instead of an identical sphere. Positions, interaction radius, collection counters, robot fight, quiz, runner, and old releases are unchanged. This makes the two objective types visually distinct even before interaction.

## Akzeptanzkriterien
- Crystal0 has a SphereMesh; Switch0 has a BoxMesh; both have a PickupVisual node.
- Three crystals, two switches, and portal logic remain unchanged.
- Existing bridge, gameplay, runner, and archive regression checks continue to pass before any merge.

## Tatsächliche Prüfungen
- Read all four mandatory policy/roadmap files on main; confirmed Primary account mtothek0703, repository, main 46e899a84c500243274badf71255bb2afec3186b and Adventure branch divergence (198 ahead, 3 behind before this sprint).
- Inspected existing neon_walk_testbed.gd and adventure_bridge_test.gd. Added a new mesh-type assertion to the existing headless bridge test.
- Previous Adventure head 78e8d4b had successful Godot PR validation run #42663293879. **No new CI result was available for the changed head when checked.** No local Godot import/headless test, WebGL export, real 16:9/19.5:9 screenshots, manual iPhone Safari QA or FPS measurement performed in this run.
- Blender PR #160 remains separate; main-based branch was 20 commits ahead and 0 behind when compared. Its previous head 751a5c8 had a successful Godot run #42661474172 and a generated artifact named learnquest-blender-race-before-after (ID 13695001867), but the image content was not visually inspected in this run. No live portal release confirmed.

## Commits and outcome
- Gameplay b82a1f2e365197fa4bfde0cc9c22536a6c71bc79.
- Regression 40ed2170752dae9a4277e3950c5ecda775ec70e3, typing repair 15093016239756fb0af24c6534e3aa234a9072f1.
- Status: DRAFT, awaiting new Godot CI and real rendered visual checks. No merge or Skyway release.
- Next: review new CI; assess visual clarity of mission objects in both landscape aspect ratios, then continue distinct Blender-generated in-world Neon City objects without merging experimental branches blindly.
