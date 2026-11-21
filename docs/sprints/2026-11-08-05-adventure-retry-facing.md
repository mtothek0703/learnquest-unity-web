# LearnQuest Adventure – 2026-11-08 05:18 CET: checkpoint facing reset

## Ausgangsprüfung
Primary GitHub account: mtothek0703 / michael_kohler1@yahoo.de; repo: mtothek0703/learnquest-unity-web; branch: feature/adventure-a1-walkable-neon-testbed-20261106-19 (DRAFT PR #157). Main and all four mandatory policy/roadmap documents read before edits. Main comparison base: 46bfea3ecbfa4db8cc755df8d7fab201706d8059; PR initially 105 ahead / 2 behind main, head 617609d86e8023c467074d5fd0656f945d422c41. Previous PR Godot CI run 42437619297: success.

## Implementierung
Checkpoint respawn now restores WalkingVisual yaw to neutral, while leaving the CharacterBody3D collision rotation unchanged. This prevents a sideways-looking character immediately after a mission retry or robot-energy checkpoint. No runner touch, quiz, world, boss, reward or archive files changed.

Gameplay commit: 98e1b7f0feca80fe6f9e7020980183907f03d33f.
Regression commit: b17e3409c03f4f9f3ef940acb36bb7a10b32a76f.

## Akzeptanzkriterien
- WalkingVisual turns while moving right and faces forward again after respawn.
- CharacterBody collision rotation remains zero.
- Sprint, momentum and input still reset; race state and XP remain intact.

## Tatsächliche Tests und Freigabe
Source inspection and regression assertion added to res://adventure/adventure_bridge_test.gd. No local Godot runtime test or Web export was executed in this run. New-head GitHub PR CI must be checked before claiming success. No visual 16:9/19.5:9 render, iPhone Safari test, merge or immutable Pages release performed. PR stays DRAFT.

## Nächster Schritt
Verify new CI, then implement/review reuse of the existing licensed rider appearance without importing PR #111's experimental rig; preserve independent walking physics and runner camera/touch. Perform actual landscape renders and device QA before release.
