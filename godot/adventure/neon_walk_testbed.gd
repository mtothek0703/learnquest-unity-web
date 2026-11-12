extends Node3D
## Standalone walkable A1 testbed. Run neon_walk_testbed.tscn directly.
signal return_requested
const PlayerScript = preload("res://adventure/neon_walk_player.gd")
const FacadeShader = preload("res://adventure/neon_city_facade.gdshader")
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
var robot_warning_material: StandardMaterial3D
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
var crystal_float_phase := 0.0
var portal_pulse_phase := 0.0

func _ready() -> void:
    _platform(Vector3(0, -0.5, 0), Vector3(18, 1, 18), Color("#263456"))
    _platform(Vector3(4, 0.5, -4), Vector3(4, 1, 4), Color("#395c87"))
    _platform(Vector3(4, 1.7, -8), Vector3(4, 1, 4), Color("#317b99"))
    _build_neon_skyline()
    _build_rooftop_art_pass()
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
    follow_camera.position = Vector3(0, 2.55, 4.0)
    follow_camera.current = true
    add_child(follow_camera)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-45, -25, 0)
    light.light_color = Color("#b7c7fa")
    light.light_energy = 0.9
    add_child(light)
    # Balanced midnight atmosphere: soft ambient fill lets the character
    # and dark building materials read on a small landscape phone screen.
    var atmosphere := WorldEnvironment.new()
    atmosphere.name = "NeonCityNightAtmosphere"
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#07162d")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#46629c")
    environment.ambient_light_energy = 0.9
    atmosphere.environment = environment
    add_child(atmosphere)
    _make_touch_controls()
    _create_mission()
    _create_exit_portal()
    _create_robot()

