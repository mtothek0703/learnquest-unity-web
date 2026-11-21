# Neon City visual framing – 12.11.2026 15:12 CET

- Primary GitHub account: mtothek0703 (michael_kohler1@yahoo.de), repository ID 1427565370.
- Branch: `feature/adventure-a1-walkable-neon-testbed-20261106-19`, PR #157 DRAFT. Main at inspection: `92d49b100a022d8864112ba38494d3565fca2a4f`.
- Gameplay/art commit: `66c7e00c6d9a2048e3704d22e93985b4a97a8c9c`.
- **Actual visual change:** Walking follow-camera offsets reduced from (0, 2.9, 5.2) to (0, 2.55, 4.0) both initially and in follow logic. Intention: increase the small rigged hero's on-screen silhouette in landscape without touching collision, runner or assets.
- **Baseline visual inspection:** Downloaded six actual Godot screenshots from successful PR CI #43225280648, artifact `learnquest-adventure-walk-hero-in-game` (1170x540 and 1280x720, idle/walk/jump). Hero is small and skyline still looks geometric. This change addresses framing only, **not** model detail or animation quality.
- **Acceptance pending:** New PR-head Godot import, headless gameplay, webexport, and regenerated 1280x720/1170x540 screenshots; compare hero readability, HUD obstruction, mission visibility and clipping. If close camera worsens interaction readability, revert or adjust.
- **Executed tests:** Existing baseline CI #43225280648 SUCCESS for prior commit `f91196977b6ce51690173562fe22a3aa8bf4d340`. New commit tests NOT YET CONFIRMED at report creation. No manual iPhone Safari test, FPS measurements, or stable release.
- PR #160 independent DRAFT; V154, Cloudflare V155 preview and historic builds untouched.
