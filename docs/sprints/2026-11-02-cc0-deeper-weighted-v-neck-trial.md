# 2026-11-02 — CC0 deeper four-weight V-neck and matched material (DRAFT)

## Baseline and account
- Repository: `mtothek0703/learnquest-unity-web`, authenticated GitHub Primary `mtothek0703` (`michael_kohler1@yahoo.de`).
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before edits.
- Stable `main`: `09601905af48ff905747ea58f43177aa7f7e2e31` / immutable `skyway-v152/`; no edits to stable main, Pages, Unity archive or historical Skyway URLs.
- Experimental PR #111 remains **DRAFT / VISUAL HOLD**; its V124 title does not reserve a release number.

## Actual change
The current full-front 1280×720 CC0 portrait still shows a broad nearly horizontal blue collar and toy-like chest. This trial reshapes the existing true four-weight, original-Skin jacket rather than adding a rigid neck object: the front V is cut down by **9.5% of source body height** (previously 6.8%) with a smoother, wider lateral falloff. The back and shoulder top remain at their original height. The existing nonlinear edge solver continues to interpolate the original four Skin influences and normals at the cut seam. The mobile jacket shader's collar highlight now follows the **same x/z-dependent V edge** instead of drawing a disconnected horizontal stripe. No collision, touch, skeleton, bind, gameplay or board changes.

## Verification and release gate
- Code: `godot/rider_external_skinned_outfit.gd` and `godot/rider_external_jacket.gdshader`.
- Regression: `godot/rider_external_skinned_outfit_test.gd` now checks a deeper, curved, bilateral front cut, unchanged back and side, interpolated original Skin weights, and matching shader formula.
- GitHub Actions must pass the final branch head after the test correction, including Godot import, original 65-bone skinning, gameplay regressions, Web export and real landscape captures.
- **Visual acceptance is NOT granted by geometry tests.** Compare pose-locked front/chase PNGs to the previous PR #111 run and inspect actual face/collar intersections and the V outline. Real iPhone landscape FPS, clipping and full three-English-question touch round remain unverified.
- If the change proves visually weak or introduces exposed source-model seams, revert this trial rather than merging it. **No stable V153** is authorized from this DRAFT experiment.

## Next
Continue a coherent front/chase character and board silhouette pass, prioritizing original mesh proportions and actual skinning over stacked ornaments. Only after visual acceptance, rebase PR #111 onto current main and choose the next unused immutable release version.

## Actual first-pass CI and image review (02 Nov)
- [Godot CI 41393022889](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41393022889) **SUCCESS** on `39ca86e51`, after correcting a synthetic neckline triangle fixture whose old corners were no longer inside the deeper cut.
- Downloaded real pose-locked 1280×720 `front_detail_after` and `chase_detail_after` frames from artifacts 13118137326 and baseline 13116627229. With maximum RGB channel difference >30 in a fixed 360×260 torso region, **223 front pixels (0.24%)** and **2,746 chase pixels (2.93%)** changed. These are difference counts, **not visual-quality scores**.
- **First pass visually insufficient:** the front still shows the old horizontal blue source-body collar; chase reveals an even larger purple underlayer. Do not approve, merge or release based on this geometry-only trial.
- Follow-up: traced the horizontal glow to `rider_quaternius_suit.gdshader` on the ORIGINAL CC0 body. Added a dark, matte neck underlay and reduced the redundant cyan collar emission, with an explicit shader regression in `rider_external_silhouette_material_test.gd`. This is a second DRAFT A/B trial; **new CI and paired rendered-image comparison required** before retaining it.

## Final decision: rejected and reverted (02 Nov)
- Follow-up [Godot CI 41393796288](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41393796288) **SUCCESS**, including the original-Skin material regression, Web export and actual landscape captures. Downloaded artifact `13118258717` and compared to successful baseline `13116627229` in identical 1280×720 camera framing.
- With the same RGB >30 fixed torso-region metric, the follow-up changed **1,651 front pixels (1.76%)** and **6,095 chase pixels (6.51%)**. The change was visible but **not better**: front still showed the large horizontal ring and the chase view exposed a broad purple source layer. Pixel changes are not a quality acceptance criterion.
- **Rejected** both V-neck and underlay changes. Restored the five edited Godot geometry/shader/test files exactly from previously successful `170d4c0de` in commits `ed383f09`, `bd1192a1`, `a3587fd9`, `7db1efd5`, `82a116f0`. This sprint log is intentionally retained as a negative-result record.
- Next step must identify the ACTUAL visible horizontal collar surface/weighted material layer through controlled isolation before any further sculpt. Do not stack more decorations or assume that a shader/mesh edit is visible without actual render comparison. Keep PR #111 DRAFT and stable `main` unchanged.

## Controlled layer-isolation follow-up
- After restoring the proven baseline, extended `godot/rider_external_character_visual_capture_test.gd` to capture **84** pose-locked frames instead of 60 at 1280×720 and 1170×540. New `after_no_source` and `after_no_jacket` states keep the imported original 65-bone Skin and same camera/board pose, hiding exactly one torso layer at a time. This should identify which layer actually creates the horizontal collar and bulky chase silhouette before attempting another sculpt.
- This is diagnostic-only; it does not modify the shipped character, collision, touch, V152 stable build or historical versions. Await CI and inspect actual frames before drawing a causal conclusion.
