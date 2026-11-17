# Blender artwork – isolated LearnQuest test

The GH Actions `Blender Cloud – LearnQuest 3D portal asset` job creates a genuinely Blender-generated GLB and PNG. The feature branch stores them under `godot/assets/3d/`, and the standalone `godot/asset_showcase_blender.tscn` opens the model without changing the running game. This model has no external assets or credentials.

Verify Godot import with `godot --headless --editor --path godot --quit`, then `godot --headless --path godot --script res://blender_portal_test.gd`.

Production safeguard: Existing `main.tscn`, gameplay, saved data, and historic releases are unchanged. Do **not** publish this model to the stable game without a real iPhone image and performance QA. Generated assets are committed **only** on the isolated feature branch, not by manual actions on main.


## Next prototype step – actual Neon City race bonus portal (feature branch)

The Blender-generated `learnquest_portal.glb` is now instantiated by
`godot/blender_bonus_portal.gd` inside the existing Neon City race in
`godot/world.gd`. The model scrolls down the center lane with the course.
A real crossing of the portal on the center lane grants **25 XP, 15 energy
and 2 seconds of existing Turbo** once per run. A miss or pause awards
nothing. Resetting a run restores the portal, and other worlds hide it.
The original GLB remains editable via the Blender pipeline.

No new collisions, save fields, store purchases or input commands are added.
The score/boost integration is exercised by
`godot/blender_race_integration_test.gd`; Godot PR validation must run
both this test and `blender_portal_test.gd` after editor import.

**Release gate:** This is still an isolated PR. Check that Godot headless
tests pass and review a real browser/iPhone render and FPS before merging
into `main` and publishing. Until then the production game is unchanged.
