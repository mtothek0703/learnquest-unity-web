extends Node3D
## Standalone A1 vertical-slice playground. Not loaded by the existing runner.
## Run res://adventure/neon_rooftop.tscn directly for desktop QA.
const WALK_SPEED := 5.5
const JUMP_SPEED := 6.5
const GRAVITY := 18.0
var player: CharacterBody3D
var camera: Camera3D
var move_touch := Vector2.ZERO
var jump_requested := false
var spawn_point := Vector3(0, 1.4, 3)
var move_pointer := -1
var move_origin := Vector2.ZERO
var touch_jump_rect := Rect2()
var touch_move_rect := Rect2()

func _ready() -> void:
    _platform(Vector3(0, -0.5, 0), Vector3(18, 1, 20), Color("#253451"))
    _platform(Vector3(-4, 0.6, -4), Vector3(4, 1, 4), Color("#426d93"))
    _platform(Vector3(2, 1.8, -7), Vector3(4, 1, 4), Color("#397b80"))
    for x in [-9.5, 9.5]:
        _platform(Vector3(x, 1.5, 0), Vector3(1, 4, 20), Color("#5b3e86"))
    player = CharacterBody3D.new()
    player.name = "OnFootPlayer"
    player.position = spawn_point
    player.floor_snap_length = 0.3
    add_child(player)
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.36
    capsule.height = 1.6
    var collider := CollisionShape3D.new()
    collider.shape = capsule
    player.add_child(collider)
    var body := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.36
    mesh.height = 1.6
    body.mesh = mesh
    body.material_override = _material(Color("#4ce6db"))
    player.add_child(body)
    camera = Camera3D.new()
    camera.name = "OnFootCamera"
    camera.current = true
    camera.fov = 65.0
    add_child(camera)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-45, -25, 0)
    add_child(light)
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#111b36")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#a5c7e8")
    env.environment = environment
    add_child(env)

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    return material

func _platform(at: Vector3, dimensions: Vector3, color: Color) -> void:
    var solid := StaticBody3D.new()
    solid.position = at
    add_child(solid)
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = dimensions
    shape.shape = box
    solid.add_child(shape)
    var visual := MeshInstance3D.new()
    var box_mesh := BoxMesh.new()
    box_mesh.size = dimensions
    visual.mesh = box_mesh
    visual.material_override = _material(color)
    solid.add_child(visual)

func _physics_process(delta: float) -> void:
    var keys := Vector2(
        float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
        float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
    )
    var movement := (keys + move_touch).limit_length()
    player.velocity.x = movement.x * WALK_SPEED
    player.velocity.z = movement.y * WALK_SPEED
    if player.is_on_floor():
        if Input.is_key_pressed(KEY_SPACE) or jump_requested:
            player.velocity.y = JUMP_SPEED
        else:
            player.velocity.y = 0.0
    else:
        player.velocity.y -= GRAVITY * delta
    jump_requested = false
    player.move_and_slide()
    if player.global_position.y < -8.0:
        player.global_position = spawn_point
        player.velocity = Vector3.ZERO
    var desired := player.global_position + Vector3(0, 4.0, 7.0)
    camera.global_position = camera.global_position.lerp(desired, minf(delta * 8.0, 1.0))
    camera.look_at(player.global_position + Vector3.UP * 0.7)

func _input(event: InputEvent) -> void:
    var viewport_size := get_viewport().get_visible_rect().size
    touch_move_rect = Rect2(Vector2.ZERO, Vector2(viewport_size.x * 0.45, viewport_size.y))
    touch_jump_rect = Rect2(Vector2(viewport_size.x * 0.65, 0), Vector2(viewport_size.x * 0.35, viewport_size.y))
    if event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        if touch.pressed:
            if move_pointer == -1 and touch_move_rect.has_point(touch.position):
                move_pointer = touch.index
                move_origin = touch.position
                move_touch = Vector2.ZERO
            elif touch_jump_rect.has_point(touch.position):
                jump_requested = true
        elif touch.index == move_pointer:
            move_pointer = -1
            move_touch = Vector2.ZERO
    elif event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        if drag.index == move_pointer:
            move_touch = ((drag.position - move_origin) / 75.0).limit_length()

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        move_pointer = -1
        move_touch = Vector2.ZERO
        jump_requested = false
