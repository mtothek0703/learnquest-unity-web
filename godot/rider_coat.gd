extends Node3D
## Original sculpted coat-tail mesh for the imported glTF rider. No external
## textures, paid assets, physics changes, or per-frame mesh rebuilding.
## Two individually animated cloth panels frame the glowing jacket emblem.
var tails: Array[Node3D] = []
var clock: float = 0.0

func _ready() -> void:
    _build_coat()

func _process(delta: float) -> void:
    clock += delta
    var rider := get_parent().get_parent() as Node3D
    var lean := float(rider.get("lean")) if rider != null else 0.0
    var turbo := bool(rider.get("boosting")) if rider != null else false
    for i in range(tails.size()):
        var tail := tails[i]
        var side := -1.0 if i == 0 else 1.0
        var wind := -0.26 if turbo else -0.08
        tail.rotation.x = lerpf(tail.rotation.x, wind + sin(clock * (8.0 if turbo else 3.2) + float(i)) * 0.06, minf(1.0, delta * 6.0))
        tail.rotation.z = lerpf(tail.rotation.z, -lean * 0.16 + side * sin(clock * 2.7) * 0.035, minf(1.0, delta * 6.0))

func _fabric() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.metallic = 0.14
    material.roughness = 0.57
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _glow() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.19, 0.94, 1.0)
    material.emission_enabled = true
    material.emission = Color(0.06, 0.63, 0.92)
    material.emission_energy_multiplier = 1.7
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _build_coat() -> void:
    tails.clear()
    var fabric := _fabric()
    var trim := _glow()
    for i in range(2):
        var side := -1.0 if i == 0 else 1.0
        var pivot := Node3D.new()
        pivot.name = "LeftCoatTail" if i == 0 else "RightCoatTail"
        pivot.position = Vector3(side * 0.34, 1.96, 0.73)
        add_child(pivot)
        var cloth := MeshInstance3D.new()
        cloth.name = "SculptedCloth"
        cloth.mesh = _cloth_mesh(side)
        cloth.material_override = fabric
        pivot.add_child(cloth)
        var seams := MeshInstance3D.new()
        seams.name = "NeonSeams"
        seams.mesh = _seam_mesh(side)
        seams.material_override = trim
        pivot.add_child(seams)
        tails.append(pivot)
    var collar := MeshInstance3D.new()
    collar.name = "RaisedSculptedCollar"
    collar.mesh = _collar_mesh(false)
    collar.material_override = fabric
    add_child(collar)
    var collar_trim := MeshInstance3D.new()
    collar_trim.name = "CollarLight"
    collar_trim.mesh = _collar_mesh(true)
    collar_trim.material_override = trim
    add_child(collar_trim)

func _cloth_point(u: float, t: float, side: float) -> Vector3:
    var across := u * 2.0 - 1.0
    var width := 0.40 + 0.09 * t
    var pleat := sin(u * PI * 4.0) * 0.028 * sin(t * PI)
    return Vector3(
        across * width * 0.5 + side * (0.09 * t * t),
        -0.94 * t - 0.08 * t * t * (1.0 - absf(across)),
        0.035 + 0.29 * t * t + pleat + 0.045 * across * across
    )

func _vertex(tool: SurfaceTool, point: Vector3, t: float) -> void:
    # Hand-authored violet-to-magenta fabric gradient, independent of textures.
    tool.set_color(Color(0.21, 0.12, 0.48).lerp(Color(0.77, 0.22, 0.66), t * 0.75))
    tool.add_vertex(point)

func _cloth_mesh(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 14
    const COLUMNS := 8
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        for col in range(COLUMNS):
            var u0 := float(col) / float(COLUMNS)
            var u1 := float(col + 1) / float(COLUMNS)
            var a := _cloth_point(u0, t0, side)
            var b := _cloth_point(u1, t0, side)
            var c := _cloth_point(u0, t1, side)
            var d := _cloth_point(u1, t1, side)
            _vertex(tool, a, t0)
            _vertex(tool, c, t1)
            _vertex(tool, d, t1)
            _vertex(tool, a, t0)
            _vertex(tool, d, t1)
            _vertex(tool, b, t0)
    tool.generate_normals()
    return tool.commit()

func _seam_mesh(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const STEPS := 14
    for edge in [0.025, 0.935]:
        for step in range(STEPS):
            var t0 := float(step) / float(STEPS)
            var t1 := float(step + 1) / float(STEPS)
            _quad(tool,
                _cloth_point(edge, t0, side),
                _cloth_point(edge + 0.035, t0, side),
                _cloth_point(edge, t1, side),
                _cloth_point(edge + 0.035, t1, side))
    for step in range(STEPS):
        var u0 := float(step) / float(STEPS)
        var u1 := float(step + 1) / float(STEPS)
        _quad(tool,
            _cloth_point(u0, 0.95, side),
            _cloth_point(u1, 0.95, side),
            _cloth_point(u0, 0.99, side),
            _cloth_point(u1, 0.99, side))
    tool.generate_normals()
    return tool.commit()

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
    var offset := Vector3(0.0, 0.0, 0.013)
    tool.add_vertex(a + offset)
    tool.add_vertex(c + offset)
    tool.add_vertex(d + offset)
    tool.add_vertex(a + offset)
    tool.add_vertex(d + offset)
    tool.add_vertex(b + offset)

func _collar_point(u: float, top: bool) -> Vector3:
    var x := (u * 2.0 - 1.0) * 0.50
    var arc := 1.0 - pow(absf(x) / 0.50, 2.0)
    return Vector3(x, (2.36 - 0.07 * absf(x)) if top else 2.12, 0.50 + 0.14 * arc + (0.035 if top else 0.0))

func _collar_mesh(light: bool) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const STEPS := 20
    for i in range(STEPS):
        var u0 := float(i) / float(STEPS)
        var u1 := float(i + 1) / float(STEPS)
        if light:
            var a := _collar_point(u0, true)
            var b := _collar_point(u1, true)
            _quad(tool, a, b, a - Vector3(0.0, 0.032, 0.0), b - Vector3(0.0, 0.032, 0.0))
        else:
            _vertex(tool, _collar_point(u0, false), 0.0)
            _vertex(tool, _collar_point(u1, false), 0.0)
            _vertex(tool, _collar_point(u1, true), 0.35)
            _vertex(tool, _collar_point(u0, false), 0.0)
            _vertex(tool, _collar_point(u1, true), 0.35)
            _vertex(tool, _collar_point(u0, true), 0.35)
    tool.generate_normals()
    return tool.commit()
