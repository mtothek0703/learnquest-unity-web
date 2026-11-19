extends SceneTree
## godot --headless --path godot --script res://adventure/adventure_hud_integration_test.gd
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://adventure/adventure_area.tscn")
	assert(scene != null, "Arena must import")
	var arena := scene.instantiate()
	root.add_child(arena)
	await process_frame
	var mission: Node = arena.get_node("Mission")
	var hud: Control = arena.get_node("TouchUI/MissionHUD")
	assert(hud.mission == mission, "Arena must bind its mission to the HUD")
	assert(hud.progress_label.text.contains("0/3"), "Initial crystal count")
	assert(hud.portal_label.text == "Portal gesperrt", "Initial lock")
	for id in ["a", "b", "c"]:
		assert(mission.collect_crystal(id))
	assert(hud.portal_label.text == "Portal gesperrt", "Switches required")
	for id in ["left", "right"]:
		assert(mission.activate_switch(id))
	assert(hud.progress_label.text.contains("3/3"), "Crystal completion visible")
	assert(hud.progress_label.text.contains("2/2"), "Switch completion visible")
	assert(hud.portal_label.text == "Portal bereit!", "Exit unlocked")
	mission.reset_mission()
	assert(hud.portal_label.text == "Portal gesperrt", "Reset relocks")
	arena.queue_free()
	await process_frame
	print("ADVENTURE HUD INTEGRATION TEST PASSED")
	quit(0)
