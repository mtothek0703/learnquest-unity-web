# 31 Oct 2026 — V138 candidate: Star Harbor aerial cargo mastery

Independent stable-track gameplay feature, not DRAFT PR #111.

Five existing cargo docks gain raised cyan 3D jump targets. A successful catch above 0.85m using the existing Jump gesture earns 20 extra XP and at least 0.75s of real Turbo. Four airborne catches earn 40 XP once. Five precision catches plus four jumps total 445 XP versus 325 before. Original broad lane catch, convoy, 3 English tasks, four worlds, bosses, four abilities, touch and archives unchanged.

Existing harbor cargo regression checks geometry, once-only payout, Turbo, HUD, result and reset in PR and main release CI. Candidate only until Godot tests, export, archive, Pages and exact build.txt SHA verify. V138 workflow refuses overwrite. PR #111 stays DRAFT/visual HOLD, title reserves no version. Manual real-iPhone FPS, clipping and full touch playthrough still open. Pages artifact >1GB remains a risk.

## Final verified release — 31 Oct 2026
- Stable [PR #126](https://github.com/mtothek0703/learnquest-unity-web/pull/126) merged as main commit `3200b304c3d06b938fafb1edaf190e22202200c3` after the initial HUD-version smoke-test failure was fixed (four assertions updated from V137 to V138).
- [Final PR Godot validation 41247957590](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41247957590), [main Godot validation 41248186601](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41248186601), [archive protection 41248186623](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41248186623), [healthcheck 41248186637](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41248186637) and [Pages publication 41248186611](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41248186611) **SUCCESS**.
- [Immutable Skyway V138](https://mtothek0703.github.io/learnquest-unity-web/skyway-v138/) confirmed by release job with HTTP 200 for `build.txt`, `index.html`, `index.js`, `index.wasm`, `index.pck`; build revision exactly `3200b304c3d06b938fafb1edaf190e22202200c3`. Release log confirms **135 historical version directories** preserved, plus original Unity site prepared.
- Pages artifact **1,390,570,305 bytes**, above the 1-GB warning; deployment nevertheless succeeded. This is a growing infrastructure risk, not a resolved optimization.
- Track B separately progressed in [DRAFT PR #111](https://github.com/mtothek0703/learnquest-unity-web/pull/111), with [successful CI 41247986151](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41247986151) and actual 24-frame QA; visual quality gate still open, no merge.
