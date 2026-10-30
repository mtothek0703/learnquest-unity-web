extends Node3D

# LearnQuest 3D: mobile-first Godot 4 browser prototype, no third-party assets.
const WORDS := [
    [["Hund","dog"],["Katze","cat"],["Sonne","sun"],["Apfel","apple"],["Haus","house"],["Buch","book"]],
    [["Brücke","bridge"],["Garten","garden"],["Wetter","weather"],["Schule","school"],["Freund","friend"],["Fenster","window"]],
    [["Abenteuer","adventure"],["Umwelt","environment"],["Entscheidung","decision"],["Erfahrung","experience"],["entdecken","discover"],["wichtig","important"]]
]
# Complete vocabulary missions first; racing is a continuous, finite level.
const TASKS_PER_ROUND := 3
const VERSION_LABEL := "V124"
const TouchGestures = preload("res://touch_gestures.gd")
const WORLD_NAMES := ["NEON CITY", "KRISTALL-CANYON", "STERNEN-HAFEN", "AURORA-GLETSCHER"]
const WORLD_GOALS := [800.0, 950.0, 1100.0, 1200.0]
const HARBOR_BONUS_TARGET := 4
const HARBOR_RELAY_TARGET := 3
const GLACIER_BONUS_TARGET := 3
const CANYON_ROUTE_TARGET := 3
const NEON_SIGNAL_TARGET := 4
const SHIELD_COST := 30
const MEGA_JUMP_COST := 30
const ATTACK_COST := 45
const GUARDIAN_HEALTH := 3
const GUARDIAN_SPAWN_FRACTION := 0.55
const ORBIT_HEALTH := 2
const ORBIT_SPAWN_FRACTION := 0.60
const FROST_HEALTH := 3
const FROST_SPAWN_FRACTION := 0.65
var phase := "menu" # menu -> training -> race -> results
var training_correct := 0
var round_number := 1
var rounds_finished := 0
var world_choice := 0
var total_stars := 0
var total_reward_xp := 0
var mission_target := 800.0
var lane := 0
var grade := 5
var xp := 0
var power := 0
var speed := 14.0
var distance := 0.0
var started := false
var quiz_active := false
var quiz_time := 7.0
var correct_index := 0
# Prevent back-to-back repetitions of the same English vocabulary challenge.
var previous_quiz_index := -1
var options: Array[int] = []
var answer_buttons: Array[Button] = []
var combo := 0
var turbo_left := 0.0
var shield_left := 0.0
var attack_left := 0.0
var mega_jump_active := false
var jump_duration := 0.85
var jump_height := 1.8
var shield_visual: MeshInstance3D
var attack_visual: MeshInstance3D
var mega_jump_visual: MeshInstance3D
var powerups_grid: GridContainer
var rider: Node3D
var chase_camera: Camera3D
var hero_gallery: Node3D
var camera_focus := Vector3(0.0, 1.5, 0.5)
var showcase_clock := 0.0
var moving: Node3D
var skyway_zone: Node3D
var canyon_zone: Node3D
var harbor_zone: Node3D
var glacier_zone: Node3D
var harbor_crystals := 0
var guardian: Node3D
var guardian_beam: MeshInstance3D
var guardian_hp := GUARDIAN_HEALTH
var guardian_active := false
var guardian_defeated := false
var guardian_attack_timer := 0.0
var guardian_warning_left := 0.0
var guardian_lane := 0
var orbit_sentinel: Node3D
var orbit_beam: MeshInstance3D
var orbit_hp := ORBIT_HEALTH
var orbit_active := false
var orbit_defeated := false
var orbit_attack_timer := 0.0
var orbit_warning_left := 0.0
var orbit_lane := 0
var frost_warden: Node3D
var frost_warnings: Array[MeshInstance3D] = []
var frost_hp := FROST_HEALTH
var frost_active := false
var frost_defeated := false
var frost_attack_timer := 0.0
var frost_warning_left := 0.0
var frost_safe_lane := 0
var sky_material: ProceduralSkyMaterial
var world_button: Button
var progress_bar: ProgressBar
var reward_label: Label
var road_marks: Node3D
var run_items: Node3D
var lives := 3
var jump_left := 0.0
var hit_cooldown := 0.0
var end_panel: PanelContainer
var hud: Label
var hud_panel: PanelContainer
var mobile_hud_layout := false
# Wide touchscreen phones must still offer the optional gesture-only mode.
var touch_screen_mode := false
# A rotated/resized viewport invalidates active finger coordinates.
var last_touch_layout_width := -1.0
var last_touch_layout_height := -1.0
var splash: PanelContainer
var controls_grid: GridContainer
var touch_steering = TouchGestures.new()
var touch_buttons_visible := true
var gesture_toggle: Button
var gesture_hint: Label
var start_heading: Label
var end_heading: Label
var quiz_box: PanelContainer
var question_label: Label
var grade_label: Label
var info_label: Label
var feedback_time := 0.0
var style_dark: StyleBoxFlat

func _ready() -> void:
    _create_world()
    _create_ui()
    _refresh_hud()
    # Start directly with a front-facing hero portrait, not the old rear view.
    _update_camera(100.0)

# Browser tab switches, calls and app suspension do not always emit a
# ScreenTouch(canceled) event. Discard stale pointers and pending double taps
# when focus is lost, so a resumed drag cannot spend energy or jump.
func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        # Quarantine still-held pointers until all fingers lift.
        # reset() forgets them and can mistake another finger for a new jump.
        touch_steering.invalidate_focus(Time.get_ticks_msec())

