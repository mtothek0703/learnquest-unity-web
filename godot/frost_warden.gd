extends Node3D
## Skyway V47: original curved frost-dragon mesh with animated jaw and fins.
## All surfaces are generated locally once; no paid or third-party assets.
var active := false
var elapsed := 0.0
var hit_flash := 0.0
var jaw: Node3D
var fins: Array[Node3D] = []
var heart: MeshInstance3D

func _material(tint: Color, glow: bool = false, vertex_colors: bool = false) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.vertex_color_use_as_albedo = vertex_colors
    material.metallic = 0.36
    material.roughness = 0.34
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    if glow:
        material.emission_enabled = true
        material.emission = tint
        material.emission_energy_multiplier = 2.0
    return material

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(a)
    tool.add_vertex(b)
    tool.add_vertex(c)
    tool.add_vertex(a)
    tool.add_vertex(c)
    tool.add_vertex(d)

func _body_point(section: int, around: int) -> Vector3:
    var t := float(section) / 48.0
    var angle := TAU * float(around) / 24.0
    var radius := 0.22 + 1.15 * pow(sin(t * PI), 0.8)
    var wave := sin(t * TAU * 1.25) * 0.40
    return Vector3(wave + cos(angle) * radius, 0.55 + 3.75 * t, -0.55 + sin(angle) * radius * 0.84 - 0.65 * t)

func _body_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for section in range(48):
        var t := float(section) / 48.0
        for around in range(24):
            var glint := 0.14 if around % 6 == 0 else 0.0
            var tint := Color("#174e85").lerp(Color("#c9f8ff"), clampf(0.12 + t * 0.65 + glint, 0.0, 1.0))
            _quad(tool, _body_point(section, around), _body_point(section + 1, around),
                _body_point(section + 1, around + 1), _body_point(section, around + 1), tint)
    tool.generate_normals()
    return tool.commit()

func _fin_point(length_step: int, width_step: int) -> Vector3:
    var t := float(length_step) / 30.0
    var v := float(width_step) / 8.0
    return Vector3(0.45 + 3.55 * t, 2.6 + sin(t * PI) * 1.20 + v * 0.38,
        -0.65 + (v - 0.5) * (1.9 - t) + 0.24 * sin(t * TAU))

func _fin_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(30):
        var t := float(step) / 30.0
        for across in range(8):
            var v := float(across) / 8.0
            var tint := Color("#126eac").lerp(Color("#c9faff"), 0.22 + t * 0.47 + v * 0.22)
            if across == 0 or across == 7:
                tint = tint.lerp(Color("#73f9ff"), 0.6)
            _quad(tool, _fin_point(step, across), _fin_point(step + 1, across),
                _fin_point(step + 1, across + 1), _fin_point(step, across + 1), tint)
    tool.generate_normals()
    return tool.commit()

func _jaw_point(section: int, around: int) -> Vector3:
    var t := float(section) / 12.0
    var angle := TAU * float(around) / 16.0
    var radius := (0.35 + 0.32 * sin(t * PI)) * (1.0 - 0.65 * t)
    return Vector3(cos(angle) * radius, -0.12 - t * 0.42 + sin(angle) * radius * 0.22, 0.55 + t * 1.25)

func _jaw_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for section in range(12):
        for around in range(16):
            _quad(tool, _jaw_point(section, around), _jaw_point(section + 1, around),
                _jaw_point(section + 1, around + 1), _jaw_point(section, around + 1), Color("#91c8ed"))
    tool.generate_normals()
    return tool.commit()

func _ready() -> void:
    var shell := MeshInstance3D.new()
    shell.name = "Sculpted frost dragon body"
    shell.mesh = _body_mesh()
    shell.material_override = _material(Color.WHITE, false, true)
    add_child(shell)

    var fin_mesh := _fin_mesh()
    var fin_material := _material(Color.WHITE, false, true)
    for side in [-1, 1]:
        var pivot := Node3D.new()
        pivot.name = "Animated frost fin left" if side < 0 else "Animated frost fin right"
        pivot.scale.x = float(side)
        add_child(pivot)
        var fin := MeshInstance3D.new()
        fin.name = "Curved ice fin"
        fin.mesh = fin_mesh
        fin.material_override = fin_material
        pivot.add_child(fin)
        fins.append(pivot)

    jaw = Node3D.new()
    jaw.name = "Articulated frost jaw"
    jaw.position = Vector3(0.0, 3.62, 0.12)
    add_child(jaw)
    var mouth := MeshInstance3D.new()
    mouth.name = "Sculpted lower jaw"
    mouth.mesh = _jaw_mesh()
    mouth.material_override = _material(Color.WHITE, false, true)
    jaw.add_child(mouth)

    heart = MeshInstance3D.new()
    heart.name = "Aurora dragon heart"
    var core_mesh := SphereMesh.new()
    core_mesh.radial_segments = 20
    core_mesh.rings = 12
    heart.mesh = core_mesh
    heart.material_override = _material(Color("#73f9ff"), true)
    heart.position = Vector3(0, 2.05, 0.95)
    heart.scale = Vector3(0.48, 0.64, 0.22)
    add_child(heart)

    for side in [-1.0, 1.0]:
        var eye := MeshInstance3D.new()
        eye.name = "Luminous frost eye"
        eye.mesh = core_mesh
        eye.material_override = _material(Color("#ffca7d"), true)
        eye.position = Vector3(side * 0.29, 3.80, 0.43)
        eye.scale = Vector3(0.13, 0.16, 0.12)
        add_child(eye)

func take_hit() -> void:
    hit_flash = 0.55

func _process(delta: float) -> void:
    if not active:
        return
    elapsed += delta
    hit_flash = maxf(0.0, hit_flash - delta)
    rotation.y = sin(elapsed * 0.55) * 0.13
    position.y = 0.65 + sin(elapsed * 1.5) * 0.16
    jaw.rotation.x = 0.10 + 0.20 * (0.5 + 0.5 * sin(elapsed * 2.7))
    heart.scale = Vector3(0.48, 0.64, 0.22) * (1.0 + 0.10 * sin(elapsed * 5.0) + hit_flash * 0.65)
    for index in range(fins.size()):
        fins[index].rotation.z = sin(elapsed * 1.8 + float(index) * 1.2) * 0.18
        fins[index].rotation.y = sin(elapsed * 1.2 + float(index)) * 0.08