# Visual-only, low-draw-call rooftop skyline. Buildings stay outside the
# playable collision arena; no new physics bodies or runner changes.
# Emissive trims remain readable in the mobile Compatibility renderer.
func _build_neon_skyline() -> void:
    var skyline := Node3D.new()
    skyline.name = "NeonCitySkyline"
    add_child(skyline)
    # A full floor of tiny lit/empty window modules comes from one shader,
    # not hundreds of mobile-expensive MeshInstances. Each tower has a
    # deterministic window pattern and warm/cool illuminated rooms.
    var trim_cyan := StandardMaterial3D.new()
    trim_cyan.albedo_color = Color("#48cde9")
    trim_cyan.emission_enabled = true
    trim_cyan.emission = Color("#48cde9")
    trim_cyan.emission_energy_multiplier = 1.6
    var trim_pink := StandardMaterial3D.new()
    trim_pink.albedo_color = Color("#ed65b8")
    trim_pink.emission_enabled = true
    trim_pink.emission = Color("#ed65b8")
    trim_pink.emission_energy_multiplier = 1.4
    var locations := [
        Vector3(-15.0, 0.0, -14.0), Vector3(-8.0, 0.0, -19.0),
        Vector3(1.0, 0.0, -20.0), Vector3(12.0, 0.0, -17.0),
        Vector3(17.0, 0.0, -8.0), Vector3(-18.0, 0.0, 3.0)
    ]
    var heights := [9.0, 14.0, 11.0, 16.0, 10.0, 12.0]
    for i in range(locations.size()):
        var tower := Node3D.new()
        tower.name = "Tower%d" % i
        tower.position = locations[i]
        skyline.add_child(tower)
        var height: float = heights[i]
        var width := 3.2 if i % 2 == 0 else 4.2
        var body := MeshInstance3D.new()
        body.name = "Facade"
        # A single custom lofted mesh replaces the flat box silhouette.
        # The stepped, tapered profile is visible against the night sky
        # while keeping one draw call per facade and the existing window shader.
        body.mesh = _sculpted_tower_mesh(width, height, width * 0.82, i)
        var window_material := ShaderMaterial.new()
        window_material.shader = FacadeShader
        window_material.set_shader_parameter("panel_tint", Color("#152544") if i % 2 == 0 else Color("#22243e"))
        window_material.set_shader_parameter("facade_seed", float(i + 1) * 13.7)
        window_material.set_shader_parameter("columns", 6.0 if i % 2 == 0 else 8.0)
        window_material.set_shader_parameter("rows", float(roundi(height * 1.30)))
        body.material_override = window_material
        body.position.y = height * 0.5 - 0.5
        tower.add_child(body)
        # Horizontal light bands communicate scale without dozens of windows.
        var neon: StandardMaterial3D = trim_cyan if i % 2 == 0 else trim_pink
        for band in range(3):
            var strip := MeshInstance3D.new()
            strip.name = "LightBand%d" % band
            var strip_mesh := BoxMesh.new()
            strip_mesh.size = Vector3(width + 0.08, 0.10, width * 0.82 + 0.08)
            strip.mesh = strip_mesh
            strip.material_override = neon
            strip.position.y = height * (0.30 + float(band) * 0.25) - 0.5
            tower.add_child(strip)
        # Real secondary geometry breaks the primitive box silhouette:
        # rooftop crowns, side fins and a readable holographic destination sign.
        var crown := MeshInstance3D.new()
        crown.name = "RoofCrown"
        var crown_mesh := BoxMesh.new()
        crown_mesh.size = Vector3(width + 0.36, 0.28, width * 0.82 + 0.36)
        crown.mesh = crown_mesh
        crown.material_override = trim_cyan if i % 2 == 0 else trim_pink
        crown.position.y = height - 0.43
        tower.add_child(crown)
        for fin in [-1.0, 1.0]:
            var facade_fin := MeshInstance3D.new()
            facade_fin.name = "FacadeFinLeft" if fin < 0.0 else "FacadeFinRight"
            var fin_mesh := BoxMesh.new()
            fin_mesh.size = Vector3(0.12, height * 0.85, 0.18)
            facade_fin.mesh = fin_mesh
            facade_fin.material_override = neon
            facade_fin.position = Vector3(fin * width * 0.48, height * 0.48 - 0.5, width * 0.41)
            tower.add_child(facade_fin)
        var sign_label := Label3D.new()
        sign_label.name = "CityLandmarkSign"
        sign_label.text = ["NOVA", "ASTRA", "VOLT", "ORBIT", "NEXUS", "SKYLINE"][i]
        sign_label.font_size = 52
        sign_label.pixel_size = 0.008
        sign_label.outline_size = 10
        sign_label.modulate = Color("#b7ffff") if i % 2 == 0 else Color("#ffc2ec")
        sign_label.outline_modulate = Color("#101b34")
        sign_label.position = Vector3(0, height * 0.72 - 0.5, width * 0.415 + 0.18)
        tower.add_child(sign_label)
        # A small antenna gives each silhouette a readable rooftop landmark.
        var antenna := MeshInstance3D.new()
        antenna.name = "Beacon"
        var antenna_mesh := CylinderMesh.new()
        antenna_mesh.top_radius = 0.06
        antenna_mesh.bottom_radius = 0.14
        antenna_mesh.height = 1.5
        antenna.mesh = antenna_mesh
        antenna.material_override = neon
        antenna.position.y = height + 0.25
        tower.add_child(antenna)

