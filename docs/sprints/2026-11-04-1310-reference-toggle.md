# LearnQuest Sprint – 2026-11-04 13:10 CET

## Mandatory policy
Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md and LEARNQUEST_RELEASE_POLICY.md on main. Stable releases and experimental character remain separate.

## Track A – stable
No new gameplay/graphics candidate built or released in this run. No Godot tests, web export, archive protection or Pages deployment executed; no success claimed. Last documented stable V154 (not independently reverified in this run). Immutable Skyway URLs and Unity archive untouched.

## Track B – DRAFT PR #111
Added a reference-only toggle to tools/character-frame-compare.html on sprint-v124-quaternius-rigged-hero (commit df04e2d27d664321a61be688ecc9a01aa386b03e). Button toggles old-only visibility while preserving the current split position, aria-pressed communicates state, Escape returns to comparison. No changes to character model, game, or historic assets.

## Validation and next step
Read updated HTML back from GitHub and verified the new function exists. No browser automation, actual image inspection, Godot test or iPhone touch/FPS measurement performed. Visual quality approval remains outstanding; do not merge PR #111 or reserve V124. Next: produce actual 16:9 and 19.5:9 paired renders, inspect silhouette and clipping, then improve the 65-bone mesh/hoverboard itself; separately implement and test a stable gameplay improvement.
