# 2026-11-02 – Coherent original-skin shoulder taper (PR #111 DRAFT)

## Purpose
The previous two experiments showed that narrowing the source deltoid alone and then the visible weighted sleeves alone left the complete mobile hero almost unchanged. This trial deliberately coordinates **three real, original-65-bone-Skin surfaces**: source body, GPU-skinned sleeve shell, and the clipped torso jacket. It adds no rigid primitive, collision, external asset, or render pass.

## Implementation
- Original imported body: outer deltoid taper 16% → 19% in X and 6.5% → 7.5% in depth, smoothly fading before armpits, hands and head. Original indices, four weights, 65 bones, and foot contact remain intact.
- Both GPU-skinned sleeves: reduce upper-arm shell and cap crest relief together with the source deltoid, retaining the original four-weight shoulder/elbow bends and rounded lighting normals.
- GPU-skinned jacket: clip the duplicated torso to 22% rather than 24% of imported source width per side, preventing a separate broad shoulder shelf over the newly tailored arms. Existing source-weight interpolation remains intact.
- Tighten source/sleeve geometry regression thresholds; no release metadata or immutable archive paths touched.

## Acceptance / hold
- [ ] Godot PR CI (full headless gameplay, source/sleeve/jacket regression, Web export) successful for this exact commit.
- [ ] Inspect same-pose 1280×720 and 1170×540 chase/front frames, including the source-only control; a pixel difference alone does not prove better quality.
- [ ] Manually check all-pose clipping, iPhone Safari FPS and three English questions followed by a full touch-controlled round.
- [ ] Only merge if the **complete** character/hoverboard is demonstrably better; otherwise retain PR #111 as DRAFT/VISUAL HOLD. No V151 or other release number is reserved.

Stable channel: V150 remains the last independently verified release on main d0f981fd; Godot, Pages and archive workflows are green. This draft must never block a separate finished stable release. The historic Skyway directories and Unity archive are unchanged.
