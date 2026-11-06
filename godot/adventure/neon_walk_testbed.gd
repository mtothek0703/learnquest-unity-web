extends Node3D
## Standalone walkable A1 testbed. Run neon_walk_testbed.tscn directly.
signal return_requested
const PlayerScript = preload("res://adventure/neon_walk_player.gd")
var player: CharacterBody3D
var follow_camera: Camera3D
var mobile_axis := Vector2.ZERO
var pressed := {}

func _ready() -> void:
    _platform(Vector3(0, -0.5, 0), Vector3(18, 1, 18), Color("#263456"))
    _platform(Vector3(4, 0.5, -4), Vector3(4, 1, 4), Color("#395c87"))
    _platform(Vector3(4, 1.7, -8), Vector3(4, 1, 4), Color("#317b99"))
    player = CharacterBody3D.new()
    player.name = "WalkingHero"
    player.set_script(PlayerScript)
    player.position = Vector3(0, 1.5, 0)
    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.4
    capsule.height = 1.8
    shape.shape = capsule
    player.add_child(shape)
    var mesh := MeshInstance3D.new()
    mesh.mesh = CapsuleMesh.new()
    mesh.position.y = 0
    player.add_child(mesh)
    add_child(player)
    follow_camera = Camera3D.new()
    follow_camera.name = "Walk follow camera"
    follow_camera.position = Vector3(0, 4.5, 8)
    follow_camera.current = true
    add_child(follow_camera)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-45, -25, 0)
    add_child(light)
    _make_touch_controls()

func _physics_process(_delta: float) -> void:
    if not is_instance_valid(player):
        return
    player.set_mobile_move(mobile_axis)
    if is_instance_valid(follow_camera) and follow_camera.current:
        follow_camera.global_position = player.global_position + Vector3(0, 4.5, 8)
        follow_camera.look_at(player.global_position + Vector3.UP * 0.6)

func _platform(at: Vector3, size: Vector3, tint: Color) -> void:
    var body := StaticBody3D.new()
    body.position = at
    var collider := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = size
    collider.shape = box
    body.add_child(collider)
    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    visual.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    visual.material_override = material
    body.add_child(visual)
    add_child(body)

func _make_touch_controls() -> void:
    var ui := CanvasLayer.new()
    add_child(ui)
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui.add_child(root)
    for entry in [
        ["LINKS", Vector2(0.03, 0.72), Vector2(-1, 0)],
        ["RECHTS", Vector2(0.19, 0.72), Vector2(1, 0)],
        ["VOR", Vector2(0.11, 0.56), Vector2(0, -1)],
        ["ZURÜCK", Vector2(0.11, 0.84), Vector2(0, 1)]
    ]:
        var button := Button.new()
        button.text = entry[0]
        button.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
        button.anchor_left = entry[1].x
        button.anchor_right = entry[1].x
        button.anchor_top = entry[1].y
        button.anchor_bottom = entry[1].y
        button.custom_minimum_size = Vector2(110, 52)
        root.add_child(button)
        var direction: Vector2 = entry[2]
        button.button_down.connect(func(): pressed[direction] = true; _sync_axis())
        button.button_up.connect(func(): pressed.erase(direction); _sync_axis())
    var jump := Button.new()
    jump.text = "SPRUNG"
    jump.anchor_left = 0.80
    jump.anchor_right = 0.80
    jump.anchor_top = 0.77
    jump.anchor_bottom = 0.77
    jump.custom_minimum_size = Vector2(130, 70)
    root.add_child(jump)
    jump.pressed.connect(func(): player.mobile_jump())

    # Only the parent runner handles the actual return transition. The same
    # scene remains independently launchable for Godot movement testing.
    var return_button := Button.new()
    return_button.name = "Return to Hoverboard"
    return_button.text = "AUFSTEIGEN"
    return_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    return_button.offset_left = -185.0
    return_button.offset_right = -15.0
    return_button.offset_top = 16.0
    return_button.offset_bottom = 64.0
    root.add_child(return_button)
    return_button.pressed.connect(func(): return_requested.emit())

func _sync_axis() -> void:
    mobile_axis = Vector2.ZERO
    for direction in pressed:
        mobile_axis += direction
    mobile_axis = mobile_axis.limit_length(1.0)

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        pressed.clear()
        mobile_axis = Vector2.ZERO
