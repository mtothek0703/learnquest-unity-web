extends CharacterBody3D
## Isolated A1 movement: no runner input actions or shared touch state.
const SPEED := 5.0
const SPRINT_SPEED := 7.5
const JUMP_VELOCITY := 6.5
const GRAVITY := 19.6
const FALL_LIMIT := -12.0
var spawn_point := Vector3(0, 1.5, 0)
var move_axis := Vector2.ZERO
var jump_requested := false
var input_paused := false
var mobile_sprint_held := false

func _physics_process(delta: float) -> void:
    if global_position.y < FALL_LIMIT:
        # Do not apply gravity or stale movement on the same tick as respawn.
        respawn()
        return
    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    elif jump_requested:
        velocity.y = JUMP_VELOCITY
    jump_requested = false
    var keyboard := Vector2(
        float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
        float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
    )
    var axis := (keyboard + move_axis).limit_length(1.0)
    var speed := SPRINT_SPEED if mobile_sprint_held or Input.is_key_pressed(KEY_SHIFT) else SPEED
    velocity.x = axis.x * speed
    velocity.z = axis.y * speed
    move_and_slide()
    # Face the actual travel direction, independently of the runner rig/camera.
    # Rotate visuals only: CharacterBody collision stays axis-independent.
    var visual := get_node_or_null("WalkingVisual") as Node3D
    if visual != null and axis.length_squared() > 0.001:
        visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-axis.x, -axis.y), minf(1.0, delta * 12.0))

func _unhandled_key_input(event: InputEvent) -> void:
    if input_paused:
        return
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
        jump_requested = true

func set_mobile_move(axis: Vector2) -> void:
    if input_paused:
        return
    move_axis = axis.limit_length(1.0)

func set_mobile_sprint(held: bool) -> void:
    if input_paused:
        return
    mobile_sprint_held = held

func mobile_jump() -> void:
    if input_paused:
        return
    jump_requested = true

func respawn() -> void:
    # Spawn is arena-local; the runner mounts this arena far from world origin.
    global_position = get_parent().to_global(spawn_point)
    velocity = Vector3.ZERO
    move_axis = Vector2.ZERO
    mobile_sprint_held = false
    jump_requested = false
    # A local retry also restores facing without rotating the collision body.
    var visual := get_node_or_null("WalkingVisual") as Node3D
    if visual != null:
        visual.rotation.y = 0.0

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        input_paused = true
        move_axis = Vector2.ZERO
        mobile_sprint_held = false
        jump_requested = false
    elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
        input_paused = false
        move_axis = Vector2.ZERO
        mobile_sprint_held = false
        jump_requested = false
