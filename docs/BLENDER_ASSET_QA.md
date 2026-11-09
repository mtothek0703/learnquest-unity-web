# Blender artwork – isolated LearnQuest test

The GH Actions `Blender Cloud – LearnQuest 3D portal asset` job creates a genuinely Blender-generated GLB and PNG. The feature branch stores them under `godot/assets/3d/`, and the standalone `godot/asset_showcase_blender.tscn` opens the model without changing the running game. This model has no external assets or credentials.

Verify Godot import with `godot --headless --editor --path godot --quit`, then `godot --headless --path godot --script res://blender_portal_test.gd`.

Production safeguard: Existing `main.tscn`, gameplay, saved data, and historic releases are unchanged. Do **not** publish this model to the stable game without a real iPhone image and performance QA. Generated assets are committed **only** on the isolated feature branch, not by manual actions on main.
