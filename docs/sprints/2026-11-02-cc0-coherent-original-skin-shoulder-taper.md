# 2026-11-02 – Coherent original-skin shoulder taper (PR #111 DRAFT)

## Purpose
The previous two experiments showed that narrowing the source deltoid alone and then the visible weighted sleeves alone left the complete mobile hero almost unchanged. This trial deliberately coordinates **three real, original-65-bone-Skin surfaces**: source body, GPU-skinned sleeve shell, and the clipped torso jacket. It adds no rigid primitive, collision, external asset, or render pass.

## Implementation
- Original imported body: outer deltoid taper 16% → 19% in X and 6.5% → 7.5% in depth, smoothly fading before armpits, hands and head. Original indices, four weights, 65 bones, and foot contact remain intact.
- Both GPU-skinned sleeves: reduce upper-arm shell and cap crest relief together with the source deltoid, retaining the original four-weight shoulder/elbow bends and rounded lighting normals.
- GPU-skinned jacket: clip the duplicated torso to 22% rather than 24% of imported source width per side, preventing a separate broad shoulder shelf over the newly tailored arms. Existing source-weight interpolation remains intact.
- Tighten source/sleeve geometry regression thresholds; no release metadata or immutable archive paths touched.

## Acceptance / hold
- [x] Full Godot PR CI [41366169243](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41366169243) completed/success for code commit b9a682f7, including headless gameplay, 65-bone regressions, Web export and 108 original-skin layer frames.
- [x] Compared 108 previous and 108 new original Godot PNGs in both phone landscape ratios. At max RGB difference >25: complete 1280×720 chase 6,677 pixels (0.725%), front 2,368 (0.257%); source-only chase 968 (0.105%); weighted-sleeve-only chase 1,551 (0.168%). Overall change remains modest; **no visual approval**. The awkward high hand position and broad neck silhouette persist.
- [ ] Manually check all-pose clipping, iPhone Safari FPS and three English questions followed by a full touch-controlled round.
- [ ] Only merge if the **complete** character/hoverboard is demonstrably better; otherwise retain PR #111 as DRAFT/VISUAL HOLD. No V151 or other release number is reserved.

Stable channel: V150 remains the last independently verified release on main d0f981fd; Godot, Pages and archive workflows are green. This draft must never block a separate finished stable release. The historic Skyway directories and Unity archive are unchanged.
