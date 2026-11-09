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
var return_button: Button
const INTERACT_RADIUS := 2.0
const EXIT_PORTAL_POSITION := Vector3(0.0, 1.0, 6.0)
const EXIT_PORTAL_RADIUS := 2.0
const ROBOT_RANGE := 3.0
var robot: Node3D
var robot_visual: MeshInstance3D
var robot_warning_zone: MeshInstance3D
var robot_material: StandardMaterial3D
var robot_hits := 0
var player_attack_cooldown := 0.0
var robot_warning := 0.0
var robot_cooldown := 0.0
var robot_stunned := false
var robot_label: Label
var robot_energy := 3
var robot_guard := 0.0
var robot_guard_cooldown := 0.0
var robot_last_hit := false
var robot_feedback := ""
var hero_material: StandardMaterial3D
var portal_material: StandardMaterial3D
var adventure_focus_paused := false

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
    mesh.name = "WalkingVisual"
    mesh.mesh = CapsuleMesh.new()
    hero_material = StandardMaterial3D.new()
    hero_material.albedo_color = Color("#d7e9ff")
    mesh.material_override = hero_material
    mesh.position.y = 0
    player.add_child(mesh)
    # Visible shield independent of the hidden capsule and imported glTF material.
    var shield := MeshInstance3D.new()
    shield.name = "WalkingShield"
    var shield_mesh := SphereMesh.new()
    shield_mesh.radius = 1.08
    shield_mesh.height = 2.16
    shield.mesh = shield_mesh
    var shield_material := StandardMaterial3D.new()
    shield_material.albedo_color = Color(0.25, 1.0, 0.78, 0.20)
    shield_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    shield_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    shield.material_override = shield_material
    shield.visible = false
    player.add_child(shield)
    # Load the existing licensed body without creating the hoverboard adapter.
    _install_walking_character(mesh)
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

func _install_walking_character(fallback: MeshInstance3D) -> void:
    const CHARACTER_PATH := "res://models/rider.gltf"
    if not ResourceLoader.exists(CHARACTER_PATH):
        return
    var resource := load(CHARACTER_PATH) as PackedScene
    if resource == null:
        return
    var model := resource.instantiate() as Node3D
    if model == null:
        return
    # Visual-only: the original CharacterBody3D still owns all collision.
    var bounds := _visual_bounds(model, Transform3D.IDENTITY)
    if bounds.size.y <= 0.01:
        model.free()
        return
    var scale_factor := minf(1.65 / bounds.size.y, 2.0)
    model.scale = Vector3.ONE * scale_factor
    model.position.y = -(bounds.position.y + bounds.size.y * 0.5) * scale_factor
    model.name = "WalkingVisual"
    fallback.name = "WalkingCapsuleFallback"
    fallback.visible = false
    player.add_child(model)

func _visual_bounds(node: Node3D, parent_transform: Transform3D) -> AABB:
    var local_transform := parent_transform * node.transform
    var result := AABB()
    var found := false
    if node is MeshInstance3D and node.mesh != null:
        result = local_transform * node.mesh.get_aabb()
        found = true
    for child in node.get_children():
        if child is Node3D:
            var child_bounds := _visual_bounds(child, local_transform)
            if child_bounds.size.length_squared() > 0.0001:
                result = result.merge(child_bounds) if found else child_bounds
                found = true
    return result if found else AABB()

func _physics_process(delta: float) -> void:
    if not is_instance_valid(player):
        return
    # Safari tab/app switches must not consume the robot's telegraph while hidden.
    if adventure_focus_paused:
        return
    player.set_mobile_move(mobile_axis)
    player_attack_cooldown = maxf(0.0, player_attack_cooldown - delta)
    robot_guard = maxf(0.0, robot_guard - delta)
    robot_guard_cooldown = maxf(0.0, robot_guard_cooldown - delta)
    _update_hero_guard_visual()
    if is_instance_valid(robot) and not robot_stunned:
        robot_cooldown = maxf(0.0, robot_cooldown - delta)
        if robot_warning > 0.0:
            robot_warning = maxf(0.0, robot_warning - delta)
            if robot_warning == 0.0:
                _resolve_robot_strike()
                robot_cooldown = 2.0
                _update_robot_label()
                _update_robot_visual()
        elif robot_cooldown <= 0.0 and player.global_position.distance_to(robot.global_position) <= ROBOT_RANGE:
            robot_warning = 1.2
            _update_robot_label()
            _update_robot_visual()
    if is_instance_valid(follow_camera) and follow_camera.current:
        _update_follow_camera()
    _update_objective_guidance()
    _update_return_button()

