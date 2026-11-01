# 2026-11-01 — CC0 65-bone hero: compact hoverboard footprint trial (DRAFT)

## Scope
- GitHub Primary `mtothek0703`, repo `mtothek0703/learnquest-unity-web`; both mandatory sprint/release policy documents read from main.
- Independent experimental track B only, PR #111 / branch `sprint-v124-quaternius-rigged-hero`. **No merge or release number reserved**.
- Real 65-bone CC0 GPU-skinned figure, original hoverboard movement, mobile touch, four worlds, three English questions, bosses, four abilities, legacy rider and Unity archive remain intact.

## Reason
The original 1280×720 front/chase images show the hoverboard much wider than the skinned character. Many previous tiny face/shoulder mesh changes were nearly invisible. This trial addresses the **whole rider/board proportion** rather than a microscopic costume detail.

## Implementation
- Only after successful external CC0 model configuration, set the legacy visual hoverboard root to `Vector3(0.80, 1.0, 0.90)` (20% narrower, 10% shorter). Do not change Y hover motion, steering/boost animation, physics or touch.
- The original V123/legacy character path retains its full-size board. The change is reversible and isolated to the draft.
- Extend the actual 65-bone regression with the expected board footprint and absence of collision objects.
- Extend real locked-pose Godot landscape capture from 48 to 60 PNGs, adding `after_original_board` next to `after` for 1280×720 and 1170×540 across front, chase and four additional angles.
- Compare color samples of the identical-pose front and chase images; require at least 70 changed samples at both phone ratios. These checks establish **visible change only**, not aesthetic superiority.

## Release gate
- Await full Godot CI, web export and real visual captures; inspect screenshots before deciding to keep/revert.
- Even a passing CI does **not** approve the entire character. Keep PR #111 DRAFT until genuine visual quality, clipping and manual iPhone QA pass. Stable track A PR #139 may proceed independently.
