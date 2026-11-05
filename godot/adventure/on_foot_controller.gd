extends CharacterBody3D
## Isolated A1 controller. Never consumes Runner gestures.
@export var walk_speed: float = 5.0
@export var acceleration: float = 16.0
@export var jump_velocity: float = 6.5
@export var gravity_strength: float = 20.0
@export var respawn_height: float = -8.0
@onready var checkpoint: Vector3 = global_position
var touch_vector: Vector2 = Vector2.ZERO
var jump_requested: bool = false

func set_touch_move(value: Vector2) -> void:
	touch_vector = value.limit_length(1.0)

func request_jump() -> void:
	jump_requested = true

func _physics_process(delta: float) -> void:
	if global_position.y < respawn_height:
		global_position = checkpoint
		velocity = Vector3.ZERO
	var keyboard := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction_2d := touch_vector if touch_vector.length_squared() > 0.001 else keyboard
	var desired := Vector3(direction_2d.x, 0.0, direction_2d.y).limit_length(1.0) * walk_speed
	velocity.x = move_toward(velocity.x, desired.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, desired.z, acceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity_strength * delta
	elif jump_requested or Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_velocity
	jump_requested = false
	move_and_slide()
