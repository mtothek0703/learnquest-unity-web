extends SceneTree
## Run with: godot --headless --path godot --script res://adventure/adventure_crystal_test.gd
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var mission_script := load("res://adventure/adventure_mission.gd")
	var mission: Node = mission_script.new()
	root.add_child(mission)
	assert(not mission.is_complete())
	assert(mission.collect_crystal("a"))
	assert(not mission.collect_crystal("a"))
	assert(mission.collect_crystal("b"))
	assert(not mission.is_complete())
	assert(mission.collect_crystal("c"))
	assert(mission.is_complete())
	assert(not mission.collect_crystal("d"))
	mission.reset_mission()
	assert(not mission.is_complete())
	assert(mission.collect_crystal("a"))
	mission.queue_free()
	print("ADVENTURE CRYSTAL TEST PASSED")
	quit()
