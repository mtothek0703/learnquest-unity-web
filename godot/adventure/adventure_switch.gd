extends Area3D
## A2 prototype: explicit interaction only, no automatic activation on overlap.
@export var switch_id: String = ""
@export var mission_path: NodePath = NodePath("../Mission")
@export var walker_path: NodePath = NodePath("../Walker")
@export var interaction_range: float = 2.2
var activated: bool = false

func try_activate() -> bool:
	if activated:
		return false
	var walker := get_node_or_null(walker_path) as Node3D
	var mission := get_node_or_null(mission_path)
	if walker == null or mission == null:
		return false
	if global_position.distance_to(walker.global_position) > interaction_range:
		return false
	if not mission.activate_switch(switch_id):
		return false
	activated = true
	return true

func reset_switch() -> void:
	activated = false