func _update_follow_camera() -> void:
    # Keep the walking camera out of rooftop geometry. The runner camera is untouched.
    var focus := player.global_position + Vector3.UP * 0.6
    var desired := player.global_position + Vector3(0, 4.5, 8)
    var query := PhysicsRayQueryParameters3D.create(focus, desired)
    query.exclude = [player.get_rid()]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if not hit.is_empty():
        desired = (hit["position"] as Vector3) + (hit["normal"] as Vector3) * 0.25
    follow_camera.global_position = desired
    follow_camera.look_at(focus)

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
        button.custom_minimum_size = Vector2(84, 44)
        root.add_child(button)
        var direction: Vector2 = entry[2]
        button.button_down.connect(func(): pressed[direction] = true; _sync_axis())
        button.button_up.connect(func(): pressed.erase(direction); _sync_axis())
    var jump := Button.new()
    jump.text = "SPRUNG"
    jump.anchor_left = 1.0
    jump.anchor_right = 1.0
    jump.anchor_top = 0.80
    jump.anchor_bottom = 0.80
    jump.offset_left = -106.0
    jump.offset_right = -12.0
    jump.custom_minimum_size = Vector2(94, 52)
    root.add_child(jump)
    jump.pressed.connect(_mobile_jump)
    # Independent walking sprint; no changes to the runner swipe controls.
    var sprint := Button.new()
    sprint.text = "SPRINT"
    sprint.anchor_left = 0.03
    sprint.anchor_right = 0.03
    sprint.anchor_top = 0.43
    sprint.anchor_bottom = 0.43
    sprint.custom_minimum_size = Vector2(100, 48)
    root.add_child(sprint)
    sprint.button_down.connect(func():
        if not adventure_focus_paused and is_instance_valid(player):
            player.set_mobile_sprint(true)
    )
    sprint.button_up.connect(func():
        if is_instance_valid(player):
            player.set_mobile_sprint(false)
    )

    # Only the parent runner handles the actual return transition. The same
    # scene remains independently launchable for Godot movement testing.
    return_button = Button.new()
    return_button.name = "Return to Hoverboard"
    return_button.text = "AUFSTEIGEN"
    return_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    return_button.offset_left = -185.0
    return_button.offset_right = -15.0
    return_button.offset_top = 16.0
    return_button.offset_bottom = 64.0
    root.add_child(return_button)
    return_button.pressed.connect(_request_return)
    _update_return_button()
    # Explicit on-foot retry; never restarts the runner or reopens the quiz.
    var retry_button := Button.new()
    retry_button.name = "Retry Adventure Mission"
    retry_button.text = "NEUSTART"
    retry_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
    retry_button.offset_left = 16.0
    retry_button.offset_right = 156.0
    retry_button.offset_top = 16.0
    retry_button.offset_bottom = 64.0
    root.add_child(retry_button)
    retry_button.pressed.connect(_retry_from_ui)
    var interact_button := Button.new()
    interact_button.text = "INTERAKTION"
    interact_button.anchor_left = 1.0
    interact_button.anchor_right = 1.0
    interact_button.offset_left = -150.0
    interact_button.offset_right = -12.0
    interact_button.anchor_top = 0.56
    interact_button.anchor_bottom = 0.56
    interact_button.custom_minimum_size = Vector2(138, 48)
    root.add_child(interact_button)
    interact_button.pressed.connect(_contextual_interact)
    var attack := Button.new()
    attack.text = "ANGRIFF"
    attack.anchor_left = 1.0
    attack.anchor_right = 1.0
    # Keep attack in the left action column: on short landscape screens it
    # must not overlap the jump button in the right column.
    attack.offset_left = -255.0
    attack.offset_right = -117.0
    attack.anchor_top = 0.70
    attack.anchor_bottom = 0.70
    attack.custom_minimum_size = Vector2(138, 48)
    root.add_child(attack)
    attack.pressed.connect(attack_robot)
    var guard := Button.new()
    guard.text = "ABWEHR"
    guard.anchor_left = 1.0
    guard.anchor_right = 1.0
    guard.offset_left = -242.0
    guard.offset_right = -116.0
    # Separate attack and guard vertically even at 390px landscape height.
    guard.anchor_top = 0.86
    guard.anchor_bottom = 0.86
    guard.custom_minimum_size = Vector2(126, 48)
    root.add_child(guard)
    guard.pressed.connect(guard_robot)
    robot_label = Label.new()
    robot_label.anchor_left = 0.27
    robot_label.anchor_right = 0.75
    robot_label.offset_top = 92.0
    robot_label.offset_bottom = 124.0
    root.add_child(robot_label)
    mission_label = Label.new()
    mission_label.anchor_left = 0.27
    mission_label.anchor_right = 0.75
    mission_label.offset_top = 18.0
    mission_label.offset_bottom = 80.0
    root.add_child(mission_label)

