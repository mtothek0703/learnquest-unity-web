# LearnQuest Blender Portal – real in-game visual QA and visibility adjustment (2026-11-10 02:11 CET)

## Verified context
- Primary GitHub identity: mtothek0703 (339490599), profile michael_kohler1@yahoo.de; repository mtothek0703/learnquest-unity-web; branch feature/blender-learnquest-integration.
- main commit before edit: 46e899a84c500243274badf71255bb2afec3186b.
- Required four main policy/roadmap files were read before modification.
- Previous PR #160 head 7d5fd8cfe0f0eb65d42bd2dd11bd876551a73906: Godot PR validation #42681487769 SUCCESS.
- Adventure PR #157 remains separate at 1e82f71ba5baad47142322f74be9bc0be94dbbf0, validation #42718808092 SUCCESS. No Adventure code changed in this sprint.

## Actual visual evidence
- Downloaded **real Godot camera screenshots** from GitHub Actions artifact 13703016629 (`learnquest-blender-race-before-after`), produced by #42681487769.
- Opened and compared all eight images: center/adjacent lane, with/without portal, 1280x720 and 1170x540. These are actual Godot screenshots, not mockups.
- **Finding:** adjacent-lane images show a distinct Blender portal gate in the road; center-lane images obscure much of the gate behind the large chase-rider. The high cyan ring is visible but visually disconnected from the gate. In 1170x540, the top mission HUD and two rows of touch buttons occupy substantial vertical screen space; this is a broader UI-quality issue, not fixed by the portal change.
- This is *visual inspection*, not proof of smooth animation, phone performance, touch behavior or real iPhone Safari compatibility.

## One integrated visual change
- Gameplay code commit: ecd647f7a787d3a82674870364ebe33b734d776c.
- `godot/blender_bonus_portal.gd`: two narrow, emissive low-poly side beacons at x=±2.2, y=2.2 relative to the actual Blender GLB portal, outside the rider's center silhouette. Eight radial segments per cylinder, shared material, no shadows.
- Acceptance intent: both side markers should be visible in center-lane 1280x720 and 1170x540 images while retaining the original Blender GLB and upper cue; no change to x=0 pickup, one-time +25 XP/+15 energy/+2s turbo, physics, save, or runner gestures.
- No new Blender job required; existing original Blender GLB remains the functional 3D asset. This is an in-game visibility correction, not a new model or release.

## Tests and release gates
- **Executed this run:** verified prior complete CI results, downloaded artifact ZIP, inspected eight actual rendered Godot PNGs, reviewed portal and runner integration code, committed a scoped change.
- **Not executed/verified for the new head:** Godot import, headless gameplay, 16:9/1170x540 after screenshots, webexport, archive protection, Pages HTTP checks, iPhone touch/FPS.
- PR #160 stays DRAFT; do not merge or release. Confirm new-head CI first; inspect newly rendered screenshots to see whether the two beacons improve visibility without adding clutter. If not, revise or revert. Keep PR #157 and experimental #111 separate, protect all historical Skyway/Unity assets.
