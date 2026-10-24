extends Node3D
## Skyway V38: original, sculpted front-of-body flight jacket.
## Curved, vertex-shaded cloth panels, a raised collar, layered chest armor,
## a luminous zipper and waist piping. Built once; breathing and turbo only
## animate transforms/materials, preserving the existing gameplay and glTF.
var clock: float = 0.0
var breathing_pivot: Node3D
var zip_glow: StandardMaterial3D

func _ready() -> void:
    _build_jacket()

func _process(delta: float) -> void:
    clock += delta
    var rider := get_parent().get_parent() as Node3D
    var turbo := bool(rider.get("boosting")) if rider != null else false
    var lean := float(rider.get("lean")) if rider != null else 0.0
    if is_instance_valid(breathing_pivot):
        var breath := sin(clock * (5.2 if turbo else 2.0))
        breathing_pivot.scale = Vector3(1.0 + breath * 0.008, 1.0, 1.0 + breath * 0.018)
        breathing_pivot.rotation.y = lerpf(breathing_pivot.rotation.y, lean * 0.045, minf(1.0, delta * 6.0))
    if zip_glow != null:
        zip_glow.emission_energy_multiplier = 1.7 + (0.75 if turbo else 0.14) * (0.5 + 0.5 * sin(clock * (8.0 if turbo else 2.5)))

func _fabric() -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color.WHITE
    m.vertex_color_use_as_albedo = true
    m.metallic = 0.18
    m.roughness = 0.51
    m.cull_mode = BaseMaterial3D.CULL_DISABLED
    return m

func _armor() -> StandardMaterial3D:
    var m := _fabric()
    m.metallic = 0.48
    m.roughness = 0.30
    return m

func _neon() -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color(0.20, 0.96, 1.0)
    m.emission_enabled = true
    m.emission = Color(0.06, 0.58, 0.90)
    m.emission_energy_multiplier = 1.8
    m.cull_mode = BaseMaterial3D.CULL_DISABLED
    return m

func _add_mesh(name: String, parent: Node3D, mesh: ArrayMesh, mat: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = name
    node.mesh = mesh
    node.material_override = mat
    parent.add_child(node)
    return node

func _chest_point(u: float, v: float, lift: float = 0.0) -> Vector3:
    # The front faces -Z. Waist tapers inward, shoulders widen; the surface
    # swells naturally over the sternum rather than appearing box-shaped.
    var width := lerpf(0.37, 0.53, v) + 0.025 * sin(v * PI)
    var curved := (1.0 - u * u) * (0.13 + 0.035 * sin(v * PI))
    return Vector3(
        u * width,
        1.13 + v * 1.00,
        -0.49 - curved - lift
    )

func _emit(tool: SurfaceTool, point: Vector3, color: Color) -> void:
    tool.set_color(color)
    tool.add_vertex(point)

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, tint_a: Color, tint_b: Color) -> void:
    _emit(tool, a, tint_a)
    _emit(tool, c, tint_b)
    _emit(tool, d, tint_b)
    _emit(tool, a, tint_a)
    _emit(tool, d, tint_b)
    _emit(tool, b, tint_a)

func _cloth_panel(left: bool) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 20
    const COLS := 14
    var from_u := -1.0 if left else 0.038
    var to_u := -0.038 if left else 1.0
    for row in range(ROWS):
        var v0 := float(row) / float(ROWS)
        var v1 := float(row + 1) / float(ROWS)
        for column in range(COLS):
            var u0 := lerpf(from_u, to_u, float(column) / float(COLS))
            var u1 := lerpf(from_u, to_u, float(column + 1) / float(COLS))
            var a := _chest_point(u0, v0)
            var b := _chest_point(u1, v0)
            var c := _chest_point(u0, v1)
            var d := _chest_point(u1, v1)
            var lower := Color(0.10, 0.12, 0.33).lerp(Color(0.33, 0.20, 0.66), v0)
            var upper := Color(0.10, 0.12, 0.33).lerp(Color(0.33, 0.20, 0.66), v1)
            _quad(tool, a, b, c, d, lower, upper)
    tool.generate_normals()
    return tool.commit()

