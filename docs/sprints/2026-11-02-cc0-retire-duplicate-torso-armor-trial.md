# 2026-11-02 — CC0 fitted jacket silhouette: retire redundant torso armor (DRAFT)

## Policy, account and scope
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` for this run. Confirmed GitHub Primary `mtothek0703` / `michael_kohler1@yahoo.de` and exact repository `mtothek0703/learnquest-unity-web`.
- Stable main was `09601905af48ff905747ea58f43177aa7f7e2e31` (verified Skyway V152). Stable releases remain independent; no version reserved by DRAFT PR #111.

## Hypothesis and real implementation
Recent same-camera 1280×720 comparisons showed that repeated narrow panel and shoulder tweaks changed only small pixel fractions while the full rider still looked layered and barrel-shaped. This trial tests a **composition change**, not another recolor: if the original-65-bone weighted flight jacket **and** the four genuine weighted harness bands both install, hide the three opaque overlaid pectoral/spine armor panels. Keep their original Skin meshes, weights and nodes intact for fallback and isolated before/after comparisons. The jacket, sleeves, original CC0 body, facial animation, 65-bone rig, and sculpted board stay unchanged. No new primitives, draw calls, physics, touch inputs or external assets.

## Regression and release hold
- Extend `rider_external_skinned_armor_test.gd` to assert the fitted harness, visible source-weighted jacket, three retained hidden armor panels and `armor_layers_retired` state; keep all existing four-weight interpolation, curved profile and mesh checks.
- Run complete Godot CI, export, gameplay and 1280×720/1170×540 front/chase QA. Compare actual complete rider and layer-isolated images against the preceding DRAFT commit. **A successful test is not aesthetic acceptance.**
- No merge of PR #111 or Skyway release without demonstrable complete-hero improvement and manual iPhone FPS/clipping/full-touch-round QA. Older Skyway builds and Unity archive must remain untouched.

## Results
- Pending CI and same-camera image inspection after code commit. If the visual composition worsens, revert the trial rather than claim a quality improvement.
