# Adventure A3 – separate mobile attack/guard controls (2026-11-06 07:11 CET)

## Baseline and scope
Authenticated Primary account mtothek0703 (michael_kohler1@yahoo.de), repository mtothek0703/learnquest-unity-web. Branch feature/adventure-a3-combat-touch-20261106-0711 created from main 0e01246620d33a9afcbb617152748adac4402993. Before writing, read on main: LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md.

## Change and acceptance criteria
Standalone adventure_combat_touch.gd builds separate touch buttons ANGRIFF (tap) and ABWEHR (hold), emitting attack_requested and guard_changed. Combat disabled by default. Guard releases on finger-up, UI hide, disable, or removal, avoiding stuck defensive input after pause/transition. No edits to runner touch_gestures.gd, world.gd, quiz, bosses, power-ups, archives or assets.

Acceptance: disabled input inert; enabled attack once per press; guard down/up emits balanced true/false; hide/disable cancels held guard; on-foot scene can connect these signals to neon_robot_actor.gd in DRAFT PR #148 after integration. Touch target 104x72 logical pixels; real safe-area/landscape QA pending.

## Verification
GitHub branch creation and file commits are actual source writes. Headless test source: godot --headless --path godot --script res://adventure/adventure_combat_touch_test.gd.
No Godot import, headless execution, Web export, actual 16:9/19.5:9 render, iPhone Safari QA, Pages HTTP checks, archive checks or release verified in this run. No CI pass claimed. This is an independent building block, not a playable integrated encounter.

## Follow-up
Run Godot 4.4.1 test in CI; integrate into PR #146 arena with PR #148 robot and connect signal handlers; check pointer cancel and landscape safe areas on actual device. No merge/release until all required gates pass.
