# LearnQuest 3D — Sprint 2026-11-10 06:15 CET

## Verified starting point
- GitHub connection: Primary / mtothek0703 / michael_kohler1@yahoo.de; repository mtothek0703/learnquest-unity-web.
- main: `46e899a84c500243274badf71255bb2afec3186b`. Read `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md` on main before writing.
- Existing DRAFT #157 at `1c7bff38048a933b6ef788caadd02c7b831dd7c9` before change; full PR CI #42755170206 SUCCESS for that head. DRAFT #160 at `dc5be9fc8f9d0d748487490546c5c1ef6ab508d1`, PR CI #42734105793 SUCCESS. #157 is 3 behind main; #160 is 0 behind.

## Concrete change
- `godot/adventure/adventure_visual_capture_test.gd`: fixed a QA mismatch. Its old hard-coded camera position (3.4 m high / 7.4 m back) no longer matched the actual walking camera (2.9 m / 5.2 m), changed in the previous sprint. Capture now places the actual game camera relative to the actual walking hero and aims at the same 0.75 m focus point as gameplay. This makes the next six 1280x720 / 1170x540 idle/walk/jump images valid evidence for the new framing instead of showing obsolete framing.
- Commit: `0c86b4b672c24f6000c31e1e2b6b1317c4d9d6f8` on the existing #157 branch. Runner camera, touch gestures, missions, quiz, score, archives, and stable releases untouched.

## Acceptance criteria and actual verification
- Source inspection: verified camera constants in `neon_walk_testbed.gd` and obsolete capture coordinates before editing; exact expected lines replaced with a guarded SHA-based update. **Passed source-level check.**
- Godot import, six new rendered screenshots, headless regression, web export, iPhone Safari/FPS: **not executed in this run**; new commit CI is **not yet confirmed**. Prior successful CI does not prove this change.
- The current walk hero and environment still need real image comparison and quality work; this is a capture accuracy fix, not a claim of improved gameplay visuals.
- Blender portal #160: unchanged, DRAFT, not confirmed live. No merge, no release, V154 and archives preserved.

## Next safe step
Confirm CI for new #157 head; inspect freshly generated screenshots at both aspect ratios and correct the largest observed hero/scene composition defect in #157. Review portal #160 screenshots separately. No merge without full quality gates and actual iPhone QA.
