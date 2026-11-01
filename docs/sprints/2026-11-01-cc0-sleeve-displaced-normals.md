# 2026-11-01 — Track B: correct lighting normals on the true 65-bone weighted sleeves (DRAFT)

## Preflight and stable track
- Read `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` from `main` in this run.
- Verified GitHub Primary `mtothek0703` (`michael_kohler1@yahoo.de`), repository `mtothek0703/learnquest-unity-web` (ID `1427565370`).
- Last separately verified stable release remains [Skyway V145](https://mtothek0703.github.io/learnquest-unity-web/skyway-v145/) at `aa570902`, with [successful Pages deployment](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41314253268). No changes to `main`, immutable releases or the Unity archive in this experiment.
- [PR #111](https://github.com/mtothek0703/learnquest-unity-web/pull/111) remains **DRAFT / VISUAL HOLD**. Its V124 working title does not reserve a release number.

## What changed
- `godot/rider_external_skinned_sleeves.gd`: previously, the genuinely original-Skin-weighted shoulder/elbow/forearm triangles were sculpted into a 3D relief but kept the **pre-sculpt body normals**. That makes curved relief shade like an unmodified flat arm.
- Each generated vertex now receives a finite-difference surface normal from the **actual displaced 3D sculpt** at that vertex, using its same original four-weight arm influence. The calculation runs once at mesh creation, with no extra runtime shader pass, new light, new mesh, downloaded asset, physics collider or gameplay/touch changes.
- Near unstable or flipped seams, the safe original normalized normal is retained.
- `godot/rider_external_skinned_sleeves_test.gd` now checks finite unit normals, actual deltoid relief (not just material colors), mirrored left/right shading and safe wrist orientation.
- Commits: [implementation `f84e87dc`](https://github.com/mtothek0703/learnquest-unity-web/commit/f84e87dce65f826a666a04b43392eb8cee96c12d), [regression `9a8e1883`](https://github.com/mtothek0703/learnquest-unity-web/commit/9a8e18832b728bcd94ab7d18c0c5bd24a384c0d3).

## Acceptance gates
- [ ] Confirm GitHub Actions Godot import, headless gameplay/rig/sleeve regression and Web export on the **final** PR head.
- [ ] Compare actual pose-locked 1280x720 and 1170x540 front/chase screenshots against the previous PR head, with source-only control. A normal calculation alone does **not** prove a visible whole-character upgrade.
- [ ] If the CI test or images reveal broken shading, fix or revert before further work.
- [ ] Whole-character quality, multi-pose clipping, physical iPhone FPS and complete three-question touch round remain **unapproved**. No PR merge or stable release from this change.

## Next
Prioritize visible, coherent shoulder/hair/cape/hoverboard silhouette, rather than subpixel cosmetic tweaks. Keep the stable release lane independent; only release a new immutable Skyway version after genuinely playable/visible improvement, full Godot/Pages/archive checks and exact build revision verification. Pages artifact size over 1 GB remains a separate risk.