func mat(color: Color, glow: bool = false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = 0.25
    m.roughness = 0.35
    if glow:
        m.emission_enabled = true
        m.emission = color
        m.emission_energy_multiplier = 2.0
        m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    return m

func cube(parent: Node3D, pos: Vector3, size: Vector3, color: Color, glow: bool = false) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    instance.mesh = mesh
    instance.material_override = mat(color, glow)
    instance.position = pos
    parent.add_child(instance)
    return instance

func sphere(parent: Node3D, pos: Vector3, scale_value: Vector3, color: Color, glow: bool = false) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radial_segments = 12
    mesh.rings = 6
    instance.mesh = mesh
    instance.material_override = mat(color, glow)
    instance.position = pos
    instance.scale = scale_value
    parent.add_child(instance)
    return instance

func _create_world() -> void:
    var env := WorldEnvironment.new()
    var resource := Environment.new()
    resource.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    sky_material = ProceduralSkyMaterial.new()
    # V14 visual overhaul: electric sunset instead of the old dark-blue sky.
    sky_material.sky_top_color = Color("#080d35")
    sky_material.sky_horizon_color = Color("#ff789b")
    sky_material.ground_horizon_color = Color("#ffbd8b")
    sky_material.ground_bottom_color = Color("#39265e")
    sky_material.use_debanding = true
    sky.sky_material = sky_material
    resource.sky = sky
    resource.background_color = Color("#211b51")
    resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    resource.ambient_light_color = Color("#ffe0f1")
    resource.ambient_light_energy = 1.18
    env.environment = resource
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-42, -28, 0)
    sun.light_color = Color("#ffe0bd")
    sun.light_energy = 1.6
    add_child(sun)

    chase_camera = Camera3D.new()
    chase_camera.name = "Dynamic chase camera"
    chase_camera.position = Vector3(0, 4.3, 9.0)
    chase_camera.fov = 64.0
    add_child(chase_camera)
    chase_camera.look_at(Vector3(0, 1.5, 0.5), Vector3.UP)
    chase_camera.current = true

    cube(self, Vector3(0, -0.35, -55), Vector3(11, 0.6, 160), Color("#141633"))
    for side in [-1, 1]:
        cube(self, Vector3(side * 5.5, 0, -55), Vector3(0.2, 0.3, 160), Color("#27f5ff"), true)
    road_marks = Node3D.new()
    road_marks.name = "Animated lane markers"
    add_child(road_marks)
    for z in range(-125, 20, 8):
        for side in [-1, 1]:
            cube(road_marks, Vector3(side * 1.8, -0.025, z), Vector3(0.15, 0.05, 3.4), Color("#ad62ff"), true)

    # A dedicated, articulated hero with its own hoverboard and procedural animation.
    var rider_scene: PackedScene = preload("res://rider_character.tscn")
    rider = rider_scene.instantiate()
    rider.name = "Animated Hover Hero"
    rider.position = Vector3(0, 0, 0.2)
    rider.scale = Vector3(1.55, 1.55, 1.55)
    add_child(rider)
    # Highly visible, temporary visual check anchored to the rider.
    var marker := OmniLight3D.new()
    marker.name = "Hero visibility marker"
    marker.light_color = Color("#26efff")
    marker.light_energy = 3.0
    marker.omni_range = 5.0
    rider.add_child(marker)
    marker.position = Vector3(0, 2, 0)
    # V88: mobile-friendly projected contact shadow, colored rim light and
    # Turbo speed ribbons; visual-only and independent of touch/physics.
    var rider_lighting := preload("res://rider_cinematic_lighting.gd").new() as Node3D
    rider_lighting.name = "Cinematic rider lighting"
    rider_lighting.set("rider", rider)
    add_child(rider_lighting)
    _create_powerup_effects()
    hero_gallery = preload("res://hero_gallery.gd").new() as Node3D
    hero_gallery.name = "Cinematic hero gallery"
    hero_gallery.position = Vector3(0.0, 0.0, 0.2)
    add_child(hero_gallery)

    var zone_script = preload("res://neon_environment.gd")
    skyway_zone = zone_script.new()
    skyway_zone.name = "LearnQuest Skyway world"
    add_child(skyway_zone)
    canyon_zone = preload("res://crystal_canyon.gd").new() as Node3D
    canyon_zone.name = "LearnQuest Crystal Canyon world"
    add_child(canyon_zone)
    canyon_zone.visible = false
    harbor_zone = preload("res://star_harbor.gd").new() as Node3D
    harbor_zone.name = "LearnQuest Star Harbor world"
    add_child(harbor_zone)
    harbor_zone.visible = false
    glacier_zone = preload("res://aurora_glacier.gd").new() as Node3D
    glacier_zone.name = "LearnQuest Aurora Glacier world"
    add_child(glacier_zone)
    glacier_zone.visible = false
    _create_guardian()
    _create_orbit_sentinel()
    _create_frost_warden()

    # Moving roadside silhouettes supplement the richer scrolling Skyway world.
    moving = Node3D.new()
    moving.name = "Moving city"
    add_child(moving)
    # Existing buildings and crystals share this scrolling scenery.
    for i in range(12):
        var side: int = -1 if i % 2 == 0 else 1
        var z := -14.0 - i * 11.5
        var height := float(5 + (i % 4) * 2)
        var root := Node3D.new()
        root.position = Vector3(side * (14 + (i % 3) * 2), 0, z)
        moving.add_child(root)
        cube(root, Vector3(0, height / 2.0, 0), Vector3(3.0, height, 3.0), Color("#202443"))
        for floor_index in range(1, int(height), 2):
            cube(root, Vector3(0, float(floor_index), -1.54), Vector3(2.65, 0.12, 0.06),
                Color("#21ecff") if i % 2 == 0 else Color("#fd47c1"), true)
        cube(root, Vector3(0, height, 0), Vector3(3.2, 0.25, 3.2), Color("#f9b135"), true)
    for i in range(12):
        var crystal := Node3D.new()
        crystal.position = Vector3(10.8 if i % 2 == 0 else -10.8, 1.5, -13.0 - i * 11.0)
        moving.add_child(crystal)
        cube(crystal, Vector3.ZERO, Vector3(1.4, 2.2, 1.4), Color("#39e5ff") if i % 2 == 0 else Color("#fd47c1"), true).rotation_degrees = Vector3(27, 45, 15)
    _create_run_items()
    _apply_world_theme()

func _create_guardian() -> void:
    # Original, sculpted 3D boss model; no external downloads.
    guardian = preload("res://canyon_guardian.gd").new() as Node3D
    guardian.name = "Crystal Guardian Boss"
    guardian.position = Vector3(0, 0.7, -20.0)
    add_child(guardian)
    guardian.visible = false
    guardian_beam = MeshInstance3D.new()
    guardian_beam.name = "Guardian telegraphed laser lane"
    var beam_mesh := BoxMesh.new()
    beam_mesh.size = Vector3(1.7, 0.12, 35.0)
    guardian_beam.mesh = beam_mesh
    guardian_beam.material_override = mat(Color("#ff547e"), true)
    guardian_beam.position = Vector3(0, 0.10, -13.0)
    add_child(guardian_beam)
    guardian_beam.visible = false

func _update_guardian(delta: float) -> void:
    # Guardian battle is uninterrupted, after the mid-race checkpoint.
    if world_choice != 1 or phase != "race" or not started or guardian_defeated:
        return
    if not guardian_active:
        if distance < mission_target * GUARDIAN_SPAWN_FRACTION:
            return
        guardian_active = true
        guardian.visible = true
        guardian.set("active", true)
        guardian_attack_timer = 2.8
        info_label.text = "BOSS: KRISTALL-WÄCHTER! ATTACKE EINSETZEN!"
        feedback_time = 2.5
    if guardian_warning_left > 0.0:
        guardian_warning_left -= delta
        if guardian_warning_left <= 0.0:
            guardian_warning_left = 0.0
            guardian_beam.visible = false
            if lane == guardian_lane and rider.position.y <= 0.85 and shield_left <= 0.0 and turbo_left <= 0.0 and hit_cooldown <= 0.0:
                lives -= 1
                hit_cooldown = 1.4
                info_label.text = "BOSS-LASER! NOCH %d LEBEN" % lives
                feedback_time = 1.5
                if lives <= 0:
                    _finish_run()
                    return
            else:
                info_label.text = "BOSS-STRAHL AUSGEWICHEN!"
                feedback_time = 1.1
            guardian_attack_timer = 5.0
        return
    guardian_attack_timer -= delta
    if guardian_attack_timer <= 0.0:
        guardian_lane = randi_range(-1, 1)
        guardian_warning_left = 1.35
        guardian_beam.position.x = float(guardian_lane) * 3.1
        guardian_beam.visible = true
        info_label.text = "WARNUNG! ROTE LASER-SPUR VERLASSEN!"
        feedback_time = 1.35

func _create_orbit_sentinel() -> void:
    # A second, distinct 3D boss uses curved original geometry and visible lane targeting.
    orbit_sentinel = preload("res://orbit_sentinel.gd").new() as Node3D
    orbit_sentinel.name = "Star Harbor Orbit Sentinel Boss"
    orbit_sentinel.position = Vector3(0, 1.1, -23.0)
    add_child(orbit_sentinel)
    orbit_sentinel.visible = false
    orbit_beam = MeshInstance3D.new()
    orbit_beam.name = "Sentinel plasma lane warning"
    var beam_mesh := BoxMesh.new()
    beam_mesh.size = Vector3(1.9, 0.15, 35.0)
    orbit_beam.mesh = beam_mesh
    orbit_beam.material_override = mat(Color("#ffb75b"), true)
    orbit_beam.position = Vector3(0, 0.12, -13.0)
    add_child(orbit_beam)
    orbit_beam.visible = false

func _update_orbit_sentinel(delta: float) -> void:
    if world_choice != 2 or phase != "race" or not started or orbit_defeated:
        return
    if not orbit_active:
        if distance < mission_target * ORBIT_SPAWN_FRACTION:
            return
        orbit_active = true
        orbit_sentinel.visible = true
        orbit_sentinel.set("active", true)
        orbit_attack_timer = 2.3
        info_label.text = "BOSS: ORBIT-WÄCHTER! ENERGIE-ATTACKE LADEN!"
        feedback_time = 2.5
    if orbit_warning_left > 0.0:
        orbit_warning_left -= delta
        if orbit_warning_left <= 0.0:
            orbit_warning_left = 0.0
            orbit_beam.visible = false
            # Unlike the Canyon laser, turbo does not protect against plasma.
            if lane == orbit_lane and rider.position.y <= 1.1 and shield_left <= 0.0 and hit_cooldown <= 0.0:
                lives -= 1
                hit_cooldown = 1.4
                info_label.text = "PLASMA-TREFFER! NOCH %d LEBEN" % lives
                feedback_time = 1.5
                if lives <= 0:
                    _finish_run()
                    return
            else:
                info_label.text = "PLASMA AUSGEWICHEN!"
                feedback_time = 1.1
            orbit_attack_timer = 2.6 if orbit_hp == 1 else 4.5
        return
    orbit_attack_timer -= delta
    if orbit_attack_timer <= 0.0:
        # The sentinel targets the lane occupied at the beginning of its warning.
        # A visible 1.25-second telegraph lets players steer, jump or use Shield.
        orbit_lane = lane
        orbit_warning_left = 1.25
        orbit_beam.position.x = float(orbit_lane) * 3.1
        orbit_beam.visible = true
        info_label.text = "ORBIT-PLASMA! ORANGE SPUR VERLASSEN!"
        feedback_time = 1.25

