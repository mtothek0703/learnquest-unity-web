# 31 Oct 2026 — CC0 DRAFT board: rising swept carve fins

- Re-sculpted the two existing closed 3D aerofoil fins as a more legible, raised aft wing profile with increased outboard sweep, maintaining symmetric procedural surfaces, existing materials, the original 65-bone rider Skin, and untouched touch/collision/gameplay.
- Added geometry regression for continuous 0.12m+ aft rise/outboard sweep and left/right symmetry. Existing 30/60 FPS steering and 24 real 16:9/19.5:9 OpenGL image captures remain the CI gate.
- This is an **experimental** art-direction attempt only. No release, no merge, no visual quality acceptance without actual before/after frame review and real iPhone QA. PR #111 remains DRAFT. Stable V138 is separate and does not depend on this work.

## Verified result
- [Godot PR validation 41247986151](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41247986151) **SUCCESS**: rig/geometry tests, gameplay, Web export and OpenGL visual captures completed.
- [24 actual landscape frames](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41247986151/artifacts/13060690587) compared against [prior 24-frame artifact](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41245310962/artifacts/13059516813) at identical 1280x720 camera. >25 RGB maximum-channel changed pixels: neutral chase 1.042%, left carve 1.023%, right carve 1.012%, right three-quarter 0.968%. The wider, raised fin tips are visibly exposed in chase view, but this is **not** a substantial overall character/board quality leap.
- Still DRAFT / VISUAL HOLD. No merge/release, no real iPhone FPS or all-pose clipping signoff.
