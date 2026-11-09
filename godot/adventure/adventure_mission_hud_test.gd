extends SceneTree
## Run: godot --headless --path godot --script res://adventure/adventure_mission_hud_test.gd
const Mission = preload("res://adventure/adventure_mission.gd")
const Hud = preload("res://adventure/adventure_mission_hud.gd")
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var mission := Mission.new()
	root.add_child(mission)
	var hud := Hud.new()
	root.add_child(hud)
	await process_frame
	hud.bind_mission(mission)
	_check(hud.progress_label.text == "Kristalle 0/3  |  Schalter 0/2", "initial")
	_check(hud.portal_label.text == "Portal gesperrt", "locked")
	mission.collect_crystal("a")
	mission.collect_crystal("b")
	mission.collect_crystal("c")
	mission.activate_switch("left")
	mission.activate_switch("right")
	_check(hud.progress_label.text == "Kristalle 3/3  |  Schalter 2/2", "complete")
	_check(hud.portal_label.text == "Portal bereit!", "unlocked")
	mission.reset_mission()
	_check(hud.portal_label.text == "Portal gesperrt", "reset")
	hud.bind_mission(null)
	_check(hud.portal_label.text == "Portal gesperrt", "unbind")
	quit(1 if failures > 0 else 0)

func _check(ok: bool, description: String) -> void:
	if not ok:
		push_error("Adventure HUD failed: " + description)
		failures += 1