func _create_frost_warden() -> void:
    # Third distinct, animated original 3D boss: a sculpted frost dragon.
    frost_warden = preload("res://frost_warden.gd").new() as Node3D
    frost_warden.name = "Aurora Frost Warden Boss"
    frost_warden.position = Vector3(0, 0.65, -25.0)
    add_child(frost_warden)
    frost_warden.visible = false
    # Swept, shaded ice sheets and jagged translucent crests replace flat boxes.
    # Keep one warning node per dangerous lane: collision rules stay unchanged.
    for index in range(2):
        var wave := preload("res://frost_shockwave.gd").new() as MeshInstance3D
        wave.name = "Frost shockwave lane %d" % index
        wave.position = Vector3(0, 0.14, -13.0)
        add_child(wave)
        wave.visible = false
        frost_warnings.append(wave)

func _update_frost_warden(delta: float) -> void:
    if world_choice != 3 or phase != "race" or not started or frost_defeated:
        return
    if not frost_active:
        if distance < mission_target * FROST_SPAWN_FRACTION:
            return
        frost_active = true
        frost_warden.visible = true
        frost_warden.set("active", true)
        frost_attack_timer = 2.4
        info_label.text = "BOSS: FROST-DRACHE! SCHOCKWELLEN AUSWEICHEN!"
        feedback_time = 2.5
    if frost_warning_left > 0.0:
        frost_warning_left -= delta
        if frost_warning_left <= 0.0:
            frost_warning_left = 0.0
            for wave in frost_warnings:
                wave.visible = false
            # Two dangerous lanes; the third is always safe. Jump or Shield
            # also protects the player, even if they stay in a frozen lane.
            if lane != frost_safe_lane and rider.position.y <= 1.45 and shield_left <= 0.0 and hit_cooldown <= 0.0:
                lives -= 1
                hit_cooldown = 1.4
                info_label.text = "FROSTWELLE! NOCH %d LEBEN" % lives
                feedback_time = 1.5
                if lives <= 0:
                    _finish_run()
                    return
            else:
                info_label.text = "FROSTWELLE ÜBERSTANDEN!"
                feedback_time = 1.1
            frost_attack_timer = 2.8 if frost_hp == 1 else 4.5
        return
    frost_attack_timer -= delta
    if frost_attack_timer <= 0.0:
        frost_safe_lane = randi_range(-1, 1)
        frost_warning_left = 1.6
        var wave_index := 0
        for candidate_lane in [-1, 0, 1]:
            if candidate_lane == frost_safe_lane:
                continue
            frost_warnings[wave_index].position.x = float(candidate_lane) * 3.1
            frost_warnings[wave_index].visible = true
            wave_index += 1
        info_label.text = "EISWELLE! ZWEI BLAUE SPUREN MEIDEN!"
        feedback_time = 1.6

func _apply_world_theme() -> void:
    # World selection changes real 3D geometry, lighting and the race mission.
    mission_target = float(WORLD_GOALS[world_choice])
    if skyway_zone != null:
        skyway_zone.visible = world_choice == 0
    if canyon_zone != null:
        canyon_zone.visible = world_choice == 1
    if harbor_zone != null:
        harbor_zone.visible = world_choice == 2
    if glacier_zone != null:
        glacier_zone.visible = world_choice == 3
    if moving != null:
        moving.visible = world_choice == 0
    if sky_material != null:
        match world_choice:
            0:
                sky_material.sky_top_color = Color("#080d35")
                sky_material.sky_horizon_color = Color("#ff789b")
                sky_material.ground_horizon_color = Color("#ffbd8b")
                sky_material.ground_bottom_color = Color("#39265e")
            1:
                sky_material.sky_top_color = Color("#1c1040")
                sky_material.sky_horizon_color = Color("#ffb07c")
                sky_material.ground_horizon_color = Color("#dc83ac")
                sky_material.ground_bottom_color = Color("#50254d")
            2:
                sky_material.sky_top_color = Color("#050d28")
                sky_material.sky_horizon_color = Color("#2f9fbb")
                sky_material.ground_horizon_color = Color("#a36fd6")
                sky_material.ground_bottom_color = Color("#1d265b")
            3:
                sky_material.sky_top_color = Color("#061b38")
                sky_material.sky_horizon_color = Color("#26a9b5")
                sky_material.ground_horizon_color = Color("#a4c8ed")
                sky_material.ground_bottom_color = Color("#183b63")

func _change_world() -> void:
    if phase != "menu":
        return
    world_choice = (world_choice + 1) % WORLD_NAMES.size()
    _apply_world_theme()
    world_button.text = "WELT: %s" % WORLD_NAMES[world_choice]
    _refresh_hud()

func _update_neon_signals() -> void:
    if world_choice != 0 or phase != "race" or not started or quiz_active:
        return
    var result: Dictionary = skyway_zone.call("check_neon_signal", rider.position.x)
    if result.is_empty():
        return
    if bool(result.get("hit", false)):
        xp += int(result.get("xp", 0))
        power = mini(100, power + int(result.get("energy", 0)))
        if bool(result.get("overdrive", false)):
            info_label.text = "NEON-OVERDRIVE! DREIERKETTE +30 ENERGIE"
        else:
            info_label.text = "SIGNAL ERWISCHT! KOMBO x%d  +%d XP" % [int(result.get("streak", 0)), int(result.get("xp", 0))]
    else:
        info_label.text = "SIGNALKETTE UNTERBROCHEN! NAECHSTES TOR"
    feedback_time = 1.6
    _refresh_hud()

func _update_canyon_routes() -> void:
    if world_choice != 1 or phase != "race" or not started or quiz_active:
        return
    var result: Dictionary = canyon_zone.call("check_route_choices", rider.position.x)
    if result.is_empty():
        return
    if bool(result.get("missed", false)):
        info_label.text = "KRISTALL-ABZWEIGUNG VERPASST! NAECHSTE WAEHLEN"
    else:
        xp += int(result.get("xp", 0))
        power = mini(100, power + int(result.get("energy", 0)))
        if str(result.get("choice", "")) == "energy":
            info_label.text = "ENERGIE-PFAD! +20 ENERGIE, +15 XP"
        else:
            info_label.text = "XP-PFAD! +40 XP"
    feedback_time = 1.6
    _refresh_hud()

func _update_harbor_cargo_relay() -> void:
    if world_choice != 2 or phase != "race" or not started or quiz_active:
        return
    var delivery: Dictionary = harbor_zone.call("check_cargo_delivery", rider.position.x)
    if delivery.is_empty():
        return
    if bool(delivery.get("delivered", false)):
        xp += int(delivery.get("xp", 0))
        power = mini(100, power + int(delivery.get("energy", 0)))
        info_label.text = "HAFEN-FRACHT GELIEFERT! +30 XP, +12 ENERGIE"
    else:
        info_label.text = "FRACHTTOR VERPASST! NAECHSTEN DOCK ANFLIEGEN"
    feedback_time = 1.6
    _refresh_hud()

func _update_glacier_mission() -> void:
    if world_choice != 3 or phase != "race" or not started:
        return
    var gate_result: int = int(glacier_zone.call("check_jump_gates", rider.position.x, rider.position.y))
    if gate_result > 0:
        info_label.text = "AURORA-SPRUNG GESCHAFFT! %d/%d" % [int(glacier_zone.get("completed_gates")), GLACIER_BONUS_TARGET]
        feedback_time = 1.5
    elif gate_result < 0:
        info_label.text = "SPRUNG-TOR VERPASST! NÄCHSTES TOR ANPEILEN"
        feedback_time = 1.5

func _show_world_menu() -> void:
    if phase != "results":
        return
    phase = "menu"
    started = false
    end_panel.hide()
    guardian.visible = false
    guardian_beam.visible = false
    orbit_sentinel.visible = false
    orbit_sentinel.set("active", false)
    orbit_beam.visible = false
    frost_warden.visible = false
    frost_warden.set("active", false)
    for wave in frost_warnings:
        wave.visible = false
    splash.show()
    _refresh_hud()

