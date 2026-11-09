extends Node
## Prototype mission state; rewards are deliberately NOT wired into persistent XP.
signal crystals_changed(collected: int, required: int)
signal crystals_complete
signal switches_changed(activated: int, required: int)
signal portal_unlocked
@export var required_crystals: int = 3
@export var required_switches: int = 2
var collected_ids: Dictionary = {}
var activated_switch_ids: Dictionary = {}

func collect_crystal(crystal_id: String) -> bool:
	if crystal_id.is_empty() or collected_ids.has(crystal_id) or collected_ids.size() >= required_crystals:
		return false
	var was_unlocked := can_open_portal()
	collected_ids[crystal_id] = true
	crystals_changed.emit(collected_ids.size(), required_crystals)
	if collected_ids.size() == required_crystals:
		crystals_complete.emit()
	if not was_unlocked and can_open_portal():
		portal_unlocked.emit()
	return true

func activate_switch(switch_id: String) -> bool:
	if switch_id.is_empty() or activated_switch_ids.has(switch_id) or activated_switch_ids.size() >= required_switches:
		return false
	var was_unlocked := can_open_portal()
	activated_switch_ids[switch_id] = true
	switches_changed.emit(activated_switch_ids.size(), required_switches)
	if not was_unlocked and can_open_portal():
		portal_unlocked.emit()
	return true

func can_open_portal() -> bool:
	return collected_ids.size() == required_crystals and activated_switch_ids.size() == required_switches

func reset_mission() -> void:
	collected_ids.clear()
	activated_switch_ids.clear()
	crystals_changed.emit(0, required_crystals)
	switches_changed.emit(0, required_switches)

func is_complete() -> bool:
	return can_open_portal()
