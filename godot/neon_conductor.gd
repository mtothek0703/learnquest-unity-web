extends Node3D
## Neon City circuit conductor: an original procedural 3D boss with a
## continuous sculpted hull, articulated swept fins and orbiting energy coils.
## No downloaded assets, collision bodies, new controls or extra render passes.

var active := false
var elapsed := 0.0
var hit_flash := 0.0
var core: MeshInstance3D
var coils: Node3D
var fins: Array[Node3D] = []

func _material(tint: Color, glow: bool = false, vertex_colors: bool = false) -> StandardMaterial3D:
    var result := StandardMaterial3D.new()
    result.albedo_color = tint
    result.vertex_color_use_as_albedo = vertex_colors
    result.metallic = 0.55
    result.roughness = 0.30
    result.cull_mode = BaseMaterial3D.CULL_DISABLED
    if glow:
        result.emission_enabled = true
        result.emission = tint
        result.emission_energy_multiplier = 2.3
    return result

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(a)
    tool.add_vertex(b)
    tool.add_vertex(c)
    tool.add_vertex(a)
    tool.add_vertex(c)
    tool.add_vertex(d)

func _hull_point(level: int, segment: int) -> Vector3:
    var t := float(level) / 24.0
    var theta := TAU * float(segment) / 32.0
    var radius := 0.12 + 1.28 * pow(sin(t * PI), 0.72)
    var ridge := 1.0 + 0.11 * cos(theta * 6.0 + t * 5.0)
    return Vector3(cos(theta) * radius * ridge, 0.65 + t * 4.2, sin(theta) * radius * 0.78 * ridge)

func _hull_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for level in range(24):
        var t := float(level) / 24.0
        for segment in range(32):
            var tint := Color("#355a9c").lerp(Color("#e2c8ff"), 0.20 + 0.66 * t)
            if segment % 8 == 0:
                tint = tint.lerp(Color("#5ceeff"), 0.45)
            _quad(tool, _hull_point(level, segment), _hull_point(level + 1, segment),
                _hull_point(level + 1, segment + 1), _hull_point(level, segment + 1), tint)
    tool.generate_normals()
    return tool.commit()

func _fin_point(step: int, across: int) -> Vector3:
    var t := float(step) / 28.0
    var v := float(across) / 8.0
    var x := 0.78 + t * 3.55
    var y := 2.2 + 1.15 * sin(t * PI) + 0.24 * cos(v * PI) - 0.38 * t
    var z := -0.55 + (v - 0.5) * (2.15 - 1.15 * t) + 0.28 * sin(t * PI)
    return Vector3(x, y, z)

func _fin_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(28):
        for across in range(8):
            var t := float(step) / 28.0
            var v := float(across) / 8.0
            var tint := Color("#345eb1").lerp(Color("#ffa5ed"), 0.20 + 0.52 * t + 0.25 * v)
            if across == 0 or across == 7:
                tint = tint.lerp(Color("#68f7ff"), 0.70)
            _quad(tool, _fin_point(step, across), _fin_point(step + 1, across),
                _fin_point(step + 1, across + 1), _fin_point(step, across + 1), tint)
    tool.generate_normals()
    return tool.commit()

func _ready() -> void:
    var shell := MeshInstance3D.new()
    shell.name = "Continuous ribbed conductor body"
    shell.mesh = _hull_mesh()
    shell.material_override = _material(Color.WHITE, false, true)
    add_child(shell)

    var fin_mesh := _fin_mesh()
    var fin_material := _material(Color.WHITE, false, true)
    for side in [-1, 1]:
        var pivot := Node3D.new()
        pivot.name = "Articulated circuit fin left" if side < 0 else "Articulated circuit fin right"
        pivot.scale.x = float(side)
        add_child(pivot)
        var fin := MeshInstance3D.new()
        fin.name = "Curved continuous energy fin"
        fin.mesh = fin_mesh
        fin.material_override = fin_material
        pivot.add_child(fin)
        fins.append(pivot)

    core = MeshInstance3D.new()
    core.name = "Pulsating magenta conductor core"
    var core_mesh := SphereMesh.new()
    core_mesh.radial_segments = 24
    core_mesh.rings = 12
    core.mesh = core_mesh
    core.material_override = _material(Color("#ff75e3"), true)
    core.position = Vector3(0.0, 2.65, 1.0)
    core.scale = Vector3(0.68, 0.86, 0.30)
    add_child(core)

    coils = Node3D.new()
    coils.name = "Counter-rotating conductor coils"
    coils.position = Vector3(0.0, 2.55, 0.0)
    add_child(coils)
    for index in range(3):
        var ring := MeshInstance3D.new()
        ring.name = "Neon circuit torus %d" % index
        var torus := TorusMesh.new()
        torus.inner_radius = 1.70 + float(index) * 0.29
        torus.outer_radius = 1.81 + float(index) * 0.29
        torus.rings = 40
        torus.ring_segments = 8
        ring.mesh = torus
        ring.material_override = _material(Color("#5af5ff") if index % 2 == 0 else Color("#ff9ce7"), true)
        ring.rotation = Vector3(0.3 + float(index) * 0.37, 0.4 * float(index), 0.2)
        coils.add_child(ring)

func take_hit() -> void:
    hit_flash = 0.65

func _process(delta: float) -> void:
    if not active:
        return
    elapsed += delta
    hit_flash = maxf(0.0, hit_flash - delta)
    coils.rotation.y += delta * 0.92
    coils.rotation.z = sin(elapsed * 0.6) * 0.20
    core.scale = Vector3(0.68, 0.86, 0.30) * (1.0 + 0.12 * sin(elapsed * 5.0) + hit_flash * 0.45)
    for index in range(fins.size()):
        fins[index].rotation.z = sin(elapsed * 1.7 + float(index) * 0.8) * 0.16
        fins[index].rotation.y = sin(elapsed * 1.1 + float(index)) * 0.09
