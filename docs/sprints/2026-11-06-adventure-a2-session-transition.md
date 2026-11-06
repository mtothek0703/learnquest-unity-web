# Sprint 2026-11-06 08:16 – Adventure A2: guarded session transition

## Baseline and scope
Primary GitHub identity: mtothek0703 / michael_kohler1@yahoo.de. Repository: mtothek0703/learnquest-unity-web. Base main SHA: `0e01246620d33a9afcbb617152748adac4402993`. Read `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md` from main before edits.

## Change
New opt-in `godot/adventure/session_transition.gd` models RACE -> TRANSITION -> ON_FOOT -> TRANSITION -> RACE. Dismount requires active race, no quiz, Neon City, initialized session, and explicit enable. Mount requires unlocked exit. Cancel restores prior mode. Session reset clears state. The existing `world.gd`, runner gestures, all worlds, bosses, quiz, power-ups, saves, archive and releases are unchanged. This is **not integrated gameplay**: no live dismount or mount is available yet.

## Acceptance criteria and evidence
- Feature-off rejects dismount; active quiz, non-race and non-Neon City reject it.
- Transition cannot be requested twice; cancellation restores foot mode; return to race requires exit unlock.
- New session and reset clear transition state.
- Test source: `godot/adventure/session_transition_test.gd`; command for future CI: `godot --headless --path godot --script res://adventure/session_transition_test.gd`.
- Tests actually executed this sprint: **none** (Godot runtime not available in the connector environment). No import, headless run, WebGL export, render screenshots, iPhone Safari or Pages checks performed.
- PR: DRAFT pending; implementation commits `90396902ed8ad331033ea63cf3bc9f644e22485b`, `c3d816d614f7ca859c735ad3e09048b899c1d52e`.
- Result: isolated source/test committed; no merge, no release.

## Next
Run Godot 4.4.1 test and import in CI; wire transition into `world.gd` only behind feature-off flag, ensure race simulation actually pauses and three pre-round questions remain unchanged. Coordinate independently with PR #146 (arena), #147 (rewards), #148 (robot), #149 (combat touch). Never blindly merge camera PR #133 or experimental character PR #111.