func _create_robot() -> void:
    robot = Node3D.new()
    robot.name = "TrainingRobot"
    robot.position = Vector3(-2.0, 1.0, -5.0)
    var visual := MeshInstance3D.new()
    var shape := BoxMesh.new()
    shape.size = Vector3(1.0, 1.6, 0.8)
    visual.mesh = shape
    robot_material = StandardMaterial3D.new()
    robot_material.albedo_color = Color("#54c7ed")
    visual.material_override = robot_material
    robot_visual = visual
    robot.add_child(visual)
    # Ground-level danger area telegraphs the same range used by the hit check.
    robot_warning_zone = MeshInstance3D.new()
    robot_warning_zone.name = "RobotWarningZone"
    var zone_mesh := CylinderMesh.new()
    zone_mesh.top_radius = ROBOT_RANGE
    zone_mesh.bottom_radius = ROBOT_RANGE
    zone_mesh.height = 0.035
    robot_warning_zone.mesh = zone_mesh
    robot_warning_zone.position.y = -0.96
    var zone_material := StandardMaterial3D.new()
    zone_material.albedo_color = Color(1.0, 0.18, 0.12, 0.24)
    zone_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    zone_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    zone_material.no_depth_test = false
    robot_warning_zone.material_override = zone_material
    robot_warning_zone.visible = false
    robot.add_child(robot_warning_zone)
    add_child(robot)
    _update_robot_label()

func attack_robot() -> bool:
    if adventure_focus_paused:
        return false
    if not is_instance_valid(player) or not is_instance_valid(robot) or robot_stunned or player_attack_cooldown > 0.0:
        return false
    if player.global_position.distance_to(robot.global_position) > ROBOT_RANGE:
        return false
    player_attack_cooldown = 0.65
    robot_hits += 1
    robot_feedback = "TREFFER! Roboter %d/2" % robot_hits
    robot_warning = 0.0
    robot_cooldown = 2.0
    if robot_hits >= 2:
        robot_stunned = true
        robot.visible = false
        _update_mission_label()
    _update_robot_label()
    _update_robot_visual()
    return true

func guard_robot() -> void:
    if adventure_focus_paused:
        return
    # Prevent holding/repeatedly tapping guard from granting permanent invulnerability.
    if robot_guard_cooldown > 0.0 or robot_stunned:
        return
    robot_guard = 0.8
    robot_guard_cooldown = 2.0
    robot_feedback = "SCHILD AKTIV"
    _update_hero_guard_visual()
    _update_robot_label()

func _resolve_robot_strike() -> void:
    # Distance is checked when the telegraph ends: stepping away is a dodge.
    robot_last_hit = player.global_position.distance_to(robot.global_position) <= ROBOT_RANGE and robot_guard <= 0.0
    robot_feedback = "TREFFER ERHALTEN" if robot_last_hit else "ABGEWEHRT" if robot_guard > 0.0 and player.global_position.distance_to(robot.global_position) <= ROBOT_RANGE else "AUSGEWICHEN"
    if robot_last_hit:
        robot_energy = maxi(0, robot_energy - 1)
        if robot_energy == 0:
            # Training encounter resets locally; never silently drains runner lives.
            robot_energy = 3
            player.respawn()
            pressed.clear()
            mobile_axis = Vector2.ZERO
            robot_feedback = "ENERGIE LEER – CHECKPOINT"
    _update_robot_label()