func _create_powerup_effects() -> void:
    # V49: large, curved, gradient-lit energy surfaces instead of stock spheres
    # and a torus. The effect node names and gameplay costs remain unchanged.
    var effect_factory = preload("res://ability_effects.gd")
    shield_visual = MeshInstance3D.new()
    shield_visual.name = "Active energy shield"
    shield_visual.mesh = effect_factory.shield_mesh()
    shield_visual.material_override = effect_factory.effect_material(Color(0.14, 0.75, 0.98), 0.86)
    shield_visual.position.y = 1.35
    rider.add_child(shield_visual)
    shield_visual.visible = false

    mega_jump_visual = MeshInstance3D.new()
    mega_jump_visual.name = "Mega jump energy"
    mega_jump_visual.mesh = effect_factory.jump_mesh()
    mega_jump_visual.material_override = effect_factory.effect_material(Color(0.37, 0.19, 0.09), 0.90)
    mega_jump_visual.position.y = 0.20
    rider.add_child(mega_jump_visual)
    mega_jump_visual.visible = false

    attack_visual = MeshInstance3D.new()
    attack_visual.name = "Super attack shockwave"
    attack_visual.mesh = effect_factory.attack_mesh()
    attack_visual.material_override = effect_factory.effect_material(Color(0.55, 0.08, 0.33), 0.80)
    attack_visual.position.y = 1.3
    rider.add_child(attack_visual)
    attack_visual.visible = false

func _create_run_items() -> void:
    run_items = Node3D.new()
    run_items.name = "3D obstacles and energy pickups"
    add_child(run_items)
    for i in range(20):
        var item := Node3D.new()
        var good: bool = i % 3 == 0
        item.name = "Energy crystal" if good else "Floating barrier"
        item.position = Vector3(float(randi_range(-1, 1)) * 3.1, 0, -28.0 - float(i) * 11.0)
        item.set_meta("energy", good)
        item.set_meta("collected", false)
        run_items.add_child(item)
        if good:
            # Large collectible energy gate with moving inner crystal.
            # The silhouette is unmistakable from the chase camera.
            var gate := TorusMesh.new()
            gate.inner_radius = 0.72
            gate.outer_radius = 0.87
            gate.rings = 32
            gate.ring_segments = 10
            var outer := MeshInstance3D.new()
            outer.name = "Energy gate"
            outer.mesh = gate
            outer.material_override = mat(Color("#ffd35a"), true)
            outer.position = Vector3(0, 1.45, 0)
            item.add_child(outer)
            var core := Node3D.new()
            core.name = "Animated core"
            core.position = Vector3(0, 1.45, 0)
            item.add_child(core)
            var diamond := SphereMesh.new()
            diamond.radial_segments = 8
            diamond.rings = 4
            var crystal := MeshInstance3D.new()
            crystal.mesh = diamond
            crystal.material_override = mat(Color("#fff4a3"), true)
            crystal.scale = Vector3(0.37, 0.64, 0.37)
            core.add_child(crystal)
            for side in [-1.0, 1.0]:
                sphere(item, Vector3(side * 0.78, 1.45, 0), Vector3(0.12, 0.12, 0.12), Color("#fff4a3"), true)
        else:
            cube(item, Vector3(0, 0.68, 0), Vector3(1.85, 1.36, 0.7), Color("#fe537f"), true)
            cube(item, Vector3(0, 0.72, 0.39), Vector3(1.27, 0.22, 0.06), Color("#ffdf81"), true)
            cube(item, Vector3(0, 1.4, 0), Vector3(2.1, 0.13, 0.84), Color("#b927f7"), true)

func _reset_run() -> void:
    touch_steering.reset()
    _apply_world_theme()
    phase = "race"
    lane = 0
    xp = 0
    power = 0
    distance = 0.0
    lives = 3
    combo = 0
    speed = 14.0
    jump_left = 0.0
    hit_cooldown = 0.0
    turbo_left = 0.0
    shield_left = 0.0
    attack_left = 0.0
    mega_jump_active = false
    guardian_hp = GUARDIAN_HEALTH
    harbor_crystals = 0
    skyway_zone.call("reset_signals")
    harbor_zone.call("reset_cargo_relay")
    glacier_zone.call("reset_course")
    canyon_zone.call("reset_routes")
    guardian_active = false
    guardian_defeated = false
    guardian_attack_timer = 0.0
    guardian_warning_left = 0.0
    guardian.visible = false
    guardian.set("active", false)
    guardian_beam.visible = false
    orbit_hp = ORBIT_HEALTH
    orbit_active = false
    orbit_defeated = false
    orbit_attack_timer = 0.0
    orbit_warning_left = 0.0
    orbit_sentinel.visible = false
    orbit_sentinel.set("active", false)
    orbit_beam.visible = false
    frost_hp = FROST_HEALTH
    frost_active = false
    frost_defeated = false
    frost_attack_timer = 0.0
    frost_warning_left = 0.0
    frost_safe_lane = 0
    frost_warden.visible = false
    frost_warden.set("active", false)
    for wave in frost_warnings:
        wave.visible = false
    jump_duration = 0.85
    jump_height = 1.8
    shield_visual.visible = false
    attack_visual.visible = false
    mega_jump_visual.visible = false
    quiz_time = 7.0
    quiz_active = false
    previous_quiz_index = -1
    rider.position = Vector3(0, 0, 0.2)
    for i in range(run_items.get_child_count()):
        var item: Node3D = run_items.get_child(i)
        item.position.z = -28.0 - float(i) * 11.0
        item.position.x = float(randi_range(-1, 1)) * 3.1
        item.position.y = 0.0
        item.set_meta("collected", false)
        item.visible = true
    started = true
    splash.hide()
    quiz_box.hide()
    end_panel.hide()
    info_label.text = ""
    _refresh_hud()

func _jump() -> void:
    if phase == "race" and started and not quiz_active and jump_left <= 0.0:
        jump_duration = 0.85
        jump_height = 1.8
        mega_jump_active = false
        jump_left = jump_duration

func _use_shield() -> void:
    if phase != "race" or not started or quiz_active or shield_left > 0.0 or power < SHIELD_COST:
        return
    power -= SHIELD_COST
    shield_left = 8.0
    shield_visual.visible = true
    info_label.text = "ENERGIE-SCHILD AKTIV!"
    feedback_time = 1.6
    _refresh_hud()

func _use_mega_jump() -> void:
    if phase != "race" or not started or quiz_active or jump_left > 0.0 or power < MEGA_JUMP_COST:
        return
    power -= MEGA_JUMP_COST
    jump_duration = 1.55
    jump_height = 4.2
    jump_left = jump_duration
    mega_jump_active = true
    mega_jump_visual.visible = true
    info_label.text = "MEGA-SPRUNG!"
    feedback_time = 1.4
    _refresh_hud()

func _use_super_attack() -> void:
    if phase != "race" or not started or quiz_active or attack_left > 0.0 or power < ATTACK_COST:
        return
    power -= ATTACK_COST
    attack_left = 0.72
    attack_visual.visible = true
    var cleared := 0
    for item in run_items.get_children():
        # Destroy upcoming hazards across all three lanes in shockwave range.
        if bool(item.get_meta("energy")) or bool(item.get_meta("collected")):
            continue
        if item.position.z < rider.position.z and item.position.z > rider.position.z - 62.0:
            item.set_meta("collected", true)
            item.visible = false
            cleared += 1
    xp += cleared * 20
    if guardian_active and not guardian_defeated:
        guardian_hp -= 1
        guardian.call("take_hit")
        if guardian_hp <= 0:
            guardian_defeated = true
            guardian_active = false
            guardian.visible = false
            guardian.set("active", false)
            guardian_beam.visible = false
            guardian_warning_left = 0.0
            xp += 120
            info_label.text = "BOSS BESIEGT! +120 XP UND BONUSSTERN!"
        else:
            info_label.text = "BOSS GETROFFEN! NOCH %d KERN-PUNKTE" % guardian_hp
    elif orbit_active and not orbit_defeated:
        orbit_hp -= 1
        orbit_sentinel.call("take_hit")
        if orbit_hp <= 0:
            orbit_defeated = true
            orbit_active = false
            orbit_sentinel.visible = false
            orbit_sentinel.set("active", false)
            orbit_beam.visible = false
            orbit_warning_left = 0.0
            xp += 120
            info_label.text = "ORBIT-WÄCHTER BESIEGT! +120 XP UND BONUSSTERN!"
        else:
            info_label.text = "ORBIT-WÄCHTER GETROFFEN! NOCH %d KERN-PUNKTE" % orbit_hp
    elif frost_active and not frost_defeated:
        frost_hp -= 1
        frost_warden.call("take_hit")
        if frost_hp <= 0:
            frost_defeated = true
            frost_active = false
            frost_warden.visible = false
            frost_warden.set("active", false)
            for wave in frost_warnings:
                wave.visible = false
            frost_warning_left = 0.0
            xp += 150
            info_label.text = "FROST-DRACHE BESIEGT! +150 XP UND BONUSSTERN!"
        else:
            info_label.text = "FROST-DRACHE GETROFFEN! NOCH %d KERN-PUNKTE" % frost_hp
    else:
        info_label.text = "SUPER ATTACK! %d HINDERNISSE ZERSTÖRT" % cleared
    feedback_time = 1.8
    _refresh_hud()

