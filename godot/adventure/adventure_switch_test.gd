extends SceneTree
## Run: godot --headless --path godot --script res://adventure/adventure_switch_test.gd
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var mission: Node = load("res://adventure/adventure_mission.gd").new()
	root.add_child(mission)
	assert(not mission.can_open_portal())
	assert(mission.activate_switch("left"))
	assert(not mission.activate_switch("left"))
	assert(mission.activate_switch("right"))
	assert(not mission.activate_switch("third"))
	assert(not mission.can_open_portal())
	assert(mission.collect_crystal("a"))
	assert(mission.collect_crystal("b"))
	assert(not mission.can_open_portal())
	assert(mission.collect_crystal("c"))
	assert(mission.can_open_portal())
	mission.reset_mission()
	assert(not mission.can_open_portal())
	assert(mission.activated_switch_ids.is_empty())
	assert(mission.collected_ids.is_empty())
	mission.queue_free()
	print("ADVENTURE SWITCH TEST PASSED")
	quit()
