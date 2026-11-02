# 2026-11-02 — DRAFT: 65-bone weighted jacket curved collar-relief A/B

## Grounded diagnosis
The prior 84-frame Godot isolation run [41394382983](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41394382983) hid the original CC0 source torso and the four-weight fitted jacket separately. In the fixed 1280x720 front torso ROI, hiding the source changed 3,684 pixels while leaving the large blue horizontal ring; hiding the fitted jacket changed 19,910 pixels and removed the ring. This identifies the *jacket layer*, not a source-body recolor, as the primary cause.

## Actual trial
- The original four-weight `TrueSkinnedTailoredJacket` remains attached to the same imported 65-bone Skeleton3D and source Skin. Its **geometric collar relief** now follows the existing curved `_collar_limit` front V (normalized edge `0.78 - 0.068 * front * center_v`) rather than a horizontal rest-height ridge at 0.765. The rear collar remains at its original height.
- The **same skinned jacket's PBR shader collar highlight** follows that exact V in imported rest-space instead of the flat `y=0.766` band. No new meshes, passes, bones, paid assets or collision geometry.
- Extend the silhouette material regression to reject the old horizontal ring and require the curved highlight formula. The existing jacket test continues to gate weighted seam interpolation and the 65-bone skeleton.

## Quality gate (NOT pre-approved)
This is a **visual hypothesis** from actual source/jacket isolation, not a claim of improved appearance. Require successful full Godot PR CI, Web export, 84 pose-locked original landscape frames and a **real image A/B comparison** to the previous 84-frame run before retaining the change. If the collar looks worse, exposes purple underlay or clips the source neck, revert. Real iPhone landscape FPS, full touch playthrough and multi-pose clipping remain unverified.

PR #111 remains DRAFT; no merge, no V153, no reserved release number. Stable main `09601905af48ff905747ea58f43177aa7f7e2e31` / immutable V152 and historical Skyway/Unity archives remain untouched.

## Actual CI and original 16:9 A/B — REJECTED
- [Godot CI 41395582068](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41395582068): **SUCCESS, 52/52 steps**, including 65-bone Skin, GDScript regression, gameplay, Web export and the 84 actual landscape frames.
- Compared identical named images from [previous artifact 13118489663](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41394810987/artifacts/13118489663) and [trial artifact 13119631586](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41395582068/artifacts/13119631586). At 1280×720 and maximum RGB channel delta >30: front detail **823 pixels (0.089%)**, chase detail **2,605 (0.283%)**, full front **357 (0.039%)**, full chase **1,497 (0.162%)**.
- Inspected enlarged actual torso crops. The **large horizontal front blue collar ring is effectively unchanged**, and the chase image shows a new brighter pink strip under the rear shoulder. The numeric differences are not quality scores; this trial **fails visual acceptance**.
- **Decision: revert all three shader/geometry/test edits** to the previously green source versions. Retain only this negative-result documentation; do not merge, reserve V153, or modify stable main. The next experiment should isolate the actual top-edge/backface ring-producing jacket triangles (not merely adjust a material highlight or a relief center), with same-pose front/chase render proof.
