# LearnQuest A4 – Walking touch focus safety (2026-11-06, 16:12 CET)

## Ausgangsbasis
Primary GitHub account mtothek0703 / michael_kohler1@yahoo.de verified; repository mtothek0703/learnquest-unity-web, default main. Main HEAD 0e01246620d33a9afcbb617152748adac4402993. All four mandatory policy/roadmap files read from main. Existing main-based adventure DRAFT branch feature/adventure-a1-walk-arena-20261105-2111 was used to keep the already integrated scene and avoid cherry-picking unfinished components into main.

## Implementierung
godot/adventure/adventure_touch.gd: cancel_touch() releases held joystick pointer and sends zero movement to CharacterBody3D when focus is lost, control is hidden, or it exits the scene tree. Runner gesture handling remains untouched. Added godot/adventure/adventure_touch_focus_test.gd to simulate focus cancellation and repeated pointer reset.

## Akzeptanzkriterien
- Active touch movement becomes zero on application focus loss.
- Finger index is reset, allowing a fresh touch after resuming.
- Hide/exit cannot leave a stale walking direction.
- No change to three English tasks, bosses, four worlds, powerups, runner touch, XP or historical builds.

## Tatsächlich ausgeführte Prüfungen
- GitHub authenticated account/repository/main checked: PASS.
- Policy and roadmap files fetched from main: PASS.
- Code and test committed through GitHub: PASS.
- Godot 4.4.1 import, headless test, WebGL export: NOT RUN (no Godot runtime exercised in this run).
- 16:9/19.5:9 real renders, iPhone Safari, Pages HTTP checks: NOT RUN.
- Test command to execute: godot --headless --path godot --script res://adventure/adventure_touch_focus_test.gd

## Ergebnis
Code committed on existing DRAFT adventure branch; not merged, not released. Commits f124995306ee9809810ac2080876297e5c314c59 and 8b3d4e345748f0bf380c2fee899705e66471e88c. Next: verify actual focus behavior in Godot, then complete the integrated Neon City runner-to-walker-to-runner vertical slice and test it end to end.
