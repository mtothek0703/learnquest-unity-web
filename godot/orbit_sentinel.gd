extends Node3D
## Skyway V46: original sculpted orbital sentinel, no downloaded or paid assets.
## Reused mesh surfaces and simple animation keep the boss suitable for WebGL.
var active := false
var elapsed := 0.0
var hit_flash := 0.0
var core: MeshInstance3D
var orbit: Node3D
var wings: Array[Node3D] = []

func _material(tint: Color, glow: bool = false, vertex_colors: bool = false) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.vertex_color_use_as_albedo = vertex_colors
    material.metallic = 0.64
    material.roughness = 0.23
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    if glow:
        material.emission_enabled = true
        material.emission = tint
        material.emission_energy_multiplier = 2.3
    return material

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(a)
    tool.add_vertex(b)
    tool.add_vertex(c)
    tool.add_vertex(a)
    tool.add_vertex(c)
    tool.add_vertex(d)

func _hull_point(level: int, segment: int) -> Vector3:
    var t := float(level) / 20.0
    var angle := TAU * float(segment) / 28.0
    var radius := 0.18 + 1.68 * sin(t * PI)
    var ridge := 1.0 + 0.085 * cos(angle * 8.0 + t * 4.0)
    return Vector3(cos(angle) * radius * ridge, 0.8 + t * 2.7, sin(angle) * radius * 0.72 * ridge)

func _hull_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for level in range(20):
        var t := float(level) / 20.0
        for segment in range(28):
            var accent := 0.18 if segment % 4 == 0 else 0.0
            var tint := Color("#152b59").lerp(Color("#8ca4dc"), t * 0.65 + accent)
            _quad(tool, _hull_point(level, segment), _hull_point(level + 1, segment),
                _hull_point(level + 1, segment + 1), _hull_point(level, segment + 1), tint)
    tool.generate_normals()
    return tool.commit()

func _wing_point(step: int, across: int) -> Vector3:
    var t := float(step) / 32.0
    var v := float(across) / 8.0
    var x := 0.9 + 4.5 * t
    var y := 1.95 + 0.95 * sin(t * PI) - 0.50 * t + 0.30 * sin(v * PI)
    var z := -0.6 + 2.15 * (v - 0.5) * (1.0 - t * 0.62) + sin(t * PI) * 0.22
    return Vector3(x, y, z)

func _wing_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(32):
        var t := float(step) / 32.0
        for across in range(8):
            var v := float(across) / 8.0
            var tint := Color("#23528b").lerp(Color("#a2ddf5"), 0.25 + t * 0.42 + v * 0.24)
            if across == 0 or across == 7:
                tint = tint.lerp(Color("#5afcff"), 0.6)
            _quad(tool, _wing_point(step, across), _wing_point(step + 1, across),
                _wing_point(step + 1, across + 1), _wing_point(step, across + 1), tint)
    tool.generate_normals()
    return tool.commit()

func _ready() -> void:
    var shell := MeshInstance3D.new()
    shell.name = "Sculpted sentinel hull"
    shell.mesh = _hull_mesh()
    shell.material_override = _material(Color.WHITE, false, true)
    add_child(shell)

    var wing_mesh := _wing_mesh()
    var wing_material := _material(Color.WHITE, false, true)
    for side in [-1, 1]:
        var pivot := Node3D.new()
        pivot.name = "Articulated wing left" if side < 0 else "Articulated wing right"
        pivot.scale.x = float(side)
        add_child(pivot)
        var wing := MeshInstance3D.new()
        wing.name = "Curved flight wing"
        wing.mesh = wing_mesh
        wing.material_override = wing_material
        pivot.add_child(wing)
        wings.append(pivot)

    core = MeshInstance3D.new()
    core.name = "Sentinel reactor core"
    var reactor_mesh := SphereMesh.new()
    reactor_mesh.radial_segments = 24
    reactor_mesh.rings = 12
    core.mesh = reactor_mesh
    core.material_override = _material(Color("#a2fcff"), true)
    core.position = Vector3(0, 2.0, 1.25)
    core.scale = Vector3(0.68, 0.75, 0.32)
    add_child(core)

    orbit = Node3D.new()
    orbit.name = "Animated orbital rings"
    orbit.position = Vector3(0, 2.05, 0)
    add_child(orbit)
    for index in range(3):
        var ring := MeshInstance3D.new()
        ring.name = "Orbital energy ring %d" % index
        var torus := TorusMesh.new()
        torus.inner_radius = 2.15 + float(index) * 0.32
        torus.outer_radius = 2.23 + float(index) * 0.32
        torus.rings = 48
        torus.ring_segments = 8
        ring.mesh = torus
        ring.material_override = _material(Color("#55f6f2") if index % 2 == 0 else Color("#ff8df7"), true)
        ring.rotation = Vector3(0.42 + float(index) * 0.38, 0.2 * float(index), 0.22)
        orbit.add_child(ring)

func take_hit() -> void:
    hit_flash = 0.55

func _process(delta: float) -> void:
    if not active:
        return
    elapsed += delta
    hit_flash = maxf(0.0, hit_flash - delta)
    orbit.rotation.y += delta * 0.75
    orbit.rotation.z = sin(elapsed * 0.6) * 0.18
    core.scale = Vector3(0.68, 0.75, 0.32) * (1.0 + 0.12 * sin(elapsed * 5.0) + hit_flash * 0.55)
    for index in range(wings.size()):
        wings[index].rotation.z = sin(elapsed * 1.5 + float(index) * 0.9) * 0.12
        wings[index].rotation.y = sin(elapsed * 0.9 + float(index)) * 0.09