# Deterministic low-poly architecture, authored as a single UV-mapped mesh.
# Two setbacks and a narrow rooftop shoulder give the towers a genuine
# architectural silhouette instead of a stack of box primitives.
# No new collision or runtime animation; all six towers together remain
# comfortably below 300 triangles for the facade geometry.
func _sculpted_tower_mesh(width: float, height: float, depth: float, tower_index: int) -> ArrayMesh:
    # Chamfered octagonal footprint, recessed mid-level and tiered roofline.
    # One mesh/surface per tower keeps draw calls low for mobile WebGL.
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    var profiles := [
        Vector3(width, -height * 0.5, depth),
        Vector3(width, -height * 0.15, depth),
        Vector3(width * 0.91, -height * 0.13, depth * 0.91),
        Vector3(width * 0.91, height * 0.18, depth * 0.91),
        Vector3(width * 0.78, height * 0.21, depth * 0.78),
        Vector3(width * 0.78, height * 0.39, depth * 0.78),
        Vector3(width * 0.63, height * 0.43, depth * 0.63),
        Vector3(width * 0.63, height * 0.5, depth * 0.63)
    ]
    if tower_index % 3 == 1:
        for i in range(4, profiles.size()):
            profiles[i].x *= 0.83
    var corners := [
        Vector2(-0.34, -0.5), Vector2(0.34, -0.5),
        Vector2(0.5, -0.34), Vector2(0.5, 0.34),
        Vector2(0.34, 0.5), Vector2(-0.34, 0.5),
        Vector2(-0.5, 0.34), Vector2(-0.5, -0.34)
    ]
    for level in range(profiles.size() - 1):
        var lower: Vector3 = profiles[level]
        var upper: Vector3 = profiles[level + 1]
        var v0 := float(level) / float(profiles.size() - 1)
        var v1 := float(level + 1) / float(profiles.size() - 1)
        for side in range(corners.size()):
            var c0: Vector2 = corners[side]
            var c1: Vector2 = corners[(side + 1) % corners.size()]
            var p0 := Vector3(c0.x * lower.x, lower.y, c0.y * lower.z)
            var p1 := Vector3(c1.x * lower.x, lower.y, c1.y * lower.z)
            var q0 := Vector3(c0.x * upper.x, upper.y, c0.y * upper.z)
            var q1 := Vector3(c1.x * upper.x, upper.y, c1.y * upper.z)
            var u0 := float(side) / float(corners.size())
            var u1 := float(side + 1) / float(corners.size())
            for vertex in [[p0, Vector2(u0, v0)], [q0, Vector2(u0, v1)], [p1, Vector2(u1, v0)],
                    [p1, Vector2(u1, v0)], [q0, Vector2(u0, v1)], [q1, Vector2(u1, v1)]]:
                surface.set_uv(vertex[1])
                surface.add_vertex(vertex[0])
    surface.generate_normals()
    return surface.commit()

# Decorative but genuinely three-dimensional playable-rooftop dressing:
# light rails make the walkable boundary legible, two service vents add
# silhouette rhythm and a few non-shadow-casting lamps illuminate the hero.
# No collision nodes or changes to the actual movement path.
func _build_rooftop_art_pass() -> void:
    var art := Node3D.new()
    art.name = "NeonRooftopDetails"
    add_child(art)
    var neon := StandardMaterial3D.new()
    neon.albedo_color = Color("#64e9ec")
    neon.emission_enabled = true
    neon.emission = Color("#64e9ec")
    neon.emission_energy_multiplier = 1.4
    var dark_metal := StandardMaterial3D.new()
    dark_metal.albedo_color = Color("#14233e")
    dark_metal.metallic = 0.5
    dark_metal.roughness = 0.42
    for side in [-1.0, 1.0]:
        var longitudinal := MeshInstance3D.new()
        longitudinal.name = "NeonBoundaryLong"
        var long_mesh := BoxMesh.new()
        long_mesh.size = Vector3(0.075, 0.035, 17.35)
        longitudinal.mesh = long_mesh
        longitudinal.material_override = neon
        longitudinal.position = Vector3(side * 8.75, 0.042, 0)
        art.add_child(longitudinal)
        var transverse := MeshInstance3D.new()
        transverse.name = "NeonBoundaryShort"
        var short_mesh := BoxMesh.new()
        short_mesh.size = Vector3(17.35, 0.035, 0.075)
        transverse.mesh = short_mesh
        transverse.material_override = neon
        transverse.position = Vector3(0, 0.042, side * 8.75)
        art.add_child(transverse)
    for position in [Vector3(-6.9, 0, -6.9), Vector3(6.9, 0, 6.9)]:
        var mechanical := MeshInstance3D.new()
        mechanical.name = "RooftopVent"
        var vent_mesh := CylinderMesh.new()
        vent_mesh.top_radius = 0.58
        vent_mesh.bottom_radius = 0.70
        vent_mesh.height = 0.55
        vent_mesh.radial_segments = 8
        mechanical.mesh = vent_mesh
        mechanical.material_override = dark_metal
        mechanical.position = position + Vector3.UP * 0.27
        art.add_child(mechanical)
    for i in range(2):
        var light_source := OmniLight3D.new()
        light_source.name = "NeonHeroFillLight%d" % i
        light_source.position = Vector3(-6.7 if i == 0 else 6.7, 3.1, -1.7 if i == 0 else 3.0)
        light_source.light_color = Color("#4ddcfa") if i == 0 else Color("#df81dc")
        light_source.light_energy = 0.85
        light_source.omni_range = 12.0
        light_source.shadow_enabled = false
        art.add_child(light_source)

