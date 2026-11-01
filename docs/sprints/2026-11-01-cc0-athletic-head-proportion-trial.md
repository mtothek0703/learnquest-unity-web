# CC0 65-bone rider: athletic head-to-torso proportion trial (1 November 2026)

## Mandatory policy and separation
Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before editing. Verified GitHub Primary identity `mtothek0703` (`michael_kohler1@yahoo.de`) and repository `mtothek0703/learnquest-unity-web`. Work exclusively on experimental DRAFT PR #111 / `sprint-v124-quaternius-rigged-hero`; **no stable release, no reserved V124, no changes to main or historical builds**.

## Trial and hypothesis
The imported Quaternius CC0 65-bone rider still has a disproportionately large, doll-like helmet/face/hair outline. Reduce the complete procedural Head-attached visual group from 1.82 to 1.68 (7.69% smaller than prior trial). The visual group is scaled around sampled head bounds. The original imported CC0 GLB, 65-bone Skeleton3D, weighted body, bind matrices, rider physics, touch controls, three-question gate, four worlds, bosses, power-ups and Unity archive are unchanged.

Changes:
- `godot/rider_external_character.gd`: adjust the single existing `set_visual_scale` call, not a new mesh or rigid duplicate.
- `godot/rider_external_headgear_test.gd`: structural regression requires 1.66–1.70, preserving the real 65-bone rig and mobile portrait constraints.
- Character change commit `cef5203e1f443703b9e12366a17dd8d3b80ba50d`; test commit `2610c33b28fd3b79990f2c93588cd27c87128f98`.

## Acceptance gate / outstanding
- [ ] Final GitHub Actions Godot CI at this documentation head must pass (including 65-bone skinning, portrait, gameplay, web export and landscape captures).
- [ ] Review the **actual** identical 1280×720 and 1170×540 front, chase and oblique frames against the previous successful DRAFT head, not merely test counts. The smaller head must remain expressive and not clip into collar/hair/visor; check controls and UI safe zones.
- [ ] Real iPhone Safari FPS, clipping across all poses and a complete three-English-question + full touch round are still manual acceptance tasks.
- [ ] Do not merge PR #111 unless the whole character and hoverboard visibly exceed stable quality; if eventually approved, rebase on latest main and choose next free immutable Skyway number.

This is a **testable visual hypothesis, not a proven quality improvement**. If the portrait is too small, revert the trial rather than merging it. The stable release track remains independent; latest observed main during this run is V149 commit `bc3f9ac1d576d261509c210cf1c39dc60483bff8`, whose Pages workflow was still running at initial inspection. Do not claim it live without deployment verification.
