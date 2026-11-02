# 2026-11-02 — Upper-jacket fragment isolation for CC0 collar diagnosis (DRAFT)

## Baseline / policy
- GitHub Primary (michael_kohler1@yahoo.de), repository mtothek0703/learnquest-unity-web verified before editing. Read LEARNQUEST_SPRINTS.md and LEARNQUEST_RELEASE_POLICY.md from main.
- Stable main 09601905af48ff905747ea58f43177aa7f7e2e31 / skyway-v152 remains untouched; PR #111 stays DRAFT and its old V124 title reserves no version.
- Earlier 84-image source-versus-jacket isolation established that hiding the true four-weight jacket removes the horizontal blue front ring (19,910 changed ROI pixels). The prior geometric collar-relief trial passed CI but failed actual front/chase image QA and was reverted.

## This diagnostic-only sprint
- The existing original-Skin jacket shader gains a QA-only uniform with default 0 (unchanged normal gameplay appearance). In capture mode 1, discard jacket fragments below normalized source rest-height 0.735, showing the upper jacket/collar only. In capture mode 2, discard jacket fragments at or above 0.735, showing the complementary lower jacket.
- The existing 1280x720 and 1170x540, six-camera, pose-locked visual capture now emits 108 instead of 84 images (nine variants per view and size). All existing variants and source/board comparisons remain intact; the shader uniform resets to zero after capture.
- The PR CI expected-image count is updated to 108. No production geometry, 65-bone Skin, original imported mesh, touch, collisions, gameplay, main, Pages, immutable Skyway directories or Unity archive changed.

## Acceptance and next action
- Run complete Godot PR CI and Web export on this exact commit. Download real after, after_upper_jacket_only and after_without_upper_jacket 1280x720 front/chase detail frames from the workflow artifact; compare in identical camera pose. The actual upper collar ring must be identified before any next sculpt.
- This diagnostic is NOT a visual improvement or authorization to merge or publish V153. Do not claim a successful image comparison until the artifacts are inspected. iPhone Safari landscape FPS, all-pose clipping and a full three-English-question touch round remain unverified.

## Verified CI and real image review (02 Nov, 06:16 UTC)
- [Godot PR CI 41398349714](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41398349714) **SUCCESS, 52/52 steps**, on code commit f6e99b5ab667c49405c25d89401bfbca3954da36; Godot import, gameplay/skin regressions, Web export and 108 landscape frames completed.
- Downloaded [artifact 13120181971](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41398349714/artifacts/13120181971), inspected the actual 1280x720 front_detail and chase_detail frames, comparing after vs upper-only, without-upper and no-jacket in exactly locked pose/camera.
- Fixed 345x250 torso ROI (x=470..814, y=175..424), max RGB channel difference >30: front upper-only 16,527 (19.16%), without-upper 3,430 (3.98%), no-jacket 19,954 (23.14%); chase upper-only 12,089 (14.02%), without-upper 2,740 (3.18%), no-jacket 11,821 (13.71%). These counts describe changed pixels, not visual quality.
- Narrower 335x115 collar ROI (x=475..809, y=180..294): front upper-only 8,474 (22.00%), without-upper 3,430 (8.90%), no-jacket 11,903 (30.90%); chase upper-only 2,862 (7.43%), without-upper just 38 (0.10%), no-jacket 2,858 (7.42%).
- **Visual diagnosis:** in the front view the bright blue rim persists when the upper jacket alone is rendered, while removing the upper jacket exposes a *different purple horizontal band* from overlapping geometry. In the chase collar ROI, removing the upper jacket barely changes the band. Therefore the ring is **not** a single removable top-edge strip: front upper jacket and underlying/source/other shoulder layers overlap. Another single-plane cut or highlight-only tweak would be speculative.
- This sprint improves diagnosis and regression capture, **not the visual quality of the shipped character**. Keep the default uniform at zero, retain PR #111 as DRAFT, and do not merge/release V153.
- Next targeted experiment: isolate the *other* visible shoulder/collar layer(s) in the same front/chase pose (including original source and any yoke/pauldron meshes), then sculpt a coordinated transition with real image A/B. Do not interpret CI as real iPhone Safari FPS or complete touch-playthrough acceptance.
