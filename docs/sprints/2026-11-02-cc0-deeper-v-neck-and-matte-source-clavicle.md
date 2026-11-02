# 2026-11-02 — DRAFT: deeper weighted V-neck and matte original-skin clavicle

## Scope and account
- Repository: `mtothek0703/learnquest-unity-web`, GitHub Primary `mtothek0703` (`michael_kohler1@yahoo.de`).
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` before editing. `main` was `97b016098eb45b602278f923b3859f178028daf9` (Skyway V153); it was **not modified**.
- Experimental branch `sprint-v124-quaternius-rigged-hero`, PR #111, remains **DRAFT / VISUAL HOLD**. Its title reserves no release number.

## Real changes
1. On the actual original four-weight, 65-bone **weighted jacket**, the front V opening now descends by 10.5% of imported body height at its center instead of 6.8%, with the rear and shoulder rim retained. This is an actual clipped, interpolated Skin triangle boundary, not a flat painted V. Raised collar geometry is reduced from 0.027 to 0.012 rest-space units.
2. The weighted jacket's bright metallic collar-lip highlight is replaced by a matte dark binding; no new mesh, texture, physics or draw call.
3. Crucial layered-image finding: the violet collar mass **remained when the upper jacket was hidden**. The original CC0 body shader was therefore also given a matte, dark, AABB-relative neck/clavicle underlayer and weaker collar emission. This operates on the original imported skinned body, not a replacement rigid prop.
4. The existing four-weight V-clipping regression now samples points below and above the deeper real boundary. The initial CI failure was due to all three test points being above the new neckline, not a parser failure or a failed game export.

## Tests and image evidence
- Initial code-only run [41443311441](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41443311441) **failed** at `front V collar discarded the intersecting original-Skin triangle`. The obsolete triangle fixture was corrected; no failure is hidden.
- After fixture correction, [Godot PR validation 41443530493](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41443530493) **SUCCESS**, 52/52 steps.
- Final source-underlayer code head `a872760d8cfcbda1d0d1b36282bd431bde18dac1`: [Godot PR validation 41444650976](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41444650976) **SUCCESS**, 52/52 steps including Godot import, full headless game/skin regressions, web export and actual landscape image captures.
- Original final [108-image comparison artifact](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41444650976/artifacts/13142627349) compared against the [previous green baseline](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41435064765/artifacts/13136835280) at identical 1280x720 detail cameras.
- RGB max-channel threshold >25: **front after 4,249 pixels (0.461%)**, **chase after 5,716 pixels (0.620%)**. Source-only before controls drift **467 (0.051%) front** and **978 (0.106%) chase**. Changes are real but limited; percentages measure difference, **not quality**.
- Visual verdict: the exposed rear violet upper-chest band is darker and less luminous, but the wide cartoon-like collar/shoulder silhouette and facial proportions remain. **No significant overall high-end quality leap; no visual acceptance.**

## Release decision / preservation
- **No merge to main; no new Skyway URL.** V153 remains the last confirmed stable release; the separate stable track is not blocked by this experiment.
- Original imported 65-bone Skeleton3D, four normalized weights, existing gameplay, three English questions, four worlds, bosses, four power-ups, landscape touch, older Skyway URLs and Unity archive were not changed by this draft.
- No real iPhone Safari FPS, full touch round or all-pose clipping acceptance was performed. Those remain open.
- Next step: replace the *source* shoulder/upper-torso silhouette as a coherent sculpt (and revisit head/face proportions) rather than more isolated collar color or rim adjustments. Compare both chase and front at matched camera/pose before any release decision.
