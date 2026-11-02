# 2026-11-02 — CC0 weighted shoulder arch and sleeve taper (DRAFT only)

## Mandatory branch and release gate
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` on `main` at the start of this run.
- Verified Primary GitHub account `mtothek0703` / `michael_kohler1@yahoo.de` and repository `mtothek0703/learnquest-unity-web`.
- Stable `main` remains `97b016098eb45b602278f923b3859f178028daf9` (V153). Existing successful main Actions: Godot `41415306699`, archive `41415306666`, health `41415306631`, Pages `41415306903`. No V154 was published.
- Experimental PR #111 remains **DRAFT**. Its title is not a release reservation. Do not merge or modify historic Skyway URLs or Unity archive.

## Goal and actual changes
The previous landscape QA showed oversized rounded shoulder/sleeve volumes despite the source CC0 shoulder slope. This experiment coordinates the **existing four-weight original-Skin meshes** rather than adding rigid armor:
1. `godot/rider_external_skinned_outfit.gd`: subtract a smooth bilateral, bounds-relative upper-deltoid arch from jacket depth and lateral spread, and descend the outer shoulder while preserving the central neckline.
2. `godot/rider_external_skinned_sleeves.gd`: reduce the weighted sleeve's deltoid shell, lateral sweep and upper lift, while preserving its center crest, elbow, forearm and four original bone weights.
3. Strengthen regression bounds in the two matching Godot tests for the slimmer shoulder and symmetrical crest. No physics, board collision, touch, vocabulary, worlds, bosses, power-ups, GLB source, external assets or archived builds changed.

## Tests and visual evidence
- First complete GitHub Actions trial `41453416466` **failed** at `EXTERNAL SKINNED SLEEVES TEST`: the old 0.009m center-to-edge crest requirement no longer matched the intentionally smaller shell. The actual shoulder crest was kept; the threshold was adjusted to 0.006m, still requiring bilateral curved geometry.
- The corrected code passed complete Godot PR validation `41453765395`, including skinning/gameplay tests, web export and capture/upload of real landscape frames.
- Matched 1280×720 **front idle** crop (355×300) versus prior successful `41444650976`: **541 / 106,500 pixels (0.508%)** differ by more than 12 RGB levels. The difference is subtle, not a convincing overall visual quality leap.
- The corresponding chase crop differs much more, but the hoverboard energy ring, rider pose and hair differ between captures; **do not attribute that change to the shoulder sculpt**. A time-frozen, tightly controlled comparison is still needed before any art approval.
- Final strengthened upper-arch regression and documentation commit require a fresh current-head CI check; do not claim those commits were covered by the earlier run.

## Decision
**Keep as reversible DRAFT trial only; visual QA HOLD.** The imported 65-bone Skin, old builds and main stay intact. The actual front view still reads as a large rounded shoulder silhouette. Next work should target the complete source-weighted shoulder/upper-arm profile with matched, animation-frozen front/chase/side frames, not claim this modest change is a high-end character.

Manual iPhone Safari landscape FPS, mesh clipping and a full three-question-to-finished-round touch test remain outstanding.
