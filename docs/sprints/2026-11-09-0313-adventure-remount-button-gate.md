# LearnQuest Adventure Sprint — 2026-11-09 03:13 CET

## Ausgangslage und Schutz
Primary GitHub account verified: mtothek0703 / michael_kohler1@yahoo.de; repository mtothek0703/learnquest-unity-web (id 1427565370), branch feature/adventure-a1-walkable-neon-testbed-20261106-19. All four required policies/roadmap read on main. Direct compare identifies main at `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; PR #157 base metadata still `b901029`, PR was 153 commits ahead and 2 behind before edits. Existing PR retained as DRAFT; no rebase/merge. Previous head `bdb27ef` had Godot PR CI success run 42534723129.

## Gameplay change
The mobile AUFSTEIGEN button now reflects the same actual exit gate as the existing signal: disabled until 3 crystals, 2 switches, robot defeat and physical proximity to the green exit portal. Tooltip explains the remaining requirement. Refreshes during gameplay and after mission retry. The underlying exit function still validates the conditions independently, including keyboard interaction.

Gameplay commit: `0a6a94748c1b63afa6c9581582cc3b0e570c731c`.
Regression test commit: `ea9b81c5d42cee79854be4d623fb159a83e7ff7b`.

## Akzeptanzkriterien
- AUFSTEIGEN disabled when locked.
- Still disabled after completing objectives/robot while away from portal.
- Enabled inside unlocked portal radius; existing contextual interaction returns to same race.
- No modifications to runner input, quizzes, four worlds, power-ups, boss flow, historical Skyway builds, Unity archive or experimental character PR.

## Tatsächlich ausgeführte Prüfungen / offene Gates
- GitHub Primary account/repository/PR/main and previous CI inspected.
- Source reviewed and regression assertions added to existing `res://adventure/adventure_bridge_test.gd`.
- **No local Godot 4.4.1 import, headless run, WebGL export, 16:9/19.5:9 actual render, iPhone Safari QA, or Pages deployment executed in this run.** The new commit is not yet confirmed green by CI.
- No release, no merge. Next: inspect new PR CI, fix any failures, then assess licensed rider body/board separation in isolated adventure scene before replacing capsule.