func _armor_plate(left: bool) -> ArrayMesh:
    # Raised curved upper-chest panels add a separate, readable material layer.
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 12
    const COLS := 12
    for row in range(ROWS):
        var v0 := lerpf(0.48, 0.92, float(row) / float(ROWS))
        var v1 := lerpf(0.48, 0.92, float(row + 1) / float(ROWS))
        for column in range(COLS):
            var q0 := float(column) / float(COLS)
            var q1 := float(column + 1) / float(COLS)
            var u0 := lerpf(-0.92, -0.15, q0) if left else lerpf(0.15, 0.92, q0)
            var u1 := lerpf(-0.92, -0.15, q1) if left else lerpf(0.15, 0.92, q1)
            var a := _chest_point(u0, v0, 0.035 + 0.025 * sin(q0 * PI))
            var b := _chest_point(u1, v0, 0.035 + 0.025 * sin(q1 * PI))
            var c := _chest_point(u0, v1, 0.035 + 0.025 * sin(q0 * PI))
            var d := _chest_point(u1, v1, 0.035 + 0.025 * sin(q1 * PI))
            var low := Color(0.15, 0.27, 0.46).lerp(Color(0.57, 0.31, 0.74), v0)
            var high := Color(0.15, 0.27, 0.46).lerp(Color(0.57, 0.31, 0.74), v1)
            _quad(tool, a, b, c, d, low, high)
    tool.generate_normals()
    return tool.commit()

func _ribbon(path: PackedVector3Array, width: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(path.size() - 1):
        var a := path[i]
        var b := path[i + 1]
        var tangent := (b - a).normalized()
        var across := Vector3(-tangent.y, tangent.x, 0.0) * width * 0.5
        tool.add_vertex(a - across)
        tool.add_vertex(b - across)
        tool.add_vertex(b + across)
        tool.add_vertex(a - across)
        tool.add_vertex(b + across)
        tool.add_vertex(a + across)
    tool.generate_normals()
    return tool.commit()

func _seam_path(kind: int) -> PackedVector3Array:
    var points := PackedVector3Array()
    for i in range(24):
        var t := float(i) / 23.0
        if kind == 0:
            points.append(_chest_point(0.0, 0.08 + t * 0.87, 0.030))
        elif kind == 1:
            points.append(_chest_point(-0.96 + t * 1.92, 0.12, 0.025))
        elif kind == 2:
            points.append(_chest_point(-0.92 + t * 0.77, 0.88 - t * 0.36, 0.065))
        else:
            points.append(_chest_point(0.15 + t * 0.77, 0.52 + t * 0.36, 0.065))
    return points

func _collar_mesh() -> ArrayMesh:
    # Tall, sculpted wraparound collar follows an ellipse behind the neck.
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SEGMENTS := 32
    const ROWS := 7
    for row in range(ROWS):
        var v0 := float(row) / float(ROWS)
        var v1 := float(row + 1) / float(ROWS)
        for i in range(SEGMENTS):
            var a0 := TAU * float(i) / float(SEGMENTS)
            var a1 := TAU * float(i + 1) / float(SEGMENTS)
            var p00 := _collar_point(a0, v0)
            var p01 := _collar_point(a1, v0)
            var p10 := _collar_point(a0, v1)
            var p11 := _collar_point(a1, v1)
            _quad(tool, p00, p01, p10, p11, Color(0.14, 0.14, 0.35), Color(0.42, 0.28, 0.67))
    tool.generate_normals()
    return tool.commit()

func _collar_point(angle: float, v: float) -> Vector3:
    var radius := 1.0 - 0.12 * v
    return Vector3(
        cos(angle) * 0.39 * radius,
        2.06 + 0.24 * v + 0.025 * cos(angle),
        sin(angle) * 0.36 * radius
    )

func _build_jacket() -> void:
    breathing_pivot = Node3D.new()
    breathing_pivot.name = "AnimatedBreathingJacket"
    add_child(breathing_pivot)
    var cloth := _fabric()
    var armor := _armor()
    zip_glow = _neon()
    _add_mesh("TailoredLeftChest", breathing_pivot, _cloth_panel(true), cloth)
    _add_mesh("TailoredRightChest", breathing_pivot, _cloth_panel(false), cloth)
    _add_mesh("LayeredLeftChestArmor", breathing_pivot, _armor_plate(true), armor)
    _add_mesh("LayeredRightChestArmor", breathing_pivot, _armor_plate(false), armor)
    _add_mesh("LuminousCenterZipper", breathing_pivot, _ribbon(_seam_path(0), 0.028), zip_glow)
    _add_mesh("LuminousWaistPiping", breathing_pivot, _ribbon(_seam_path(1), 0.032), zip_glow)
    _add_mesh("LuminousLeftChestEdge", breathing_pivot, _ribbon(_seam_path(2), 0.021), zip_glow)
    _add_mesh("LuminousRightChestEdge", breathing_pivot, _ribbon(_seam_path(3), 0.021), zip_glow)
    _add_mesh("RaisedFlightCollar", self, _collar_mesh(), armor)
