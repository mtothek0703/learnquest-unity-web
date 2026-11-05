# Sprint 2026-11-05 09:12 CET — V145 landscape CI gate repair

## Scope and policy
Read LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md and LEARNQUEST_RELEASE_POLICY.md from main. Primary account and mtothek0703/learnquest-unity-web verified. Stable camera candidate PR #133 remains DRAFT; independent 65-bone character PR #111 remains DRAFT/VISUAL HOLD.

## Reproducible defect and repair
The current godot/chase_camera_visual_capture_test.gd iterates two landscape resolutions × three lanes × before/after = **12** PNGs, and explicitly asserts captures == 12. However both .github/workflows/godot-pr-check.yml and .github/workflows/publish-unity-webgl.yml still asserted exactly **8** PNGs. Even a successful renderer would fail the count gate. Updated both workflows to assert 12, without modifying gameplay, old builds or Unity archives.

Commits: PR validation `1a045d7e5aadb84ed2bb248b744b3c6c31b349fc`; release validation `8debf7d8b39c3ae1c3cf5d94ce885d262e0cfdde`.

## Acceptance and status
- [x] Static consistency: two resolutions, three lanes, two states, expected 12; both workflow assertions aligned.
- [ ] Actual CI render, image artifact inspection, dynamic jump/turbo/landing and board tip visibility.
- [ ] Reconcile PR #133 with current main (at audit: ahead 25, behind 33).
- [ ] Godot import/tests, web export, archive protection, Pages, immutable URL and device FPS for final release.

No merge or release. PR #111 is independent and must not reserve V124 or block other stable improvements. Next: review GitHub Actions push-run result and actual twelve images, then add dynamic movement QA and synchronize main.
