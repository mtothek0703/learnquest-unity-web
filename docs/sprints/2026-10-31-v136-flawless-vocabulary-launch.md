# LearnQuest V136 candidate — flawless vocabulary launch (31 October 2026)

## Preconditions
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main`.
- Authenticated Primary GitHub account `mtothek0703` / `michael_kohler1@yahoo.de`, exact repository `mtothek0703/learnquest-unity-web`; no Grees account used.
- Stable baseline: V135. Separate experimental 65-bone PR #111 remains DRAFT / visual HOLD and is not part of this release.

## Actual gameplay change
- Three English vocabulary questions still gate every player-facing race.
- Three correct answers with **zero wrong attempts** award **+60 XP and 2.5 seconds of Turbo** at the start of the real continuous race, with visible start feedback and a results achievement.
- A wrong choice is disabled until the next question, counts once against the flawless achievement, and still permits retry and normal entry to the race with original 105 XP and 75 energy. Double-taps on a disabled wrong option cannot count twice.
- The bonus resets between rounds; a low-level diagnostic race entry cannot inherit it.
- No change to native touch gestures, lanes, four worlds, bosses, four powers, archived builds or the original Unity site.

## Acceptance gates
- [x] Implementation and new `flawless_vocabulary_launch_test.gd` committed on stable candidate branch; both PR and release CI execute it.
- [x] Smoke-test version assertions and immutable release workflow prepared for V136 with existing refusal to overwrite a live URL.
- [ ] PR Godot import, all gameplay tests, Web export and landscape capture must finish green.
- [ ] Historical Pages archive check must finish green.
- [ ] Only after successful PR checks: merge, then main Godot + archive + Pages; verify exact build SHA and HTTP 200 for build.txt, HTML, JS, WASM and PCK before calling V136 published.
- [ ] Real iPhone Safari FPS, clipping and a complete three-question-to-race touch playthrough remain manual QA, not automatically passed.

CI: https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41238090920
Archive: https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41238090736
PR: https://github.com/mtothek0703/learnquest-unity-web/pull/124
