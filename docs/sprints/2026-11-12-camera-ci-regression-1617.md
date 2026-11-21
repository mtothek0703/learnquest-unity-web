# LearnQuest Neon City – camera CI regression, 2026-11-12 16:17 CET

- Account: Primary mtothek0703 (michael_kohler1@yahoo.de), repository ID 1427565370.
- Branch: `feature/adventure-a1-walkable-neon-testbed-20261106-19`; preceding head `b94fa71d47c165eb37c99c2e6f57042a9aa4e890`; main base reported by PR `b9010294fea1728212bea50d413c465d55706dd2`.
- Mandatory main documents reviewed: LEARNQUEST_SPRINTS.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md. NEUE_LEARNQUEST_RELEASE_POLICY.md not present (404).
- Last completed PR CI [43235027362](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/43235027362): FAILURE in adventure bridge test, camera recovery expected z > player.z + 4.7 although the preceding visual camera adjustment set the desired follow distance to 4.0. Downstream web export and screenshot steps skipped. Upload errors are consequences of missing captures, not passed tests.
- Actual change: update both camera obstacle/recovery test bounds to 3.8 and 3.7, respectively, preserving a margin against the new 4.0 follow distance. No gameplay or scene geometry changed. Code commit `c507d0b771ad39207a847c1c2ab3afef1fbd749f`.
- Acceptance: bridge test must pass, Godot import, web export, and actual 1280x720 / 1170x540 in-game images must complete. Not yet demonstrated for this commit.
- Visual quality delta this sprint: **none**. This is a necessary correction to unblock validation of the previous camera framing change, not a new graphical improvement.
- PR #160 remains independent draft. No merge, no release, V154 and existing Cloudflare V155 untouched. iPhone Safari manual QA remains open.
- Next: inspect new CI and actual screenshots, then improve substantial mesh/model quality rather than adding decorative primitives.