func _install_walking_character(fallback: MeshInstance3D) -> void:
    # The original, animated Blender GLB takes precedence in the Adventure
    # vertical slice. A missing/invalid import safely keeps the existing glTF.
    # No change to the hoverboard hero or other stable worlds.
    const RIGGED_CHARACTER_PATH := "res://assets/3d/learnquest_walk_hero.glb"
    const CHARACTER_PATH := "res://models/rider.gltf"
    var character_path: String = RIGGED_CHARACTER_PATH if ResourceLoader.exists(RIGGED_CHARACTER_PATH) else CHARACTER_PATH
    if not ResourceLoader.exists(character_path):
        return
    var resource := load(character_path) as PackedScene
    if resource == null and character_path != CHARACTER_PATH:
        resource = load(CHARACTER_PATH) as PackedScene
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
        elif robot_cooldown <= 0.0 and _robot_ground_distance() <= ROBOT_RANGE:
            robot_warning = 1.2
            _update_robot_label()
            _update_robot_visual()
    if is_instance_valid(follow_camera) and follow_camera.current:
        _update_follow_camera()
    _animate_robot_telegraph()
    # Pulse the ground danger marker throughout the telegraph, not just on entry.
    # Pulse inward only: the visible ring never promises a larger hit radius than the real strike.
    if is_instance_valid(robot_warning_zone) and robot_warning_zone.visible:
        var warning_pulse := 0.96 + 0.04 * sin(robot_warning * 12.0)
        robot_warning_zone.scale = Vector3(warning_pulse, 1.0, warning_pulse)
        # The approaching strike becomes more opaque, without changing hit range.
        if is_instance_valid(robot_warning_material):
            var urgency := clampf(1.0 - robot_warning / 1.2, 0.0, 1.0)
            robot_warning_material.albedo_color.a = lerpf(0.24, 0.62, urgency)
    crystal_float_phase += delta * 3.0
    # Animate only remaining mission pickups in the active walking scene.
    # This makes collectible crystals easier to distinguish from static scenery.
    for target in mission_targets:
        if target.visible and target.name.begins_with("Crystal"):
            var pickup_visual := target.get_node_or_null("PickupVisual") as MeshInstance3D
            if pickup_visual != null:
                pickup_visual.rotate_y(delta * 1.8)
                # Time-based floating makes crystals stand out without accumulating drift.
                pickup_visual.position.y = sin(crystal_float_phase + float(target.get_index())) * 0.12
    # A4: An unlocked exit visibly pulses; locked exits remain still.
    var exit_visual := get_node_or_null("ExitPortal") as MeshInstance3D
    if exit_visual != null:
        if mission_complete and robot_stunned:
            portal_pulse_phase += delta * 2.5
            var pulse := 1.0 + 0.08 * (0.5 + 0.5 * sin(portal_pulse_phase))
            exit_visual.scale = Vector3(pulse, 1.0, pulse)
        else:
            exit_visual.scale = Vector3.ONE
    _update_objective_guidance()
    _update_return_button()

func _update_follow_camera() -> void:
    # Keep the walking camera out of rooftop geometry. The runner camera is untouched.
    var focus := player.global_position + Vector3.UP * 0.75
    var desired := player.global_position + Vector3(0, 2.55, 4.0)
    var query := PhysicsRayQueryParameters3D.create(focus, desired)
    query.exclude = [player.get_rid()]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if not hit.is_empty():
        desired = (hit["position"] as Vector3) + (hit["normal"] as Vector3) * 0.25
    # Smooth free-space pursuit to reduce abrupt framing changes on mobile.
    # On obstruction, snap to the safe raycast point immediately so smoothing
    # cannot carry the camera through rooftop geometry.
    var blocked := not hit.is_empty()
    var camera_blend := clampf(get_physics_process_delta_time() * 9.0, 0.0, 1.0)
    follow_camera.global_position = desired if blocked else follow_camera.global_position.lerp(desired, camera_blend)
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

# Shared box meshes use only three materials and no physics bodies.
func _robot_box(parent: Node3D, part_name: String, at: Vector3, size: Vector3, material: StandardMaterial3D) -> void:
    var part := MeshInstance3D.new()
    part.name = part_name
    var part_mesh := BoxMesh.new()
    part_mesh.size = size
    part.mesh = part_mesh
    part.position = at
    part.material_override = material
    parent.add_child(part)

