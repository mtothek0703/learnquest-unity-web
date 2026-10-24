extends Node3D

# LearnQuest 3D: mobile-first Godot 4 browser prototype, no third-party assets.
const WORDS := [
    [["Hund","dog"],["Katze","cat"],["Sonne","sun"],["Apfel","apple"],["Haus","house"],["Buch","book"]],
    [["Brücke","bridge"],["Garten","garden"],["Wetter","weather"],["Schule","school"],["Freund","friend"],["Fenster","window"]],
    [["Abenteuer","adventure"],["Umwelt","environment"],["Entscheidung","decision"],["Erfahrung","experience"],["entdecken","discover"],["wichtig","important"]]
]
# Complete vocabulary missions first; racing is a continuous, finite level.
const TASKS_PER_ROUND := 3
const VERSION_LABEL := "V44"
const WORLD_NAMES := ["NEON CITY", "KRISTALL-CANYON", "STERNEN-HAFEN"]
const WORLD_GOALS := [800.0, 950.0, 1100.0]
const HARBOR_BONUS_TARGET := 4
const SHIELD_COST := 30
const MEGA_JUMP_COST := 30
const ATTACK_COST := 45
const GUARDIAN_HEALTH := 3
const GUARDIAN_SPAWN_FRACTION := 0.55
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
var moving: Node3D
var skyway_zone: Node3D
var canyon_zone: Node3D
var harbor_zone: Node3D
var harbor_crystals := 0
var guardian: Node3D
var guardian_beam: MeshInstance3D
var guardian_hp := GUARDIAN_HEALTH
var guardian_active := false
var guardian_defeated := false
var guardian_attack_timer := 0.0
var guardian_warning_left := 0.0
var guardian_lane := 0
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
var splash: PanelContainer
var controls_grid: GridContainer
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
    _create_powerup_effects()

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
    _create_guardian()

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

func _apply_world_theme() -> void:
    # World selection changes real 3D geometry, lighting and the race mission.
    mission_target = float(WORLD_GOALS[world_choice])
    if skyway_zone != null:
        skyway_zone.visible = world_choice == 0
    if canyon_zone != null:
        canyon_zone.visible = world_choice == 1
    if harbor_zone != null:
        harbor_zone.visible = world_choice == 2
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

func _change_world() -> void:
    if phase != "menu":
        return
    world_choice = (world_choice + 1) % WORLD_NAMES.size()
    _apply_world_theme()
    world_button.text = "WELT: %s" % WORLD_NAMES[world_choice]
    _refresh_hud()

func _show_world_menu() -> void:
    if phase != "results":
        return
    phase = "menu"
    started = false
    end_panel.hide()
    guardian.visible = false
    guardian_beam.visible = false
    splash.show()
    _refresh_hud()

