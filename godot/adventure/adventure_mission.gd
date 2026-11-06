extends Node
## Prototype mission state; rewards are deliberately NOT wired into persistent XP.
signal crystals_changed(collected: int, required: int)
signal crystals_complete
@export var required_crystals: int = 3
var collected_ids: Dictionary = {}

func collect_crystal(crystal_id: String) -> bool:
	if crystal_id.is_empty() or collected_ids.has(crystal_id) or collected_ids.size() >= required_crystals:
		return false
	collected_ids[crystal_id] = true
	crystals_changed.emit(collected_ids.size(), required_crystals)
	if collected_ids.size() == required_crystals:
		crystals_complete.emit()
	return true

func reset_mission() -> void:
	collected_ids.clear()
	crystals_changed.emit(0, required_crystals)

func is_complete() -> bool:
	return collected_ids.size() == required_crystals