func _create_robot() -> void:
    robot = Node3D.new()
    robot.name = "TrainingRobot"
    robot.position = Vector3(-2.0, 1.0, -5.0)
    var visual := MeshInstance3D.new()
    # Beveled, tapered armor torso with real side faces instead of a box.
    # All vertices are local to the existing robot visual, preserving gameplay.
    var torso := ArrayMesh.new()
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    var rings := [
        [0.83, 0.37, 0.28],
        [0.57, 0.55, 0.39],
        [-0.38, 0.47, 0.34],
        [-0.80, 0.31, 0.27]
    ]
    var sides := 8
    for ring_index in range(rings.size() - 1):
        for side in range(sides):
            var angle_a := TAU * float(side) / float(sides)
            var angle_b := TAU * float(side + 1) / float(sides)
            var top = rings[ring_index]
            var bottom = rings[ring_index + 1]
            var a := Vector3(cos(angle_a) * top[1], top[0], sin(angle_a) * top[2])
            var b := Vector3(cos(angle_b) * top[1], top[0], sin(angle_b) * top[2])
            var c := Vector3(cos(angle_a) * bottom[1], bottom[0], sin(angle_a) * bottom[2])
            var d := Vector3(cos(angle_b) * bottom[1], bottom[0], sin(angle_b) * bottom[2])
            for vertex in [a, c, b, b, c, d]:
                st.add_vertex(vertex)
    st.generate_normals()
    st.commit(torso)
    visual.mesh = torso
    robot_material = StandardMaterial3D.new()
    robot_material.albedo_color = Color("#54c7ed")
    visual.material_override = robot_material
    robot_visual = visual
    robot.add_child(visual)
    # Distinct readable training-bot silhouette: head, articulated-looking
    # limbs and emissive visor. Visual-only; strike range and collision stay
    # owned by the existing robot node and ROBOT_RANGE.
    var armor := StandardMaterial3D.new()
    armor.albedo_color = Color("#223652")
    armor.metallic = 0.25
    var visor := StandardMaterial3D.new()
    visor.albedo_color = Color("#8cf5ff")
    visor.emission_enabled = true
    visor.emission = Color("#49dff5")
    visor.emission_energy_multiplier = 1.5
    _robot_box(visual, "Head", Vector3(0, 1.10, 0), Vector3(0.70, 0.56, 0.63), armor)
    _robot_box(visual, "Visor", Vector3(0, 1.12, -0.335), Vector3(0.49, 0.18, 0.055), visor)
    _robot_box(visual, "LeftShoulder", Vector3(-0.70, 0.48, 0), Vector3(0.42, 0.30, 0.48), armor)
    _robot_box(visual, "RightShoulder", Vector3(0.70, 0.48, 0), Vector3(0.42, 0.30, 0.48), armor)
    _robot_box(visual, "LeftArm", Vector3(-0.72, -0.13, 0), Vector3(0.28, 0.90, 0.32), robot_material)
    _robot_box(visual, "RightArm", Vector3(0.72, -0.13, 0), Vector3(0.28, 0.90, 0.32), robot_material)
    _robot_box(visual, "LeftLeg", Vector3(-0.28, -1.03, 0), Vector3(0.32, 0.70, 0.42), armor)
    _robot_box(visual, "RightLeg", Vector3(0.28, -1.03, 0), Vector3(0.32, 0.70, 0.42), armor)
    _robot_box(visual, "CoreLight", Vector3(0, 0.20, -0.43), Vector3(0.27, 0.27, 0.05), visor)
    # Ground-level danger area telegraphs the same range used by the hit check.
    robot_warning_zone = MeshInstance3D.new()
    robot_warning_zone.name = "RobotWarningZone"
    # A thin boundary ring replaces the large opaque danger disk. This keeps
    # the hero, floor and mission objects visible during the 1.2s telegraph,
    # while marking the same exact ROBOT_RANGE used by the hit check.
    var zone_mesh := TorusMesh.new()
    zone_mesh.inner_radius = ROBOT_RANGE - 0.18
    zone_mesh.outer_radius = ROBOT_RANGE
    zone_mesh.rings = 12
    zone_mesh.ring_segments = 48
    robot_warning_zone.mesh = zone_mesh
    robot_warning_zone.position.y = -0.96
    var zone_material := StandardMaterial3D.new()
    zone_material.albedo_color = Color(1.0, 0.18, 0.12, 0.24)
    zone_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    zone_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    zone_material.no_depth_test = false
    robot_warning_zone.material_override = zone_material
    robot_warning_material = zone_material
    robot_warning_zone.visible = false
    robot.add_child(robot_warning_zone)
    add_child(robot)
    _update_robot_label()

