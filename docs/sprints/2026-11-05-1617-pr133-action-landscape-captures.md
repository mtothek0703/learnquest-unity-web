# 2026-11-05 16:17 CET — PR #133 action-state landscape evidence

Track A, DRAFT camera candidate; main remains unchanged. Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md and LEARNQUEST_RELEASE_POLICY.md from main before changes. GitHub Primary account / mtothek0703/learnquest-unity-web verified.

## Change and acceptance
- Preserve existing 12 real OpenGL before/after captures for 3 lanes at 1280x720 and 1170x540.
- Add 6 action-state captures: Turbo, synthetic jump apex (1.25 m rider offset), landing; 3 per resolution. These are actual scene renders but **not** animated gameplay sequences or physical iPhone tests.
- Update both PR and release workflow artifact count gates to exactly 18.
- No gameplay, touch, quizzes, worlds, bosses, power-ups, archive or immutable release URLs modified.

## Evidence and remaining gates
- Code commit a9ac6f8098670796ff586509be3a83705c30d5d0; PR CI count e084e3bfab70d8612d7bb0331836dbb938ca1d70; release CI count 4422cc885b6ba780d0443da23d0d256a5726708c.
- Godot/Xvfb execution, actual 18 PNG artifacts, manual screenshot comparison, main sync, web export, archive protection and Pages deployment **not yet confirmed**. No merge or release.
- Next: run PR CI; inspect all captures; add real animated jump/landing/turbo sequences, sync with latest main and pass release gates.
- Track B PR #111 remains DRAFT / VISUAL HOLD, independent and without a reserved release number.