func _create_powerup_effects() -> void:
    # Three cheap, mobile-friendly visual effects stay attached to the racer.
    shield_visual = MeshInstance3D.new()
    shield_visual.name = "Active energy shield"
    var bubble := SphereMesh.new()
    bubble.radius = 1.4
    bubble.height = 2.8
    shield_visual.mesh = bubble
    var shield_mat := StandardMaterial3D.new()
    shield_mat.albedo_color = Color(0.17, 0.83, 1.0, 0.18)
    shield_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    shield_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    shield_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    shield_mat.emission_enabled = true
    shield_mat.emission = Color(0.06, 0.40, 0.65)
    shield_mat.emission_energy_multiplier = 1.25
    shield_visual.material_override = shield_mat
    shield_visual.position.y = 1.35
    rider.add_child(shield_visual)
    shield_visual.visible = false

    mega_jump_visual = MeshInstance3D.new()
    mega_jump_visual.name = "Mega jump energy"
    var mega_ring := TorusMesh.new()
    mega_ring.inner_radius = 0.68
    mega_ring.outer_radius = 0.80
    mega_jump_visual.mesh = mega_ring
    mega_jump_visual.material_override = mat(Color("#ffe36c"), true)
    mega_jump_visual.rotation_degrees.x = 90.0
    mega_jump_visual.position.y = 0.20
    rider.add_child(mega_jump_visual)
    mega_jump_visual.visible = false

    attack_visual = MeshInstance3D.new()
    attack_visual.name = "Super attack shockwave"
    var shockwave := SphereMesh.new()
    shockwave.radius = 1.2
    shockwave.height = 2.4
    attack_visual.mesh = shockwave
    var attack_mat := StandardMaterial3D.new()
    attack_mat.albedo_color = Color(1.0, 0.22, 0.75, 0.25)
    attack_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    attack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    attack_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    attack_mat.emission_enabled = true
    attack_mat.emission = Color(0.7, 0.10, 0.50)
    attack_mat.emission_energy_multiplier = 1.6
    attack_visual.material_override = attack_mat
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
    guardian_active = false
    guardian_defeated = false
    guardian_attack_timer = 0.0
    guardian_warning_left = 0.0
    guardian.visible = false
    guardian.set("active", false)
    guardian_beam.visible = false
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
        var stars_earned: int = clampi(lives, 1, 3) + (1 if world_choice == 1 and guardian_defeated else 0) + (1 if world_choice == 2 and harbor_crystals >= HARBOR_BONUS_TARGET else 0)
        total_stars += stars_earned
        total_reward_xp += xp
        reward_label.text = "+%d STERNE  |  +%d XP\nGESAMT: %d STERNE" % [stars_earned, xp, total_stars]
        if world_choice == 1 and guardian_defeated:
            reward_label.text += "\nKRISTALL-WÄCHTER BESIEGT: +1 BONUSSTERN!"
        if world_choice == 2 and harbor_crystals >= HARBOR_BONUS_TARGET:
            reward_label.text += "\nHAFEN-MISSION ERFÜLLT: +1 BONUSSTERN!"
    else:
        reward_label.text = "NOCH %dm BIS ZUM ZIEL\nVERSUCHE ES ERNEUT!" % maxi(0, int(mission_target - distance))
    phase = "results"
    guardian.visible = false
    guardian.set("active", false)
    guardian_beam.visible = false
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
func _apply_mobile_layout(viewport_width: float) -> void:
    var narrow := viewport_width < 720.0
    mobile_hud_layout = narrow
    hud_panel.custom_minimum_size.x = minf(360.0, maxf(0.0, viewport_width - 30.0)) if narrow else 360.0
    progress_bar.custom_minimum_size.x = hud_panel.custom_minimum_size.x
    hud.add_theme_font_size_override("font_size", 16 if narrow else 18)
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
    phase = "training"
    training_correct = 0
    combo = 0
    previous_quiz_index = -1
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
            if guardian_active and world_choice == 1:
                hud.text += "\nKRISTALL-WÄCHTER %d/%d  %s" % [guardian_hp, GUARDIAN_HEALTH, "LASER!" if guardian_warning_left > 0.0 else "ANGRIFF LADEN"]
            if world_choice == 2:
                hud.text += "\nHAFEN-MISSION: %d/%d ENERGIEKRISTALLE" % [mini(harbor_crystals, HARBOR_BONUS_TARGET), HARBOR_BONUS_TARGET]
    if progress_bar != null:
        progress_bar.visible = phase == "race"
        progress_bar.max_value = mission_target
        progress_bar.value = clampf(distance, 0.0, mission_target)

# Follow the racer on lane changes and jumps; widen the view during turbo.
func _update_camera(delta: float) -> void:
    if chase_camera == null or rider == null:
        return
    var racing := started and not quiz_active
    var boost := racing and turbo_left > 0.0
    var x := rider.position.x * 0.36 if racing else 0.0
    var y := rider.position.y * 0.25 if racing else 0.0
    chase_camera.position = chase_camera.position.lerp(Vector3(x, 4.3 + y, 10.1 if boost else 9.0), clampf(delta * 4.5, 0.0, 1.0))
    chase_camera.look_at(Vector3(rider.position.x * 0.42 if racing else 0.0, 1.5 + rider.position.y * 0.45 if racing else 1.5, 0.5), Vector3.UP)
    chase_camera.fov = lerpf(chase_camera.fov, 74.0 if boost else 64.0, clampf(delta * 3.0, 0.0, 1.0))

func _process(delta: float) -> void:
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
        var pulse := 1.0 + sin(distance * 0.24) * 0.04
        shield_visual.scale = Vector3.ONE * pulse
    attack_visual.visible = attack_left > 0.0
    if attack_visual.visible:
        attack_visual.scale = Vector3.ONE * (1.0 + (0.72 - attack_left) * 8.0)
    if mega_jump_active:
        mega_jump_visual.rotation.y += delta * 3.0
    speed = 25.0 if turbo_left > 0 else 14.0
    distance += delta * speed
    _update_guardian(delta)
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
