extends SceneTree
## Run: godot --headless --path godot --script res://adventure/adventure_joystick_test.gd

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://adventure/adventure_area.tscn") as PackedScene
	assert(packed != null, "Arena must load")
	var arena := packed.instantiate()
	root.add_child(arena)
	var walker := arena.get_node("Walker")
	var pad := arena.get_node("TouchUI/MovePad")
	assert(pad != null and walker != null, "Independent pad and walker required")
	pad._set_direction(Vector2(3.0, 0.0))
	assert(absf(walker.touch_vector.x - 1.0) < 0.001, "Joystick must clamp to unit length")
	pad._set_direction(Vector2(0.02, 0.0))
	assert(walker.touch_vector == Vector2.ZERO, "Dead zone must avoid drift")
	pad._set_direction(Vector2(-0.5, 0.25))
	assert(walker.touch_vector.distance_to(Vector2(-0.5, 0.25)) < 0.001, "Analog movement must be preserved")
	pad._set_direction(Vector2.ZERO)
	assert(walker.touch_vector == Vector2.ZERO, "Release must stop movement")
	print("PASS: A1 visible joystick input clamping, dead zone and release")
	quit(0)
