# LearnQuest 3D – 09.11.2026, 12:13 CET – Crystal floating

## Scope
Existing DRAFT PR #157 only; Primary GitHub mtothek0703 (michael_kohler1@yahoo.de), repo mtothek0703/learnquest-unity-web. Read all four required main documents. Main 46bfea3ecbfa4db8cc755df8d7fab201706d8059; branch previously 16e41a45d643e28719d9225a73ff402eb4415205, diverged 174 ahead / 2 behind. No merge or release.

## Gameplay change
Remaining Neon City crystal meshes now rotate and gently bob vertically (bounded ±0.12 m). Switches remain stationary. Retry restores both orientation and local visual offset. Changes are visual-only within the opt-in walking arena; no changes to runner, quizzes, four worlds, XP, touch gestures, archives, or published Skyway versions.

## Acceptance criteria
- Only visible crystals animate, switches do not.
- Float is bounded and does not accumulate across frames.
- Mission retry resets rotation and offset.
- Existing adventure bridge and runner regressions pass; no release without import, headless, export, landscape render and device checks.

## Evidence and limitations
Gameplay commit 58f07758654a848ad90105cabb11233ddac1c19b; test commit c97b89285bdebb25c5a9281cd3e61b0547279d8f. Extended `godot/adventure/adventure_bridge_test.gd` to check reset offset. Previous head 16e41a4 had Godot PR CI run 42602421803 completed success. **No local Godot execution, no new-head CI success, no Web export, no 16:9/19.5:9 render and no iPhone Safari acceptance demonstrated in this sprint.** PR remains DRAFT; no immutable release.
