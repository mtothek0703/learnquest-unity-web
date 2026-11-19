extends Area3D
## A2 exit portal: no automatic race transition until GameSession integration exists.
signal exit_requested
@export var mission_path: NodePath = NodePath("../Mission")
@export var walker_path: NodePath = NodePath("../Walker")
@export var interaction_range: float = 2.2
var used: bool = false

func can_exit() -> bool:
	var mission := get_node_or_null(mission_path)
	return mission != null and mission.can_open_portal()

func try_exit() -> bool:
	if used or not can_exit():
		return false
	var walker := get_node_or_null(walker_path) as Node3D
	if walker == null or global_position.distance_to(walker.global_position) > interaction_range:
		return false
	used = true
	exit_requested.emit()
	return true

func reset_portal() -> void:
	used = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
		try_exit()