func _update_run_items(delta: float) -> void:
    hit_cooldown = maxf(0.0, hit_cooldown - delta)
    jump_left = maxf(0.0, jump_left - delta)
    rider.position.y = sin((1.0 - jump_left / jump_duration) * PI) * jump_height if jump_left > 0.0 else 0.0
    if jump_left <= 0.0 and mega_jump_active:
        mega_jump_active = false
        mega_jump_visual.visible = false
        jump_duration = 0.85
        jump_height = 1.8
    for item in run_items.get_children():
        var previous_z: float = item.position.z
        item.position.z += speed * delta
        var is_energy: bool = bool(item.get_meta("energy"))
        if is_energy:
            # Rotate and pulse the existing gate mesh: no additional draw calls.
            var gate := item.get_node_or_null("Energy gate") as MeshInstance3D
            if gate != null:
                gate.rotation.z += delta * 0.45
                var glow_pulse := 1.0 + sin(distance * 0.10 + float(item.get_index()) * 0.7) * 0.08
                gate.scale = Vector3.ONE * glow_pulse
            # Animate the collectible independently from the world motion.
            var core: Node3D = item.get_node_or_null("Animated core")
            if core != null:
                core.rotation.y += delta * 2.8
                core.rotation.z += delta * 0.6
                core.position.y = 1.45 + sin(distance * 0.12 + float(item.get_index())) * 0.15
        if previous_z < rider.position.z and item.position.z >= rider.position.z and not bool(item.get_meta("collected")):
            item.set_meta("collected", true)
            if absf(item.position.x - rider.position.x) < 1.45:
                if is_energy:
                    power = mini(100, power + 18)
                    xp += 15
                    item.visible = false
                    if world_choice == 2:
                        harbor_crystals += 1
                        info_label.text = "HAFEN-KRISTALL %d/%d  +15 XP" % [harbor_crystals, HARBOR_BONUS_TARGET]
                    else:
                        info_label.text = "ENERGIE +15 XP!"
                    feedback_time = 1.2
                elif rider.position.y > 0.85:
                    xp += 10
                    info_label.text = "SPRUNG! +10 XP"
                    feedback_time = 1.2
                elif turbo_left > 0.0:
                    xp += 10
                    info_label.text = "TURBO! +10 XP"
                    feedback_time = 1.2
                elif shield_left > 0.0:
                    info_label.text = "SCHILD BLOCKT DEN TREFFER!"
                    feedback_time = 1.1
                    item.visible = false
                elif hit_cooldown <= 0.0:
                    lives -= 1
                    combo = 0
                    hit_cooldown = 1.4
                    info_label.text = "TREFFER! NOCH %d LEBEN" % lives
                    feedback_time = 1.5
                    if lives <= 0:
                        _finish_run()
                        return
        if item.position.z > 10.0:
            item.position.z = -190.0 - float(randi_range(0, 65))
            item.position.x = float(randi_range(-1, 1)) * 3.1
            item.set_meta("collected", false)
            item.visible = true

func _finish_run() -> void:
    var completed := phase == "race" and distance >= mission_target
    if completed:
        rounds_finished += 1
        round_number += 1
        var stars_earned: int = clampi(lives, 1, 3) + (1 if world_choice == 0 and int(skyway_zone.call("get_signal_count")) >= NEON_SIGNAL_TARGET else 0) + (1 if world_choice == 1 and guardian_defeated else 0) + (1 if world_choice == 1 and int(canyon_zone.get("completed_routes")) >= CANYON_ROUTE_TARGET else 0) + (1 if world_choice == 2 and harbor_crystals >= HARBOR_BONUS_TARGET else 0) + (1 if world_choice == 2 and orbit_defeated else 0) + (1 if world_choice == 2 and int(harbor_zone.call("get_cargo_deliveries")) >= HARBOR_RELAY_TARGET else 0) + (1 if world_choice == 3 and int(glacier_zone.get("completed_gates")) >= GLACIER_BONUS_TARGET else 0) + (1 if world_choice == 3 and frost_defeated else 0)
        total_stars += stars_earned
        total_reward_xp += xp
        reward_label.text = "+%d STERNE  |  +%d XP\nGESAMT: %d STERNE" % [stars_earned, xp, total_stars]
        if world_choice == 0 and int(skyway_zone.call("get_signal_count")) >= NEON_SIGNAL_TARGET:
            reward_label.text += "\nNEON-SIGNALKETTE: +1 BONUSSTERN!"
        if world_choice == 1 and guardian_defeated:
            reward_label.text += "\nKRISTALL-WÄCHTER BESIEGT: +1 BONUSSTERN!"
        if world_choice == 1 and int(canyon_zone.get("completed_routes")) >= CANYON_ROUTE_TARGET:
            reward_label.text += "\nKRISTALL-PFAD-MISSION: +1 BONUSSTERN!"
        if world_choice == 2 and harbor_crystals >= HARBOR_BONUS_TARGET:
            reward_label.text += "\nHAFEN-MISSION ERFÜLLT: +1 BONUSSTERN!"
        if world_choice == 2 and orbit_defeated:
            reward_label.text += "\nORBIT-WÄCHTER BESIEGT: +1 BONUSSTERN!"
        if world_choice == 2 and int(harbor_zone.call("get_cargo_deliveries")) >= HARBOR_RELAY_TARGET:
            reward_label.text += "\nHAFEN-FRACHTRELAIS: +1 BONUSSTERN!"
        if world_choice == 3 and int(glacier_zone.get("completed_gates")) >= GLACIER_BONUS_TARGET:
            reward_label.text += "\nAURORA-SPRUNG-MISSION: +1 BONUSSTERN!"
        if world_choice == 3 and frost_defeated:
            reward_label.text += "\nFROST-DRACHE BESIEGT: +1 BONUSSTERN!"
    else:
        reward_label.text = "NOCH %dm BIS ZUM ZIEL\nVERSUCHE ES ERNEUT!" % maxi(0, int(mission_target - distance))
    phase = "results"
    guardian.visible = false
    guardian.set("active", false)
    guardian_beam.visible = false
    orbit_sentinel.visible = false
    orbit_sentinel.set("active", false)
    orbit_beam.visible = false
    frost_warden.visible = false
    frost_warden.set("active", false)
    for wave in frost_warnings:
        wave.visible = false
    end_heading.text = "RUNDE GESCHAFFT!" if completed else "RUNDE NICHT GESCHAFFT"
    started = false
    quiz_active = false
    quiz_box.hide()
    end_panel.show()
    info_label.text = "ZIEL ERREICHT! NÄCHSTE RUNDE FREI" if completed else "VERSUCH BEENDET - %d METER" % int(distance)
    feedback_time = 4.0
    _refresh_hud()

func _style_panel(panel: PanelContainer) -> void:
    var bg := StyleBoxFlat.new()
    bg.bg_color = Color("#111b3be8")
    bg.border_color = Color("#65d8e9")
    bg.set_border_width_all(2)
    bg.set_corner_radius_all(18)
    bg.set_content_margin_all(15)
    bg.shadow_color = Color("#050b2380")
    bg.shadow_size = 10
    panel.add_theme_stylebox_override("panel", bg)

func _style_button(button: Button) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color("#344e84")
    normal.border_color = Color("#7eecfa")
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(12)
    normal.set_content_margin_all(9)
    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color("#ab53e5")
    pressed.border_color = Color("#ffe18f")
    var hovered := normal.duplicate() as StyleBoxFlat
    hovered.bg_color = Color("#506ca2")
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("hover", hovered)
    button.add_theme_stylebox_override("focus", hovered)
    button.add_theme_color_override("font_color", Color("#ffffff"))
    button.add_theme_color_override("font_hover_color", Color("#ffffff"))
    button.add_theme_color_override("font_pressed_color", Color("#fff3bf"))