# The telegraph is a ground-plane circle; vertical platform height must not
# silently shrink its reach or disagree with the warning decal.
func _robot_ground_distance() -> float:
    if not is_instance_valid(player) or not is_instance_valid(robot):
        return INF
    var delta := player.global_position - robot.global_position
    return Vector2(delta.x, delta.z).length()

func attack_robot() -> bool:
    if adventure_focus_paused:
        return false
    if not is_instance_valid(player) or not is_instance_valid(robot) or robot_stunned or player_attack_cooldown > 0.0:
        return false
    if _robot_ground_distance() > ROBOT_RANGE:
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
    robot_last_hit = _robot_ground_distance() <= ROBOT_RANGE and robot_guard <= 0.0
    robot_feedback = "TREFFER ERHALTEN" if robot_last_hit else "ABGEWEHRT" if robot_guard > 0.0 and _robot_ground_distance() <= ROBOT_RANGE else "AUSGEWICHEN"
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
    if is_instance_valid(player):
        var shield := player.get_node_or_null("WalkingShield") as MeshInstance3D
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
        if not robot_warning_zone.visible:
            robot_warning_zone.scale = Vector3.ONE
            if is_instance_valid(robot_warning_material):
                robot_warning_material.albedo_color.a = 0.24

# Animate the actual training-bot silhouette during its 1.2-second warning.
# Only visual child transforms change; attack range and timers stay untouched.
func _animate_robot_telegraph() -> void:
    if not is_instance_valid(robot_visual):
        return
    var raised := clampf(1.0 - robot_warning / 1.2, 0.0, 1.0) if robot_warning > 0.0 and not robot_stunned else 0.0
    var left_arm := robot_visual.get_node_or_null("LeftArm") as Node3D
    var right_arm := robot_visual.get_node_or_null("RightArm") as Node3D
    # Raise each forearm toward its shoulder while rotating outward. Rotating
    # only around the old arm center made the hands swing sideways/downward,
    # which read poorly as an attack wind-up from the chase camera.
    if left_arm != null:
        left_arm.position = Vector3(-0.72 - 0.12 * raised, -0.13 + 0.35 * raised, 0.0)
        left_arm.rotation.z = -0.9 * raised
    if right_arm != null:
        right_arm.position = Vector3(0.72 + 0.12 * raised, -0.13 + 0.35 * raised, 0.0)
        right_arm.rotation.z = 0.9 * raised
    var visor := robot_visual.get_node_or_null("Visor") as MeshInstance3D
    if visor != null:
        visor.scale.x = 1.0 + 0.18 * raised

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
    # Switches are flat, fixed consoles; crystals remain floating spheres.
    if id.begins_with("Switch"):
        var switch_mesh := BoxMesh.new()
        switch_mesh.size = Vector3(0.85, 0.35, 0.85)
        visual.mesh = switch_mesh
    else:
        var crystal_mesh := SphereMesh.new()
        crystal_mesh.radius = 0.42
        crystal_mesh.height = 0.84
        visual.mesh = crystal_mesh
    visual.name = "PickupVisual"
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
        mission_label.tooltip_text = "Roboter in %d m – ANGRIFF / ABWEHR" % ceili(_robot_ground_distance()) if is_instance_valid(robot) else "Roboter suchen"
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
    crystal_float_phase = 0.0
    portal_pulse_phase = 0.0
    var exit_visual := get_node_or_null("ExitPortal") as MeshInstance3D
    if exit_visual != null:
        exit_visual.scale = Vector3.ONE
    for target in mission_targets:
        target.visible = true
        # A retry must restore collectible presentation as well as mission state.
        var pickup_visual := target.get_node_or_null("PickupVisual") as MeshInstance3D
        if pickup_visual != null:
            pickup_visual.rotation = Vector3.ZERO
            pickup_visual.position = Vector3.ZERO
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