func _update_hero_guard_visual() -> void:
    if hero_material == null:
        return
    # The walking hero shows an in-world shield cue, not just HUD text.
    hero_material.albedo_color = Color("#65f5c7") if robot_guard > 0.0 else Color("#d7e9ff")
    var shield := player.get_node_or_null("WalkingShield") as MeshInstance3D if is_instance_valid(player) else null
    if shield != null:
        shield.visible = robot_guard > 0.0

func _update_robot_visual() -> void:
    if robot_material == null:
        return
    # Visible telegraph, independent of the HUD text and mobile screen size.
    robot_material.albedo_color = Color("#ff6655") if robot_warning > 0.0 and not robot_stunned else Color("#54c7ed")
    # Make the incoming strike legible in the 3D scene even on a small phone.
    # Scale only the robot mesh, never its node/range or the runner character.
    if is_instance_valid(robot_visual):
        robot_visual.scale = Vector3.ONE * (1.14 if robot_warning > 0.0 and not robot_stunned else 1.0)
    if is_instance_valid(robot_warning_zone):
        robot_warning_zone.visible = robot_warning > 0.0 and not robot_stunned

func _update_robot_label() -> void:
    if robot_label == null:
        return
    if robot_stunned:
        robot_label.text = "Roboter deaktiviert"
    elif robot_warning > 0.0:
        robot_label.text = "ACHTUNG: Ausweichen oder ABWEHR! Energie %d/3" % robot_energy
    else:
        robot_label.text = "Roboter: %d/2 Treffer | Energie %d/3" % [robot_hits, robot_energy]
    if robot_feedback != "" and not robot_stunned:
        robot_label.text += " | " + robot_feedback

func _update_return_button() -> void:
    if return_button == null:
        return
    var unlocked := mission_complete and robot_stunned
    var in_range := is_instance_valid(player) and player.global_position.distance_to(to_global(EXIT_PORTAL_POSITION)) <= EXIT_PORTAL_RADIUS
    return_button.disabled = adventure_focus_paused or not unlocked or not in_range
    return_button.tooltip_text = "Zum grünen Ausgangsportal gehen" if unlocked and not in_range else "Erst Mission und Roboter abschließen" if not unlocked else "Zurück zum Hoverboard"

func _request_return() -> void:
    if adventure_focus_paused:
        return
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
    material.albedo_color = Color("#ff6655")
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.albedo_color.a = 0.35
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    portal_material = material
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
    if adventure_focus_paused:
        return false
    if not is_instance_valid(player):
        return false
    # When two objectives overlap the interaction radius, select the closest
    # visible one rather than the first item created in the scene.
    var nearest: Node3D = null
    var nearest_distance := INTERACT_RADIUS
    for target in mission_targets:
        if not target.visible:
            continue
        var distance := player.global_position.distance_to(target.global_position)
        if distance <= nearest_distance:
            nearest = target
            nearest_distance = distance
    if nearest != null:
        var target := nearest
        target.visible = false
        if target.name.begins_with("Crystal"):
            crystals_collected += 1
        else:
            switches_activated += 1
        mission_complete = crystals_collected == 3 and switches_activated == 2
        _update_mission_label()
        return true
    return false