func _make_button(label_text: String, callback: Callable, parent: Node) -> Button:
    var b := Button.new()
    b.text = label_text
    b.custom_minimum_size = Vector2(155, 55)
    b.add_theme_font_size_override("font_size", 20)
    _style_button(b)
    b.pressed.connect(callback)
    parent.add_child(b)
    return b

# Handle native screen touches, never mouse clicks generated by the browser.
# Capturing only touches that start outside controls prevents quiz/button gestures.
func _input(event: InputEvent) -> void:
    if not (event is InputEventScreenTouch or event is InputEventScreenDrag):
        return
    var racing := phase == "race" and started and not quiz_active
    var blocked := false
    var down := event as InputEventScreenTouch
    if down != null and down.pressed:
        blocked = _touch_ui_blocked(down.position)
    var viewport_size := get_viewport().get_visible_rect().size
    var outcome: Dictionary = touch_steering.handle(event, racing, blocked, Time.get_ticks_msec(), lane, viewport_size.x, viewport_size.y)
    if not bool(outcome.get("captured", false)):
        return
    get_viewport().set_input_as_handled()
    if outcome.has("lane"):
        lane = clampi(int(outcome["lane"]), -1, 1)
    match str(outcome.get("action", "")):
        "jump":
            _jump()
        "turbo":
            _use_turbo()
        "shield":
            _use_shield()
        "attack":
            _use_super_attack()

func _touch_ui_blocked(position: Vector2) -> bool:
    # The instructions are a non-interactive MOUSE_FILTER_IGNORE label. They
    # must not reserve a full-width dead zone over the lower playfield when
    # the optional touch buttons are hidden. Keep real UI and HUD protected.
    for control in [splash, quiz_box, end_panel, controls_grid, powerups_grid, hud_panel, progress_bar, gesture_toggle]:
        if control != null and control.is_visible_in_tree() and control.get_global_rect().has_point(position):
            return true
    return false

func _toggle_touch_buttons() -> void:
    touch_buttons_visible = not touch_buttons_visible
    _update_touch_ui()

func _update_touch_ui() -> void:
    if controls_grid == null or powerups_grid == null or gesture_toggle == null or gesture_hint == null:
        return
    var racing := phase == "race" and started and not quiz_active
    var show_buttons := racing and (touch_buttons_visible or not touch_screen_mode)
    controls_grid.visible = show_buttons
    powerups_grid.visible = show_buttons
    gesture_toggle.visible = racing and touch_screen_mode
    gesture_hint.visible = racing and touch_screen_mode
    gesture_toggle.text = "TASTEN AUS" if touch_buttons_visible else "TASTEN EIN"
    gesture_hint.offset_top = -245.0 if touch_buttons_visible else -75.0
    gesture_hint.offset_bottom = -205.0 if touch_buttons_visible else -35.0

func _create_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var canvas := Control.new()
    canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layer.add_child(canvas)

    hud_panel = PanelContainer.new()
    _style_panel(hud_panel)
    hud_panel.position = Vector2(15, 12)
    hud_panel.custom_minimum_size = Vector2(360, 56)
    canvas.add_child(hud_panel)
    hud = Label.new()
    hud.add_theme_font_size_override("font_size", 18)
    hud_panel.add_child(hud)
    progress_bar = ProgressBar.new()
    progress_bar.name = "Race mission progress"
    progress_bar.position = Vector2(15, 91)
    progress_bar.custom_minimum_size = Vector2(360, 20)
    progress_bar.show_percentage = true
    progress_bar.max_value = mission_target
    var track_style := StyleBoxFlat.new()
    track_style.bg_color = Color("#15213e")
    track_style.set_corner_radius_all(9)
    var fill_style := StyleBoxFlat.new()
    fill_style.bg_color = Color("#6af5e5")
    fill_style.set_corner_radius_all(9)
    progress_bar.add_theme_stylebox_override("background", track_style)
    progress_bar.add_theme_stylebox_override("fill", fill_style)
    canvas.add_child(progress_bar)

    # Four fixed-width buttons overflow a phone screen. Two rows fit in portrait.
    controls_grid = GridContainer.new()
    controls_grid.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    controls_grid.offset_top = -90
    controls_grid.offset_bottom = -12
    controls_grid.offset_left = 15
    controls_grid.offset_right = -15
    controls_grid.add_theme_constant_override("h_separation", 12)
    controls_grid.add_theme_constant_override("v_separation", 10)
    canvas.add_child(controls_grid)
    for button in [
        _make_button("< LINKS", func(): _shift(-1), controls_grid),
        _make_button("RECHTS >", func(): _shift(1), controls_grid),
        _make_button("SPRINGEN", _jump, controls_grid),
        _make_button("TURBO", _use_turbo, controls_grid)
    ]:
        button.custom_minimum_size.x = 0
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    # Separate mobile row: four movement controls stay unchanged for old saves/tests.
    powerups_grid = GridContainer.new()
    powerups_grid.name = "Special abilities"
    powerups_grid.columns = 3
    powerups_grid.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    powerups_grid.offset_left = 15.0
    powerups_grid.offset_right = -15.0
    powerups_grid.offset_top = -152.0
    powerups_grid.offset_bottom = -98.0
    powerups_grid.add_theme_constant_override("h_separation", 7)
    canvas.add_child(powerups_grid)
    for power_button in [
        _make_button("SCHILD", _use_shield, powerups_grid),
        _make_button("MEGA ↑", _use_mega_jump, powerups_grid),
        _make_button("ATTACKE", _use_super_attack, powerups_grid)
    ]:
        power_button.custom_minimum_size = Vector2(0, 46)
        power_button.add_theme_font_size_override("font_size", 16)
        power_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    # Accessible buttons remain the default; a small independent toggle can
    # hide both rows without hiding the gesture instructions or restore button.
    gesture_toggle = _make_button("TASTEN AUS", _toggle_touch_buttons, canvas)
    gesture_toggle.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    gesture_toggle.offset_left = -143.0
    gesture_toggle.offset_right = -15.0
    gesture_toggle.offset_top = 127.0
    gesture_toggle.offset_bottom = 168.0
    gesture_toggle.add_theme_font_size_override("font_size", 14)
    gesture_hint = Label.new()
    gesture_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    gesture_hint.text = "ZIEHEN ↔ LENKEN · ↑ SPRUNG · 2× TIPP TURBO\n2 FINGER: TIPP SCHILD · ↑ ATTACKE"
    gesture_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    gesture_hint.add_theme_font_size_override("font_size", 12)
    gesture_hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    gesture_hint.offset_left = 8.0
    gesture_hint.offset_right = -8.0
    canvas.add_child(gesture_hint)

    splash = PanelContainer.new()
    _style_panel(splash)
    splash.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    splash.position = Vector2(-220, -192)
    splash.custom_minimum_size = Vector2(440, 384)
    canvas.add_child(splash)
    var start_column := VBoxContainer.new()
    start_column.add_theme_constant_override("separation", 14)
    splash.add_child(start_column)
    start_heading = Label.new()
    start_heading.text = "LEARNQUEST 3D"
    start_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    start_heading.add_theme_font_size_override("font_size", 34)
    start_column.add_child(start_heading)
    var sub := Label.new()
    sub.text = "ERST 3 VOKABELN, DANN EINE GANZE RUNDE"
    sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    start_column.add_child(sub)
    grade_label = Label.new()
    grade_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    start_column.add_child(grade_label)
    var grade_buttons := HBoxContainer.new()
    grade_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
    start_column.add_child(grade_buttons)
    var grade_down := _make_button("−", func(): _change_grade(-1), grade_buttons)
    var grade_up := _make_button("+", func(): _change_grade(1), grade_buttons)
    grade_down.custom_minimum_size.x = 68
    grade_up.custom_minimum_size.x = 68
    world_button = _make_button("WELT: NEON CITY", _change_world, start_column)
    _make_button("AUFGABEN STARTEN", _begin_training, start_column)
    _change_grade(0)

    quiz_box = PanelContainer.new()
    _style_panel(quiz_box)
    quiz_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    quiz_box.position = Vector2(-230, -185)
    quiz_box.custom_minimum_size = Vector2(460, 380)
    canvas.add_child(quiz_box)
    var quiz_column := VBoxContainer.new()
    quiz_column.add_theme_constant_override("separation", 12)
    quiz_box.add_child(quiz_column)
    var prompt := Label.new()
    prompt.text = "WIE HEISST DAS AUF ENGLISCH?"
    prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    quiz_column.add_child(prompt)
    question_label = Label.new()
    question_label.add_theme_font_size_override("font_size", 31)
    question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    quiz_column.add_child(question_label)
    for i in range(3):
        var index := i
        answer_buttons.append(_make_button("Antwort", func(): _answer(index), quiz_column))
    quiz_box.hide()

    info_label = Label.new()
    info_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
    info_label.offset_top = 80
    info_label.add_theme_font_size_override("font_size", 25)
    info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info_label.modulate = Color("#ffdc7a")
    canvas.add_child(info_label)

    end_panel = PanelContainer.new()
    _style_panel(end_panel)
    end_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    end_panel.position = Vector2(-205, -115)
    end_panel.custom_minimum_size = Vector2(410, 230)
    canvas.add_child(end_panel)
    var end_column := VBoxContainer.new()
    end_column.add_theme_constant_override("separation", 18)
    end_panel.add_child(end_column)
    end_heading = Label.new()
    end_heading.text = "RENNEN BEENDET!"
    end_heading.add_theme_font_size_override("font_size", 30)
    end_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    end_column.add_child(end_heading)
    reward_label = Label.new()
    reward_label.name = "Round rewards"
    reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    reward_label.add_theme_font_size_override("font_size", 20)
    end_column.add_child(reward_label)
    _make_button("NEUE AUFGABEN", _begin_training, end_column)
    _make_button("WELT WECHSELN", _show_world_menu, end_column)
    end_panel.hide()
    _apply_mobile_layout(get_viewport().get_visible_rect().size.x)
    get_viewport().size_changed.connect(func(): _apply_mobile_layout(get_viewport().get_visible_rect().size.x))

