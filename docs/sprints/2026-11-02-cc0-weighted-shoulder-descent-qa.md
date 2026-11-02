# 2026-11-02 — CC0 weighted sleeve shoulder descent (DRAFT visual hold)

## Required preflight
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main`; verified Primary GitHub account `mtothek0703` and repository `mtothek0703/learnquest-unity-web`.
- `main` remains `97b016098eb45b602278f923b3859f178028daf9` (immutable Skyway V153); the independent stable release path is not blocked by this DRAFT.
- PR #111 is still DRAFT. Its V124 title does not reserve a release number.

## Implemented on the existing DRAFT branch
- `001cd36d`: sculpt a continuously descending outer-deltoid profile directly into the two original four-weight CC0 sleeve meshes. The rest-space source-mesh half-width determines a symmetric, normalized falloff (up to 3.8 cm at full upper-arm influence), retaining original 65-bone Skin, elbow articulation, material and no added collision meshes.
- `1827ca54`: regression checks that the outer deltoid is lower than the inner deltoid on both sides, while retaining the existing real-bone, normalized-four-weight, seam, normal and shoulder-crest assertions.
- No gameplay, touch gesture, English-question, world, boss, power-up, archived Skyway or Unity files changed.

## Tests and actual rendered QA
- Final code/test head `1827ca5457705133395f4b44dc96605a47173441`: [full Godot PR CI 41461855941](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41461855941) **completed/success**. Godot import, gameplay and skinning regression, web export, 108 time-frozen landscape costume-layer frames and other workflow captures completed.
- Final [108-frame sleeve-layer artifact 13149816970](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41461855941/artifacts/13149816970) compared against prior green [108-frame baseline artifact 13145939157](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41454688481/artifacts/13145939157), same named 1280×720 PNGs.
- Pixel threshold: per-pixel maximum absolute RGB channel difference >25. Front isolated skin layers: **4,794 / 921,600 pixels (0.520%)**; chase isolated skin layers: **5,099 (0.553%)**. Complete front: **7,577 (0.822%)**; complete chase: **10,201 (1.107%)**. The supposedly unchanged chase `source_only` control already differs in **3,358 (0.364%)** pixels, so these raw counts include render drift and cannot prove a silhouette quality gain.
- Inspected the paired complete and isolated front/chase screenshots. The shoulder descent is technically real but the visual difference is small at actual landscape camera distance. Wide collar, disproportionate upper body and overall character art remain below the desired commercial quality. **No visual acceptance, no merge and no release**.

## Next
1. Redesign the visible collar/shoulder/upper-arm composition together, not only isolated rest-space offsets. Use identical 1280×720 and 1170×540 Godot front/chase screenshots and control frames for QA.
2. Preserve the separate stable gameplay release path. Only ship a future free immutable Skyway version when there is a finished, visibly or playably better feature and successful Godot/export/archive/Pages/SHA checks.
3. Real iPhone Safari FPS, clothing clipping and complete touch round after three English questions remain unverified.
