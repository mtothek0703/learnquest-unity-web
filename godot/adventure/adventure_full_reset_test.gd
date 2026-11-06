extends SceneTree
## Headless regression: run with godot --headless --path godot --script res://adventure/adventure_full_reset_test.gd
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://adventure/adventure_area.tscn")
	var area: Node3D = scene.instantiate()
	root.add_child(area)
	await process_frame
	var mission: Node = area.get_node("Mission")
	mission.collect_crystal("neon_1")
	mission.collect_crystal("neon_2")
	mission.collect_crystal("neon_3")
	mission.activate_switch("neon_left")
	mission.activate_switch("neon_platform")
	area.get_node("Crystal1").visible = false
	area.get_node("Crystal1").set_deferred("monitoring", false)
	area.get_node("Switch1").activated = true
	area.get_node("ExitPortal").used = true
	area.reset_adventure()
	await process_frame
	var ok: bool = not mission.can_open_portal()
	ok = ok and mission.collected_ids.is_empty() and mission.activated_switch_ids.is_empty()
	for name in ["Crystal1", "Crystal2", "Crystal3"]:
		var crystal: Area3D = area.get_node(name)
		ok = ok and crystal.visible and crystal.monitoring
	for name in ["Switch1", "Switch2"]:
		ok = ok and not area.get_node(name).activated
	ok = ok and not area.get_node("ExitPortal").used
	if not ok:
		push_error("Adventure reset left an objective or portal active")
		quit(1)
	else:
		print("PASS adventure full reset")
		quit(0)
