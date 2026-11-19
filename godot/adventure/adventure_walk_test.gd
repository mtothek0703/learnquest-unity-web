extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://adventure/adventure_area.tscn") as PackedScene
	assert(scene != null, "A1 scene must import")
	var arena := scene.instantiate()
	root.add_child(arena)
	var walker := arena.get_node("Walker") as CharacterBody3D
	assert(walker != null, "Walker must be CharacterBody3D")
	assert(arena.get_node("Ground/CollisionShape3D") != null, "Ground must collide")
	assert(arena.get_node("TouchUI/MovePad") != null, "Separate touch pad required")
	walker.set_touch_move(Vector2(0.8, -0.5))
	assert(walker.touch_vector.length() <= 1.0, "Touch direction clamped")
	walker.request_jump()
	assert(walker.jump_requested, "Jump request accepted")
	walker.set_touch_move(Vector2.ZERO)
	assert(walker.touch_vector == Vector2.ZERO, "Touch release clears motion")
	print("ADVENTURE A1 STRUCTURE TEST PASSED")
	quit(0)
