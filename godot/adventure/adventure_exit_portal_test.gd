extends SceneTree
## Run: godot --headless --path godot --script res://adventure/adventure_exit_portal_test.gd
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://adventure/adventure_area.tscn") as PackedScene
	assert(scene != null, "Adventure scene must import")
	var area := scene.instantiate()
	root.add_child(area)
	await process_frame
	var portal := area.get_node("ExitPortal")
	var walker := area.get_node("Walker") as CharacterBody3D
	var mission := area.get_node("Mission")
	var count := [0]
	portal.exit_requested.connect(func(): count[0] += 1)
	walker.global_position = portal.global_position
	assert(not portal.try_exit(), "Locked portal must reject entry")
	for i in range(3):
		assert(mission.collect_crystal("test_%d" % i))
	assert(not portal.try_exit(), "Switches are mandatory")
	assert(mission.activate_switch("left"))
	assert(mission.activate_switch("right"))
	assert(portal.try_exit(), "Completed nearby mission opens portal")
	assert(count[0] == 1)
	assert(not portal.try_exit(), "Portal must be one-shot")
	portal.reset_portal()
	walker.global_position = Vector3(20, 1, 20)
	assert(not portal.try_exit(), "Remote interaction forbidden")
	mission.reset_mission()
	walker.global_position = portal.global_position
	assert(not portal.try_exit(), "Reset mission locks portal")
	area.queue_free()
	print("ADVENTURE_EXIT_PORTAL_TEST_PASS")
	quit(0)
