extends SceneTree
## Run: godot --headless --path godot --script res://adventure/adventure_a1_physics_test.gd

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://adventure/adventure_area.tscn") as PackedScene
	assert(packed != null, "Adventure arena must import")
	var arena := packed.instantiate()
	root.add_child(arena)
	var walker := arena.get_node("Walker") as CharacterBody3D
	var platform := arena.get_node("JumpPlatform") as StaticBody3D
	var boom := arena.get_node("Walker/CameraPivot/CameraBoom") as SpringArm3D
	assert(walker != null and platform != null and boom != null)
	assert(platform.get_node("CollisionShape3D").shape != null, "Platform requires real collision")
	assert(boom.spring_length > 0.0, "Camera must have collision-aware follow distance")
	for i in range(90):
		await physics_frame
	assert(walker.is_on_floor(), "Walker must land on collidable floor")
	walker.request_jump()
	await physics_frame
	await physics_frame
	assert(walker.velocity.y > 0.0, "Jump must produce upward velocity")
	walker.set_touch_move(Vector2(1.0, 0.0))
	for i in range(12):
		await physics_frame
	assert(walker.velocity.x > 0.1, "Separate touch input must move walker")
	walker.set_touch_move(Vector2.ZERO)
	var checkpoint := arena.get_node("Checkpoint") as Area3D
	assert(checkpoint != null and checkpoint.get_node("CollisionShape3D").shape != null)
	walker.global_position = checkpoint.global_position + Vector3(0, 1.0, 0)
	for i in range(8):
		await physics_frame
	assert(walker.checkpoint.distance_to(checkpoint.global_position + Vector3(0, 1.2, 0)) < 0.01, "Checkpoint trigger must save safe position")
	walker.global_position = Vector3(0, -20, 0)
	await physics_frame
	assert(walker.global_position.distance_to(walker.checkpoint) < 1.0, "Fall must respawn at latest checkpoint")
	print("PASS: A1 arena floor, platform collision, camera boom, jump and movement")
	quit(0)
