extends Control
## Separate A1 touch pad; does not modify touch_gestures.gd.
@export var walker_path: NodePath
var active_pointer: int = -1
var origin: Vector2 = Vector2.ZERO
@export var pad_radius: float = 76.0

func _walker() -> Node:
	return get_node_or_null(walker_path)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and active_pointer == -1:
			active_pointer = event.index
			origin = event.position
			accept_event()
		elif not event.pressed and event.index == active_pointer:
			active_pointer = -1
			var walker := _walker()
			if walker != null:
				walker.set_touch_move(Vector2.ZERO)
			accept_event()
	elif event is InputEventScreenDrag and event.index == active_pointer:
		var walker := _walker()
		if walker != null:
			walker.set_touch_move((event.position - origin) / maxf(pad_radius, 1.0))
		accept_event()

func _on_jump_pressed() -> void:
	var walker := _walker()
	if walker != null:
		walker.request_jump()
