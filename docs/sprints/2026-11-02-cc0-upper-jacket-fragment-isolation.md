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
