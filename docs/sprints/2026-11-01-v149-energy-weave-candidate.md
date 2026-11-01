# LearnQuest 3D – V149 Energy Weave candidate (01.11.2026)

## Track A: meaningful gameplay, not a version-only release
Three consecutive energy gates in **different lanes** earn an optional Energy Weave mastery: +75 XP, 2 seconds Turbo, and a visible magenta 3D ring around the rider. Repeating a lane restarts progress at 1; a real hazard hit resets unfinished progress. One award per race, with a clear 2/3 status and result-screen achievement.

The original energy, aerial and clean-flight rewards, touch gestures, three mandatory English tasks, four worlds, bosses and four powers remain unchanged. No new collision nodes or third-party assets.

New `godot/energy_weave_mastery_test.gd` tests real pickups, hazard damage, streak reset, XP cap, pulse lifetime, results and replay. Both PR and release workflows invoke the test. V149 is **only a candidate** until PR and main Godot CI, Webexport, archival protection, Pages and exact immutable build revision are verified. A real 1280×720 / 1170×540 visual comparison and iPhone FPS/clipping QA remain outstanding.

## Track B
PR #111 stays DRAFT; the 65-bone character remains independent and is not version-reserved or merged.
