extends Node3D
## Standalone walkable A1 testbed. Run neon_walk_testbed.tscn directly.
signal return_requested
const PlayerScript = preload("res://adventure/neon_walk_player.gd")
var player: CharacterBody3D
var follow_camera: Camera3D
var mobile_axis := Vector2.ZERO
var pressed := {}
var crystals_collected := 0
var switches_activated := 0
var mission_complete := false
var mission_targets: Array[Node3D] = []
var mission_label: Label
const INTERACT_RADIUS := 2.0
const EXIT_PORTAL_POSITION := Vector3(0.0, 1.0, 6.0)
const EXIT_PORTAL_RADIUS := 2.0
const ROBOT_RANGE := 3.0
var robot: Node3D
var robot_hits := 0
var robot_warning := 0.0
var robot_cooldown := 0.0
var robot_stunned := false
var robot_label: Label
var robot_energy := 3
var robot_guard := 0.0
var robot_last_hit := false

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
    _create_mission()
    _create_exit_portal()
    _create_robot()

func _physics_process(delta: float) -> void:
    if not is_instance_valid(player):
        return
    player.set_mobile_move(mobile_axis)
    robot_guard = maxf(0.0, robot_guard - delta)
    if is_instance_valid(robot) and not robot_stunned:
        robot_cooldown = maxf(0.0, robot_cooldown - delta)
        if robot_warning > 0.0:
            robot_warning = maxf(0.0, robot_warning - delta)
            if robot_warning == 0.0:
                _resolve_robot_strike()
                robot_cooldown = 2.0
                _update_robot_label()
        elif robot_cooldown <= 0.0 and player.global_position.distance_to(robot.global_position) <= ROBOT_RANGE:
            robot_warning = 1.2
            _update_robot_label()
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
    return_button.pressed.connect(_request_return)
    var interact_button := Button.new()
    interact_button.text = "INTERAKTION"
    interact_button.anchor_left = 0.77
    interact_button.anchor_right = 0.77
    interact_button.anchor_top = 0.56
    interact_button.anchor_bottom = 0.56
    interact_button.custom_minimum_size = Vector2(160, 60)
    root.add_child(interact_button)
    interact_button.pressed.connect(interact)
    var attack := Button.new()
    attack.text = "ANGRIFF"
    attack.anchor_left = 0.77
    attack.anchor_right = 0.77
    attack.anchor_top = 0.68
    attack.anchor_bottom = 0.68
    attack.custom_minimum_size = Vector2(160, 55)
    root.add_child(attack)
    attack.pressed.connect(attack_robot)
    var guard := Button.new()
    guard.text = "ABWEHR"
    guard.anchor_left = 0.61
    guard.anchor_right = 0.61
    guard.anchor_top = 0.77
    guard.anchor_bottom = 0.77
    guard.custom_minimum_size = Vector2(120, 55)
    root.add_child(guard)
    guard.pressed.connect(guard_robot)
    robot_label = Label.new()
    robot_label.anchor_left = 0.27
    robot_label.anchor_right = 0.75
    robot_label.offset_top = 60.0
    robot_label.offset_bottom = 92.0
    root.add_child(robot_label)
    mission_label = Label.new()
    mission_label.anchor_left = 0.27
    mission_label.anchor_right = 0.75
    mission_label.offset_top = 18.0
    mission_label.offset_bottom = 56.0
    root.add_child(mission_label)

func _create_robot() -> void:
    robot = Node3D.new()
    robot.name = "TrainingRobot"
    robot.position = Vector3(-2.0, 1.0, -5.0)
    var visual := MeshInstance3D.new()
    var shape := BoxMesh.new()
    shape.size = Vector3(1.0, 1.6, 0.8)
    visual.mesh = shape
    robot.add_child(visual)
    add_child(robot)
    _update_robot_label()

func attack_robot() -> bool:
    if not is_instance_valid(player) or not is_instance_valid(robot) or robot_stunned:
        return false
    if player.global_position.distance_to(robot.global_position) > ROBOT_RANGE:
        return false
    robot_hits += 1
    robot_warning = 0.0
    robot_cooldown = 2.0
    if robot_hits >= 2:
        robot_stunned = true
        robot.visible = false
        _update_mission_label()
    _update_robot_label()
    return true

