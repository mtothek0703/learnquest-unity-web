# 2026-11-01 — CC0 65-bone coat-tail silhouette reduction (DRAFT track B)

## Why
- Read both mandatory policies on main; verified the Primary `mtothek0703` account and repository ID `1427565370`.
- Real previous 1280x720 Godot images showed the CC0 character still reads as a bulky, toy-like rider: broad dark-blue side panels hide the waist and arms, even after earlier cleanup of the jump ribbons and exhaust.
- The previous mantle reached roughly 0.225 imported-body widths from the center at its widest point, with a 0.14-body-width mid-chord. This pass targets a visibly narrower, more human coat silhouette, not another decorative attachment.

## Changes
- Resculpted the existing **closed, real four-weight, 65-bone GPU-skinned** twin coat tails: reduced midspan flare from 0.093 to 0.067 body widths, moved the cloth backward by a slightly deeper sweep, preserved closed sidewalls, smooth analytic normals, existing material, landing response, and original Skin/binds.
- Updated numeric geometry regression to require a roughly 0.175–0.205-body-width outer reach and 0.095–0.12 mid-chord while retaining thigh clearance, tapered hem, source Skin, and zero collision changes.
- No change to gameplay, touch, mandatory vocabulary, four worlds, powers, existing Skyway URLs, or Unity archive.

## QA gate
- **Pending CI and matched Godot image review.** Run the existing full PR CI, web export and real 16:9/19.5:9 render captures. Compare front/chase silhouettes and shoulder/hip intersections before calling this a quality improvement. Numerical narrowing alone does not prove the result looks better.
- PR #111 stays **DRAFT / visual hold**. Its V124 working title reserves no version. Stable V140 candidate is handled independently in PR #128; do not merge this experiment into main.
- Manual iPhone FPS, clipping and uninterrupted touch-round acceptance remain open.
