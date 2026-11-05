extends Control
## Independent, visible mobile joystick. Never routes input through runner gestures.
@export var walker_path: NodePath
@export var pad_radius: float = 76.0
@export var dead_zone: float = 0.12
var active_pointer: int = -1
var origin: Vector2 = Vector2.ZERO
var current_vector: Vector2 = Vector2.ZERO

func _walker() -> Node:
	return get_node_or_null(walker_path)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(pad_radius, minf(size.x, size.y) * 0.44)
	draw_circle(center, radius, Color(0.12, 0.18, 0.32, 0.48))
	draw_arc(center, radius, 0.0, TAU, 48, Color(0.45, 0.88, 1.0, 0.9), 3.0, true)
	draw_circle(center + current_vector * radius, radius * 0.33, Color(0.55, 0.92, 1.0, 0.9))

func _set_direction(value: Vector2) -> void:
	current_vector = value.limit_length(1.0)
	if current_vector.length() < dead_zone:
		current_vector = Vector2.ZERO
	var walker := _walker()
	if walker != null:
		walker.set_touch_move(current_vector)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and active_pointer == -1:
			active_pointer = event.index
			origin = event.position
			_set_direction(Vector2.ZERO)
			accept_event()
		elif not event.pressed and event.index == active_pointer:
			active_pointer = -1
			_set_direction(Vector2.ZERO)
			accept_event()
	elif event is InputEventScreenDrag and event.index == active_pointer:
		_set_direction((event.position - origin) / maxf(pad_radius, 1.0))
		accept_event()

func _exit_tree() -> void:
	_set_direction(Vector2.ZERO)

func _on_jump_pressed() -> void:
	var walker := _walker()
	if walker != null:
		walker.request_jump()