# Responsive phone portrait layout, while keeping the four desktop controls.
func _apply_mobile_layout(viewport_width: float, touchscreen_override: int = -1, viewport_height: float = -1.0) -> void:
    # iOS Safari's browser bars can change viewport HEIGHT without changing
    # width. Both rotations and height-only relayouts invalidate touch origins.
    # Quarantine held fingers until release so another finger cannot take over.
    var layout_height: float = viewport_height if viewport_height > 0.0 else get_viewport().get_visible_rect().size.y
    if last_touch_layout_width >= 0.0 and (absf(viewport_width - last_touch_layout_width) >= 2.0 or (last_touch_layout_height >= 0.0 and absf(layout_height - last_touch_layout_height) >= 2.0)):
        touch_steering.invalidate_layout()
    last_touch_layout_width = viewport_width
    last_touch_layout_height = layout_height
    var narrow := viewport_width < 720.0
    var has_touchscreen := DisplayServer.is_touchscreen_available() if touchscreen_override < 0 else touchscreen_override == 1
    # The primary mobile format is landscape: reserve the middle for the rider.
    # Never force a long desktop HUD across a short 16:9 mobile viewport.
    var landscape_phone := has_touchscreen and viewport_width > layout_height and layout_height < 620.0
    mobile_hud_layout = narrow or landscape_phone
    touch_screen_mode = narrow or has_touchscreen
    hud_panel.custom_minimum_size.x = minf(360.0, maxf(0.0, viewport_width - 30.0)) if mobile_hud_layout else 360.0
    progress_bar.custom_minimum_size.x = hud_panel.custom_minimum_size.x
    hud.add_theme_font_size_override("font_size", 14 if landscape_phone else (16 if narrow else 18))
    controls_grid.columns = 2 if narrow else 4
    controls_grid.offset_top = -142.0 if narrow else -90.0
    powerups_grid.offset_top = -200.0 if narrow else -152.0
    powerups_grid.offset_bottom = -151.0 if narrow else -98.0
    start_heading.add_theme_font_size_override("font_size", 26 if narrow else 34)
    end_heading.add_theme_font_size_override("font_size", 24 if narrow else 30)
    for panel in [splash, quiz_box, end_panel]:
        var desktop_width: float = 440.0 if panel == splash else (460.0 if panel == quiz_box else 410.0)
        var panel_width: float = minf(desktop_width, maxf(280.0, viewport_width - 24.0))
        panel.custom_minimum_size.x = panel_width
        panel.offset_left = -panel_width / 2.0
        panel.offset_right = panel_width / 2.0
    _refresh_hud()

func _change_grade(delta: int) -> void:
    grade = clampi(grade + delta, 1, 10)
    grade_label.text = "SCHULKLASSE: %d" % grade

func _begin_training() -> void:
    # Starts the mandatory preparation before every player-facing round.
    touch_steering.reset()
    phase = "training"
    training_correct = 0
    combo = 0
    previous_quiz_index = -1
    # Clear temporary abilities from the previous race before mandatory training.
    # Without this, old Turbo/Shield effects leak into the next round's menu.
    turbo_left = 0.0
    shield_left = 0.0
    attack_left = 0.0
    mega_jump_active = false
    if shield_visual != null:
        shield_visual.visible = false
    if attack_visual != null:
        attack_visual.visible = false
    if mega_jump_visual != null:
        mega_jump_visual.visible = false
    started = true
    quiz_active = false
    splash.hide()
    end_panel.hide()
    info_label.text = "LÖSE %d AUFGABEN FÜR RUNDE %d" % [TASKS_PER_ROUND, round_number]
    feedback_time = 3.0
    _ask()
    _refresh_hud()

func _start_game() -> void:
    # Backwards-compatible low-level race entry point for gameplay diagnostics.
    # The start and replay buttons always call _begin_training().
    _reset_run()

func _group() -> int:
    return 0 if grade <= 3 else (1 if grade <= 6 else 2)

func _ask() -> void:
    quiz_active = true
    var word_count: int = WORDS[_group()].size()
    correct_index = randi_range(0, word_count - 1)
    if word_count > 1 and correct_index == previous_quiz_index:
        # Randomly select a different word; do not force the same next item.
        correct_index = (correct_index + randi_range(1, word_count - 1)) % word_count
    previous_quiz_index = correct_index
    options = [correct_index]
    while options.size() < 3:
        var candidate := randi_range(0, WORDS[_group()].size() - 1)
        if not options.has(candidate):
            options.append(candidate)
    options.shuffle()
    if phase == "training":
        question_label.text = "%d/%d  %s" % [training_correct + 1, TASKS_PER_ROUND, WORDS[_group()][correct_index][0]]
    else:
        question_label.text = WORDS[_group()][correct_index][0]
    for i in range(3):
        answer_buttons[i].disabled = false
        answer_buttons[i].text = WORDS[_group()][options[i]][1]
    quiz_box.show()

func _answer(index: int) -> void:
    # Ignore stale/double taps after a quiz closes and invalid input indices.
    # Otherwise a queued second press can award XP and energy more than once.
    if not started or not quiz_active or index < 0 or index >= options.size():
        return
    if options[index] != correct_index:
        combo = 0
        # Disable the wrong choice until the next question, so the player
        # can retry without repeatedly tapping the same incorrect answer.
        answer_buttons[index].disabled = true
        info_label.text = "FALSCH! ANDERE ANTWORT WÄHLEN"
        feedback_time = 2.0
        # The game loop is paused during a quiz; update the combo HUD now.
        _refresh_hud()
        return
    combo += 1
    xp += 45 if combo >= 3 else 35
    power = mini(power + 25, 100)
    if phase == "training":
        training_correct += 1
        if training_correct >= TASKS_PER_ROUND:
            # Award a useful starting boost, then run the entire track
            # without interrupting play with further vocabulary questions.
            _reset_run()
            power = mini(100, TASKS_PER_ROUND * 25)
            xp = TASKS_PER_ROUND * 35
            combo = TASKS_PER_ROUND
            info_label.text = "RUNDE %d FREIGESCHALTET! BIS INS ZIEL!" % round_number
            feedback_time = 3.0
            _refresh_hud()
        else:
            info_label.text = "RICHTIG! NOCH %d AUFGABEN" % (TASKS_PER_ROUND - training_correct)
            feedback_time = 2.0
            _ask()
            _refresh_hud()
        return
    info_label.text = "RICHTIG!  KOMBO x%d" % combo
    feedback_time = 2.0
    quiz_active = false
    quiz_box.hide()
    quiz_time = 9.0
    _refresh_hud()

func _shift(delta: int) -> void:
    if phase == "race" and started and not quiz_active:
        lane = clampi(lane + delta, -1, 1)

