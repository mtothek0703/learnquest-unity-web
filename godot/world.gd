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
var options: Array[int] = []
var answer_buttons: Array[Button] = []
var combo := 0
var turbo_left := 0.0
var rider: Node3D
var moving: Node3D
var road_marks: Node3D
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
    resource.background_mode = Environment.BG_COLOR
    resource.background_color = Color("#0b1030")
    resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    resource.ambient_light_color = Color("#727bc8")
    resource.ambient_light_energy = 0.7
    env.environment = resource
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-42, -28, 0)
    sun.light_energy = 1.1
    add_child(sun)

    var camera := Camera3D.new()
    camera.position = Vector3(0, 4.1, 8.0)
    camera.rotation_degrees = Vector3(-12, 180, 0)
    camera.look_at(Vector3(0, 1.35, -7.0))
    camera.fov = 64
    add_child(camera)
    camera.current = true

    cube(self, Vector3(0, -0.35, -55), Vector3(11, 0.6, 160), Color("#141633"))
    for side in [-1, 1]:
        cube(self, Vector3(side * 5.5, 0, -55), Vector3(0.2, 0.3, 160), Color("#27f5ff"), true)
    road_marks = Node3D.new()
    road_marks.name = "Animated lane markers"
    add_child(road_marks)
    for z in range(-125, 20, 8):
        for side in [-1, 1]:
            cube(road_marks, Vector3(side * 1.8, -0.025, z), Vector3(0.15, 0.05, 3.4), Color("#ad62ff"), true)

    rider = Node3D.new()
    rider.name = "Hover Racer"
    add_child(rider)
    rider.position.z = -4.5
    cube(rider, Vector3(0, 0.32, 0), Vector3(1.55, 0.16, 2.35), Color("#121735"))
    cube(rider, Vector3(0, 0.42, 0), Vector3(0.8, 0.08, 1.8), Color("#843aff"))
    for side in [-1, 1]:
        cube(rider, Vector3(side * 0.68, 0.43, 0), Vector3(0.12, 0.1, 2.15), Color("#16ecff"), true)
        cube(rider, Vector3(side * 0.53, 0.25, 0.98), Vector3(0.22, 0.22, 0.25), Color("#ff4fb9"), true)
        cube(rider, Vector3(side * 0.25, 0.82, 0), Vector3(0.26, 0.7, 0.4), Color("#18254e"))
        cube(rider, Vector3(side * 0.43, 1.57, 0), Vector3(0.25, 0.65, 0.27), Color("#6245d4"))
    sphere(rider, Vector3(0, 1.69, 0), Vector3(0.42, 0.52, 0.32), Color("#614ad9"))
    sphere(rider, Vector3(0, 2.48, 0), Vector3(0.48, 0.52, 0.46), Color("#161b3c"))
    sphere(rider, Vector3(0, 2.49, -0.38), Vector3(0.38, 0.21, 0.13), Color("#05eaff"), true)
    cube(rider, Vector3(0, 1.56, 0.38), Vector3(0.55, 0.55, 0.25), Color("#fcad35"), true)

    moving = Node3D.new()
    moving.name = "Moving city"
    add_child(moving)
    for i in range(22):
        var side: int = -1 if i % 2 == 0 else 1
        var z := -12.0 - i * 6.5
        var height := float(7 + (i % 5) * 3)
        var root := Node3D.new()
        root.position = Vector3(side * (8 + (i % 3) * 2), 0, z)
        moving.add_child(root)
        cube(root, Vector3(0, height / 2.0, 0), Vector3(3.0, height, 3.0), Color("#202443"))
        for floor_index in range(1, int(height), 2):
            cube(root, Vector3(0, float(floor_index), -1.54), Vector3(2.65, 0.12, 0.06),
                Color("#21ecff") if i % 2 == 0 else Color("#fd47c1"), true)
        cube(root, Vector3(0, height, 0), Vector3(3.2, 0.25, 3.2), Color("#f9b135"), true)
    for i in range(12):
        var crystal := Node3D.new()
        crystal.position = Vector3(7.5 if i % 2 == 0 else -7.5, 1.5, -13.0 - i * 11.0)
        moving.add_child(crystal)
        cube(crystal, Vector3.ZERO, Vector3(1.4, 2.2, 1.4), Color("#39e5ff") if i % 2 == 0 else Color("#fd47c1"), true).rotation_degrees = Vector3(27, 45, 15)

func _make_button(label_text: String, callback: Callable, parent: Node) -> Button:
    var b := Button.new()
    b.text = label_text
    b.custom_minimum_size = Vector2(155, 55)
    b.add_theme_font_size_override("font_size", 20)
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
    top.position = Vector2(15, 12)
    top.custom_minimum_size = Vector2(360, 56)
    canvas.add_child(top)
    hud = Label.new()
    hud.add_theme_font_size_override("font_size", 22)
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
    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    controls.add_child(spacer)
    _make_button("TURBO", _use_turbo, controls)

    splash = PanelContainer.new()
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
    sub.text = "NEON SPEED WORLD · ENGLISH"
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

func _change_grade(delta: int) -> void:
    grade = clampi(grade + delta, 1, 10)
    grade_label.text = "SCHULKLASSE: %d" % grade

func _start_game() -> void:
    started = true
    splash.hide()
    _refresh_hud()

func _group() -> int:
    return 0 if grade <= 3 else (1 if grade <= 6 else 2)

func _ask() -> void:
    quiz_active = true
    correct_index = randi_range(0, WORDS[_group()].size() - 1)
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
        hud.text = "LVL %d   XP %d   POWER %d/100   %dm" % [1 + xp / 200, xp, power, int(distance)]

func _process(delta: float) -> void:
    if feedback_time > 0:
        feedback_time -= delta
        if feedback_time <= 0:
            info_label.text = ""
    if not started or quiz_active:
        return
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
    rider.position.y = sin(Time.get_ticks_msec() * 0.004) * 0.08
    rider.rotation.z = lerpf(rider.rotation.z, (float(lane) * 3.1 - rider.position.x) * -0.14, delta * 5)
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