func _update_objective_guidance() -> void:
    # A4: Tell mobile players what is actually reachable without pop-up quizzes.
    if mission_label == null or not is_instance_valid(player):
        return
    var guidance := ""
    var closest_distance := INF
    for target in mission_targets:
        if not target.visible:
            continue
        var distance := player.global_position.distance_to(target.global_position)
        if distance < closest_distance:
            closest_distance = distance
            guidance = "INTERAKTION: " + ("Kristall" if target.name.begins_with("Crystal") else "Schalter")
    if closest_distance <= INTERACT_RADIUS:
        mission_label.tooltip_text = guidance
        mission_label.text = mission_label.text.get_slice("\n", 0) + "\n" + guidance
    elif closest_distance < INF:
        # Give an actionable distance cue instead of leaving players to guess
        # where the next crystal or switch is in the 3D rooftop arena.
        mission_label.tooltip_text = guidance + " in %d m" % ceili(closest_distance)
        mission_label.text = mission_label.text.get_slice("\n", 0) + "\n" + mission_label.tooltip_text
    elif mission_complete and robot_stunned:
        mission_label.tooltip_text = "Ausgangsportal in %d m – AUFSTEIGEN" % ceili(player.global_position.distance_to(to_global(EXIT_PORTAL_POSITION)))
        mission_label.text = mission_label.text.get_slice("\n", 0) + "\n" + mission_label.tooltip_text
    elif mission_complete:
        mission_label.tooltip_text = "Roboter in %d m – ANGRIFF / ABWEHR" % ceili(player.global_position.distance_to(robot.global_position)) if is_instance_valid(robot) else "Roboter suchen"
        mission_label.text = mission_label.text.get_slice("\n", 0) + "\n" + mission_label.tooltip_text
    else:
        mission_label.tooltip_text = "Kristalle sammeln und Schalter aktivieren"
        mission_label.text = mission_label.text.get_slice("\n", 0) + "\n" + mission_label.tooltip_text

func _update_mission_label() -> void:
    # Portal stays visibly locked until the complete mission AND robot encounter.
    if portal_material != null:
        var tint := Color("#35f0ba") if mission_complete and robot_stunned else Color("#ff6655")
        tint.a = 0.35
        portal_material.albedo_color = tint
    if mission_label != null:
        mission_label.text = "Kristalle %d/3 | Schalter %d/2 | %s" % [crystals_collected, switches_activated, "PORTAL BEREIT" if mission_complete and robot_stunned else "Roboter besiegen" if mission_complete else "Portal gesperrt"]

func _retry_from_ui() -> void:
    if adventure_focus_paused:
        return
    reset_mission()

func reset_mission() -> void:
    # Retry is a fresh on-foot attempt: restore the checkpoint and clear
    # any held touch direction so the hero cannot drift into another hazard.
    pressed.clear()
    mobile_axis = Vector2.ZERO
    if is_instance_valid(player):
        player.respawn()
    crystals_collected = 0
    switches_activated = 0
    mission_complete = false
    for target in mission_targets:
        target.visible = true
    robot_hits = 0
    player_attack_cooldown = 0.0
    robot_warning = 0.0
    robot_cooldown = 0.0
    robot_stunned = false
    robot_energy = 3
    robot_guard = 0.0
    robot_guard_cooldown = 0.0
    robot_last_hit = false
    robot_feedback = ""
    if is_instance_valid(robot):
        robot.visible = true
    _update_robot_label()
    _update_robot_visual()
    _update_hero_guard_visual()
    _update_mission_label()
    _update_return_button()

func _contextual_interact() -> void:
    # Mobile and keyboard share one contextual action at the exit portal.
    if not interact():
        _request_return()

func _unhandled_key_input(event: InputEvent) -> void:
    if adventure_focus_paused:
        return
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
        # One contextual key for the full adventure: collect/activate nearby
        # objectives, then remount only at the unlocked exit portal.
        _contextual_interact()
    elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
        attack_robot()
    elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_G:
        guard_robot()
    elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
        # Desktop retry matches the mobile button without restarting the quiz/race.
        _retry_from_ui()

func _mobile_jump() -> void:
    # Safari can deliver a queued touch after focus loss; never replay it on resume.
    if adventure_focus_paused or not is_instance_valid(player):
        return
    player.mobile_jump()

func _sync_axis() -> void:
    if adventure_focus_paused:
        pressed.clear()
        mobile_axis = Vector2.ZERO
        return
    mobile_axis = Vector2.ZERO
    for direction in pressed:
        mobile_axis += direction
    mobile_axis = mobile_axis.limit_length(1.0)

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        adventure_focus_paused = true
        pressed.clear()
        mobile_axis = Vector2.ZERO
        if is_instance_valid(player):
            player.set_mobile_move(Vector2.ZERO)
            # A held sprint touch may never receive button_up after Safari loses focus.
            # Clear it explicitly so returning to the tab cannot resume sprinting.
            player.set_mobile_sprint(false)
            # The walking CharacterBody owns its own physics callback; pausing
            # only the arena would still advance gravity and keyboard movement.
            player.set_physics_process(false)
    elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
        adventure_focus_paused = false
        if is_instance_valid(player):
            player.set_physics_process(true)