func guard_robot() -> void:
    # A short, deliberate defensive window; independent of runner power-ups.
    robot_guard = 0.8
    _update_robot_label()

func _resolve_robot_strike() -> void:
    # Distance is checked when the telegraph ends: stepping away is a dodge.
    robot_last_hit = player.global_position.distance_to(robot.global_position) <= ROBOT_RANGE and robot_guard <= 0.0
    if robot_last_hit:
        robot_energy = maxi(0, robot_energy - 1)
        if robot_energy == 0:
            # Training encounter resets locally; never silently drains runner lives.
            robot_energy = 3
            player.global_position = to_global(Vector3(0.0, 1.5, 0.0))

func _update_robot_label() -> void:
    if robot_label == null:
        return
    if robot_stunned:
        robot_label.text = "Roboter deaktiviert"
    elif robot_warning > 0.0:
        robot_label.text = "ACHTUNG: Ausweichen oder ABWEHR! Energie %d/3" % robot_energy
    else:
        robot_label.text = "Roboter: %d/2 Treffer | Energie %d/3" % [robot_hits, robot_energy]

func _request_return() -> void:
    if mission_complete and robot_stunned and is_instance_valid(player) and player.global_position.distance_to(to_global(EXIT_PORTAL_POSITION)) <= EXIT_PORTAL_RADIUS:
        return_requested.emit()

func _create_exit_portal() -> void:
    var portal := MeshInstance3D.new()
    portal.name = "ExitPortal"
    portal.position = EXIT_PORTAL_POSITION
    var mesh := CylinderMesh.new()
    mesh.top_radius = 1.1
    mesh.bottom_radius = 1.1
    mesh.height = 2.0
    portal.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("#35f0ba")
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.albedo_color.a = 0.35
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    portal.material_override = material
    add_child(portal)

func _create_mission() -> void:
    for i in range(3):
        _mission_object("Crystal%d" % i, Vector3(-5.0 + i * 4.0, 0.9, -2.0), Color.CYAN)
    for i in range(2):
        _mission_object("Switch%d" % i, Vector3(4.0, 1.5 + i * 1.2, -4.0 - i * 4.0), Color.ORANGE)
    _update_mission_label()

func _mission_object(id: String, at: Vector3, tint: Color) -> void:
    var node := Node3D.new()
    node.name = id
    node.position = at
    var visual := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.42
    mesh.height = 0.84
    visual.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    visual.material_override = mat
    node.add_child(visual)
    add_child(node)
    mission_targets.append(node)

func interact() -> bool:
    if not is_instance_valid(player):
        return false
    for target in mission_targets:
        if not target.visible or player.global_position.distance_to(target.global_position) > INTERACT_RADIUS:
            continue
        target.visible = false
        if target.name.begins_with("Crystal"):
            crystals_collected += 1
        else:
            switches_activated += 1
        mission_complete = crystals_collected == 3 and switches_activated == 2
        _update_mission_label()
        return true
    return false

func _update_mission_label() -> void:
    if mission_label != null:
        mission_label.text = "Kristalle %d/3 | Schalter %d/2 | %s" % [crystals_collected, switches_activated, "PORTAL BEREIT" if mission_complete and robot_stunned else "Roboter besiegen" if mission_complete else "Portal gesperrt"]

func reset_mission() -> void:
    crystals_collected = 0
    switches_activated = 0
    mission_complete = false
    for target in mission_targets:
        target.visible = true
    robot_hits = 0
    robot_warning = 0.0
    robot_cooldown = 0.0
    robot_stunned = false
    robot_energy = 3
    robot_guard = 0.0
    robot_last_hit = false
    if is_instance_valid(robot):
        robot.visible = true
    _update_robot_label()
    _update_mission_label()

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
        interact()
    elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
        attack_robot()
    elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_G:
        guard_robot()

func _sync_axis() -> void:
    mobile_axis = Vector2.ZERO
    for direction in pressed:
        mobile_axis += direction
    mobile_axis = mobile_axis.limit_length(1.0)

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        pressed.clear()
        mobile_axis = Vector2.ZERO
