extends Node3D
## Original lightweight rider trousers and articulated aerodynamic knee armor.
## Hand-shaped 3D surfaces, vertex-color fabric and emissive seams; no licensed
## assets, physics changes, texture downloads or per-frame mesh regeneration.

var clock: float = 0.0
var knee_pivot: Node3D
var light_material: StandardMaterial3D

func _ready() -> void:
    _build_armor()

func _process(delta: float) -> void:
    clock += delta
    var rider := get_parent().get_parent().get_parent() as Node3D
    var lean := float(rider.get("lean")) if rider != null else 0.0
    var turbo := bool(rider.get("boosting")) if rider != null else false
    if is_instance_valid(knee_pivot):
        var target := (0.14 if turbo else 0.0) + lean * 0.08
        knee_pivot.rotation.x = lerpf(knee_pivot.rotation.x, target, minf(1.0, delta * 7.0))
    if light_material != null:
        light_material.emission_energy_multiplier = 1.45 + (0.75 if turbo else 0.12) * (0.5 + 0.5 * sin(clock * (8.0 if turbo else 2.5)))

func _fabric() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.metallic = 0.22
    material.roughness = 0.52
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _neon() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.15, 0.95, 1.0)
    material.emission_enabled = true
    material.emission = Color(0.04, 0.55, 0.92)
    material.emission_energy_multiplier = 1.65
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _build_armor() -> void:
    var cloth := _fabric()
    light_material = _neon()
    var trousers := MeshInstance3D.new()
    trousers.name = "TailoredTrouserShell"
    trousers.mesh = _trouser_mesh()
    trousers.material_override = cloth
    add_child(trousers)
    var seams := MeshInstance3D.new()
    seams.name = "LuminousSideSeams"
    seams.mesh = _side_seam_mesh()
    seams.material_override = light_material
    add_child(seams)
    knee_pivot = Node3D.new()
    knee_pivot.name = "KneeArmorPivot"
    knee_pivot.position = Vector3(0.0, -0.17, 0.0)
    add_child(knee_pivot)
    var guard := MeshInstance3D.new()
    guard.name = "CurvedKneeGuard"
    guard.mesh = _knee_guard_mesh()
    guard.material_override = cloth
    knee_pivot.add_child(guard)
    var trim := MeshInstance3D.new()
    trim.name = "KneeNeonPiping"
    trim.mesh = _knee_trim_mesh()
    trim.material_override = light_material
    knee_pivot.add_child(trim)

func _trouser_point(t: float, angle: float) -> Vector3:
    var thigh := 0.215 - 0.048 * t + 0.018 * sin(t * PI)
    var depth := 0.177 - 0.020 * t + 0.018 * sin(t * PI)
    return Vector3(
        cos(angle) * thigh,
        0.16 - 0.61 * t,
        0.015 + sin(angle) * depth + 0.014 * sin(t * PI)
    )

func _trouser_vertex(tool: SurfaceTool, t: float, angle: float) -> void:
    var fabric_dark := Color(0.10, 0.09, 0.29)
    var fabric_light := Color(0.43, 0.18, 0.59)
    var sheen := 0.86 + 0.14 * maxf(0.0, sin(angle))
    tool.set_color(fabric_dark.lerp(fabric_light, (1.0 - t) * 0.7) * sheen)
    tool.add_vertex(_trouser_point(t, angle))

func _trouser_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 18
    const SIDES := 16
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        for side in range(SIDES):
            var a0 := TAU * float(side) / float(SIDES)
            var a1 := TAU * float(side + 1) / float(SIDES)
            _trouser_vertex(tool, t0, a0)
            _trouser_vertex(tool, t1, a0)
            _trouser_vertex(tool, t1, a1)
            _trouser_vertex(tool, t0, a0)
            _trouser_vertex(tool, t1, a1)
            _trouser_vertex(tool, t0, a1)
    tool.generate_normals()
    return tool.commit()

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
    tool.add_vertex(a)
    tool.add_vertex(c)
    tool.add_vertex(d)
    tool.add_vertex(a)
    tool.add_vertex(d)
    tool.add_vertex(b)

func _side_seam_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 18
    for angle in [0.24 * PI, 0.76 * PI]:
        for row in range(ROWS):
            var t0 := float(row) / float(ROWS)
            var t1 := float(row + 1) / float(ROWS)
            var offset := Vector3(0.0, 0.0, 0.012)
            _quad(tool,
                _trouser_point(t0, angle) + offset,
                _trouser_point(t0, angle + 0.055) + offset,
                _trouser_point(t1, angle) + offset,
                _trouser_point(t1, angle + 0.055) + offset)
    tool.generate_normals()
    return tool.commit()

func _knee_point(u: float, t: float) -> Vector3:
    var across := 2.0 * u - 1.0
    var arch := sqrt(maxf(0.0, 1.0 - across * across))
    return Vector3(
        across * (0.225 - 0.045 * t),
        0.13 - 0.28 * t,
        0.17 + 0.10 * arch * sin(t * PI) + 0.022 * t
    )

func _knee_vertex(tool: SurfaceTool, u: float, t: float) -> void:
    var shade := Color(0.14, 0.15, 0.38).lerp(Color(0.44, 0.25, 0.68), 0.28 + 0.55 * t)
    tool.set_color(shade)
    tool.add_vertex(_knee_point(u, t))

func _knee_guard_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 10
    const COLUMNS := 14
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        for col in range(COLUMNS):
            var u0 := float(col) / float(COLUMNS)
            var u1 := float(col + 1) / float(COLUMNS)
            _knee_vertex(tool, u0, t0)
            _knee_vertex(tool, u0, t1)
            _knee_vertex(tool, u1, t1)
            _knee_vertex(tool, u0, t0)
            _knee_vertex(tool, u1, t1)
            _knee_vertex(tool, u1, t0)
    tool.generate_normals()
    return tool.commit()

func _knee_trim_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const COLUMNS := 14
    for band in [0.12, 0.82]:
        for col in range(COLUMNS):
            var u0 := float(col) / float(COLUMNS)
            var u1 := float(col + 1) / float(COLUMNS)
            var offset := Vector3(0.0, 0.0, 0.014)
            _quad(tool,
                _knee_point(u0, band) + offset,
                _knee_point(u1, band) + offset,
                _knee_point(u0, band + 0.035) + offset,
                _knee_point(u1, band + 0.035) + offset)
    tool.generate_normals()
    return tool.commit()
