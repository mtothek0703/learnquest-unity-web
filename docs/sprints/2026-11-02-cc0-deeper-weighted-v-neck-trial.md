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
