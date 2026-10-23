extends Node3D

# LearnQuest 3D: mobile-first Godot 4 browser prototype, no third-party assets.
const WORDS := [
    [["Hund","dog"],["Katze","cat"],["Sonne","sun"],["Apfel","apple"],["Haus","house"],["Buch","book"]],
    [["Brücke","bridge"],["Garten","garden"],["Wetter","weather"],["Schule","school"],["Freund","friend"],["Fenster","window"]],
    [["Abenteuer","adventure"],["Umwelt","environment"],["Entscheidung","decision"],["Erfahrung","experience"],["entdecken","discover"],["wichtig","important"]]
]
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
var rider: Node3D
var chase_camera: Camera3D
var moving: Node3D
var skyway_zone: Node3D
var road_marks: Node3D
var run_items: Node3D
var lives := 3
var jump_left := 0.0
var hit_cooldown := 0.0
var end_panel: PanelContainer
var hud: Label
var splash: PanelContainer
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
    var sky_gradient := ProceduralSkyMaterial.new()
    # V14 visual overhaul: electric sunset instead of the old dark-blue sky.
    sky_gradient.sky_top_color = Color("#080d35")
    sky_gradient.sky_horizon_color = Color("#ff789b")
    sky_gradient.ground_horizon_color = Color("#ffbd8b")
    sky_gradient.ground_bottom_color = Color("#39265e")
    sky_gradient.use_debanding = true
    sky.sky_material = sky_gradient
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

    var zone_script = preload("res://neon_environment.gd")
    skyway_zone = zone_script.new()
    skyway_zone.name = "LearnQuest Skyway world"
    add_child(skyway_zone)

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
    if started and not quiz_active and jump_left <= 0.0:
        jump_left = 0.85

func _update_run_items(delta: float) -> void:
    hit_cooldown = maxf(0.0, hit_cooldown - delta)
    jump_left = maxf(0.0, jump_left - delta)
    rider.position.y = sin((1.0 - jump_left / 0.85) * PI) * 1.8 if jump_left > 0.0 else 0.0
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
    started = false
    quiz_active = false
    quiz_box.hide()
    end_panel.show()
    info_label.text = "RUNDE BEENDET - %d METER" % int(distance)
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

    var top := PanelContainer.new()
    _style_panel(top)
    top.position = Vector2(15, 12)
    top.custom_minimum_size = Vector2(360, 56)
    canvas.add_child(top)
    hud = Label.new()
    hud.add_theme_font_size_override("font_size", 18)
    top.add_child(hud)

    var controls := HBoxContainer.new()
    controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    controls.offset_top = -90
    controls.offset_bottom = -12
    controls.offset_left = 15
    controls.offset_right = -15
    controls.add_theme_constant_override("separation", 12)
    canvas.add_child(controls)
    _make_button("< LINKS", func(): _shift(-1), controls)
    _make_button("RECHTS >", func(): _shift(1), controls)
    _make_button("SPRINGEN", _jump, controls)
    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    controls.add_child(spacer)
    _make_button("TURBO", _use_turbo, controls)

    splash = PanelContainer.new()
    _style_panel(splash)
    splash.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    splash.position = Vector2(-220, -160)
    splash.custom_minimum_size = Vector2(440, 320)
    canvas.add_child(splash)
    var start_column := VBoxContainer.new()
    start_column.add_theme_constant_override("separation", 14)
    splash.add_child(start_column)
    var heading := Label.new()
    heading.text = "LEARNQUEST 3D"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 34)
    start_column.add_child(heading)
    var sub := Label.new()
    sub.text = "SKYWAY CITY - VOCAB RACE"
    sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    start_column.add_child(sub)
    grade_label = Label.new()
    grade_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    start_column.add_child(grade_label)
    var grade_buttons := HBoxContainer.new()
    grade_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
    start_column.add_child(grade_buttons)
    _make_button("−", func(): _change_grade(-1), grade_buttons)
    _make_button("+", func(): _change_grade(1), grade_buttons)
    _make_button("RENNEN STARTEN", _start_game, start_column)
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
    var end_title := Label.new()
    end_title.text = "RENNEN BEENDET!"
    end_title.add_theme_font_size_override("font_size", 30)
    end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    end_column.add_child(end_title)
    _make_button("NOCHMAL FAHREN", _reset_run, end_column)
    end_panel.hide()

func _change_grade(delta: int) -> void:
    grade = clampi(grade + delta, 1, 10)
    grade_label.text = "SCHULKLASSE: %d" % grade

func _start_game() -> void:
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
    question_label.text = WORDS[_group()][correct_index][0]
    for i in range(3):
        answer_buttons[i].text = WORDS[_group()][options[i]][1]
    quiz_box.show()

func _answer(index: int) -> void:
    if options[index] != correct_index:
        combo = 0
        info_label.text = "NOCHMAL VERSUCHEN!"
        feedback_time = 2.0
        return
    combo += 1
    xp += 45 if combo >= 3 else 35
    power = mini(power + 25, 100)
    info_label.text = "RICHTIG!  KOMBO x%d" % combo
    feedback_time = 2.0
    quiz_active = false
    quiz_box.hide()
    quiz_time = 9.0
    _refresh_hud()

func _shift(delta: int) -> void:
    if started and not quiz_active:
        lane = clampi(lane + delta, -1, 1)

func _use_turbo() -> void:
    if started and not quiz_active and power >= 40:
        power -= 40
        turbo_left = 5.0
        _refresh_hud()

func _refresh_hud() -> void:
    if hud != null:
        hud.text = "SKYWAY V20   LEBEN %d   XP %d   ENERGIE %d%%   KOMBO x%d   %dm" % [lives, xp, power, combo, int(distance)]

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
    skyway_zone.set("running", started and not quiz_active)
    skyway_zone.set("travel_speed", speed)
    if not started or quiz_active:
        _update_camera(delta)
        return
    if Input.is_key_pressed(KEY_SPACE) and jump_left <= 0.0:
        _jump()
    if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
        lane = -1
    elif Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
        lane = 1
    elif Input.is_key_pressed(KEY_S):
        lane = 0
    turbo_left = maxf(0.0, turbo_left - delta)
    speed = 25.0 if turbo_left > 0 else 14.0
    distance += delta * speed
    rider.position.x = move_toward(rider.position.x, float(lane) * 3.1, delta * 12)
    rider.set("lean", lerpf(float(rider.get("lean")), float(lane), minf(1.0, delta * 5.0)))
    rider.set("boosting", turbo_left > 0)
    rider.rotation.z = lerpf(rider.rotation.z, (float(lane) * 3.1 - rider.position.x) * -0.14, delta * 5)
    rider.rotation.y = sin(distance * 0.03) * 0.035
    _update_run_items(delta)
    _update_camera(delta)
    if not started:
        return
    for object in moving.get_children():
        object.position.z += delta * speed
        if object.position.z > 12:
            object.position.z -= 155
    for marker in road_marks.get_children():
        marker.position.z += delta * speed
        if marker.position.z > 16:
            marker.position.z -= 144
    quiz_time -= delta
    if quiz_time <= 0:
        _ask()
    _refresh_hud()