func _use_turbo() -> void:
    if phase == "race" and started and not quiz_active and turbo_left <= 0.0 and power >= 40:
        power -= 40
        turbo_left = 5.0
        _refresh_hud()

func _refresh_hud() -> void:
    if hud != null:
        if mobile_hud_layout:
            hud.text = "%s  LEBEN %d  XP %d\nENERGIE %d%%  KOMBO x%d  %dm" % [VERSION_LABEL, lives, xp, power, combo, int(distance)]
        else:
            hud.text = "SKYWAY %s   LEBEN %d   XP %d   ENERGIE %d%%   KOMBO x%d   %dm" % [VERSION_LABEL, lives, xp, power, combo, int(distance)]
        if phase == "race":
            hud.text += "\n%s  RUNDE %d  ZIEL %dm  SCHILD %ds  BOOST %ds" % [WORLD_NAMES[world_choice], round_number, int(mission_target), ceili(shield_left), ceili(turbo_left)]
            if world_choice == 0:
                hud.text += "\nNEON-SIGNALE %d/%d  SERIE x%d  LEUCHTSPUR FOLGEN" % [mini(int(skyway_zone.call("get_signal_count")), NEON_SIGNAL_TARGET), NEON_SIGNAL_TARGET, int(skyway_zone.call("get_signal_streak"))]
            if world_choice == 1:
                hud.text += "\nKRISTALL-PFADE %d/%d  LINKS: ENERGIE  RECHTS: XP" % [mini(int(canyon_zone.get("completed_routes")), CANYON_ROUTE_TARGET), CANYON_ROUTE_TARGET]
            if guardian_active and world_choice == 1:
                hud.text += "\nKRISTALL-WÄCHTER %d/%d  %s" % [guardian_hp, GUARDIAN_HEALTH, "LASER!" if guardian_warning_left > 0.0 else "ANGRIFF LADEN"]
            if world_choice == 2:
                hud.text += "\nHAFEN-MISSION: %d/%d ENERGIEKRISTALLE" % [mini(harbor_crystals, HARBOR_BONUS_TARGET), HARBOR_BONUS_TARGET]
                hud.text += "\nFRACHT-RELAIS %d/%d  LEUCHTENDES DOCK ANSTEUERN" % [mini(int(harbor_zone.call("get_cargo_deliveries")), HARBOR_RELAY_TARGET), HARBOR_RELAY_TARGET]
                if orbit_active:
                    hud.text += "\nORBIT-WÄCHTER %d/%d  %s" % [orbit_hp, ORBIT_HEALTH, "PLASMA!" if orbit_warning_left > 0.0 else "ATTACKE LADEN"]
            if world_choice == 3:
                hud.text += "\nAURORA-SPRUNGTORE: %d/%d  (SPRINGEN + LENKEN)" % [mini(int(glacier_zone.get("completed_gates")), GLACIER_BONUS_TARGET), GLACIER_BONUS_TARGET]
                if frost_active:
                    hud.text += "\nFROST-DRACHE %d/%d  %s" % [frost_hp, FROST_HEALTH, "EISWELLE!" if frost_warning_left > 0.0 else "ATTACKE LADEN"]
    if progress_bar != null:
        progress_bar.visible = phase == "race"
        progress_bar.max_value = mission_target
        progress_bar.value = clampf(distance, 0.0, mission_target)
    _update_touch_ui()

# The menu showcases the actual modeled face, hair and outfit from the front.
# Training/results keep the gallery; races transition to the existing chase
# camera without interrupting controls, physics or the timed boss warnings.
func _update_camera(delta: float) -> void:
    if chase_camera == null or rider == null:
        return
    var racing := phase == "race" and started and not quiz_active
    var boost := racing and turbo_left > 0.0
    var target_position: Vector3
    var target_focus: Vector3
    var target_fov: float
    if racing:
        target_position = Vector3(rider.position.x * 0.36, 4.3 + rider.position.y * 0.25, 10.1 if boost else 9.0)
        target_focus = Vector3(rider.position.x * 0.42, 1.5 + rider.position.y * 0.45, 0.5)
        target_fov = 74.0 if boost else 64.0
    else:
        showcase_clock += delta
        # Frame the rider to the right of the central menu/quiz panel.
        # Front-facing (-Z) perspective finally exposes the detailed face.
        target_position = Vector3(-5.2 + sin(showcase_clock * 0.4) * 0.24, 3.15, -6.7)
        target_focus = Vector3(-3.0, 2.05, 0.25)
        target_fov = 58.0
    var blend := clampf(delta * 3.8, 0.0, 1.0)
    chase_camera.position = chase_camera.position.lerp(target_position, blend)
    camera_focus = camera_focus.lerp(target_focus, blend)
    chase_camera.look_at(camera_focus, Vector3.UP)
    chase_camera.fov = lerpf(chase_camera.fov, target_fov, blend)

func _process(delta: float) -> void:
    if hero_gallery != null:
        hero_gallery.visible = phase != "race"
    if feedback_time > 0:
        feedback_time -= delta
        if feedback_time <= 0:
            info_label.text = ""
    skyway_zone.set("running", phase == "race" and started and not quiz_active and world_choice == 0)
    skyway_zone.set("travel_speed", speed)
    canyon_zone.set("running", phase == "race" and started and not quiz_active and world_choice == 1)
    canyon_zone.set("travel_speed", speed)
    harbor_zone.set("running", phase == "race" and started and not quiz_active and world_choice == 2)
    harbor_zone.set("travel_speed", speed)
    glacier_zone.set("running", phase == "race" and started and not quiz_active and world_choice == 3)
    glacier_zone.set("travel_speed", speed)
    if phase != "race" or not started or quiz_active:
        _update_camera(delta)
        return
    if Input.is_key_pressed(KEY_SPACE) and jump_left <= 0.0:
        _jump()
    if Input.is_key_pressed(KEY_Q):
        _use_shield()
    if Input.is_key_pressed(KEY_E):
        _use_mega_jump()
    if Input.is_key_pressed(KEY_R):
        _use_super_attack()
    if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
        lane = -1
    elif Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
        lane = 1
    elif Input.is_key_pressed(KEY_S):
        lane = 0
    turbo_left = maxf(0.0, turbo_left - delta)
    shield_left = maxf(0.0, shield_left - delta)
    attack_left = maxf(0.0, attack_left - delta)
    shield_visual.visible = shield_left > 0.0
    if shield_visual.visible:
        shield_visual.rotation.y += delta * 0.62
        var pulse := 1.0 + sin(distance * 0.24) * 0.04
        shield_visual.scale = Vector3.ONE * pulse
    attack_visual.visible = attack_left > 0.0
    if attack_visual.visible:
        attack_visual.rotation.y += delta * 2.0
        attack_visual.scale = Vector3.ONE * (1.0 + (0.72 - attack_left) * 8.0)
    if mega_jump_active:
        mega_jump_visual.rotation.y += delta * 3.0
    speed = 25.0 if turbo_left > 0 else 14.0
    distance += delta * speed
    _update_guardian(delta)
    if started:
        _update_orbit_sentinel(delta)
    if started:
        _update_frost_warden(delta)
    if not started:
        _update_camera(delta)
        return
    if phase == "race" and distance >= mission_target:
        _finish_run()
        _update_camera(delta)
        return
    rider.position.x = move_toward(rider.position.x, float(lane) * 3.1, delta * 12)
    rider.set("lean", lerpf(float(rider.get("lean")), float(lane), minf(1.0, delta * 5.0)))
    rider.set("boosting", turbo_left > 0)
    rider.rotation.z = lerpf(rider.rotation.z, (float(lane) * 3.1 - rider.position.x) * -0.14, delta * 5)
    rider.rotation.y = sin(distance * 0.03) * 0.035
    _update_run_items(delta)
    _update_neon_signals()
    _update_canyon_routes()
    _update_harbor_cargo_relay()
    _update_glacier_mission()
    _update_camera(delta)
    if not started:
        return
    if world_choice == 0:
        for object in moving.get_children():
            object.position.z += delta * speed
            if object.position.z > 12:
                object.position.z -= 155
    for marker in road_marks.get_children():
        marker.position.z += delta * speed
        if marker.position.z > 16:
            marker.position.z -= 144
    # In the actual level, avoid pausing the action for more questions.
    # Manual _ask() remains available for diagnostics and future missions.
    if phase != "race":
        quiz_time -= delta
        if quiz_time <= 0:
            _ask()
    _refresh_hud()
