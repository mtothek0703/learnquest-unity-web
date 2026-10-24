extends Node3D
## Skyway V37: original mesh-sculpted gauntlets, segmented gloves and a
## luminous curved wrist display. No third-party assets or mesh rebuilding
## during animation; both hands follow the existing steering arm pivots.
@export var side_sign: float = 1.0
var clock: float = 0.0
var finger_pivots: Array[Node3D] = []
var display_pivot: Node3D
var display_glow: StandardMaterial3D

func _ready() -> void:
    _build_gauntlet()

func _process(delta: float) -> void:
    clock += delta
    var rider := get_parent().get_parent().get_parent() as Node3D
    var lean := float(rider.get("lean")) if rider != null else 0.0
    var turbo := bool(rider.get("boosting")) if rider != null else false
    var target := (0.22 if turbo else 0.035) + absf(lean) * 0.09
    for i in range(finger_pivots.size()):
        var finger := finger_pivots[i]
        finger.rotation.x = lerpf(finger.rotation.x, target + float(i) * 0.015, minf(1.0, delta * 9.0))
    if is_instance_valid(display_pivot):
        display_pivot.rotation.z = lerpf(display_pivot.rotation.z, -lean * 0.13 * side_sign, minf(1.0, delta * 7.0))
        display_pivot.scale = Vector3.ONE * (1.0 + (0.11 if turbo else 0.035) * (0.5 + 0.5 * sin(clock * (9.0 if turbo else 3.0))))
    if display_glow != null:
        display_glow.emission_energy_multiplier = 1.55 + (0.95 if turbo else 0.18) * (0.5 + 0.5 * sin(clock * (9.0 if turbo else 3.0)))

func _fabric() -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color.WHITE
    m.vertex_color_use_as_albedo = true
    m.metallic = 0.38
    m.roughness = 0.36
    m.cull_mode = BaseMaterial3D.CULL_DISABLED
    return m

func _neon() -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color(0.16, 0.94, 1.0)
    m.emission_enabled = true
    m.emission = Color(0.05, 0.60, 0.92)
    m.emission_energy_multiplier = 1.6
    m.cull_mode = BaseMaterial3D.CULL_DISABLED
    return m

func _build_gauntlet() -> void:
    var fabric := _fabric()
    display_glow = _neon()
    var cuff := MeshInstance3D.new()
    cuff.name = "SculptedForearmShell"
    cuff.mesh = _forearm_mesh()
    cuff.material_override = fabric
    add_child(cuff)
    var seams := MeshInstance3D.new()
    seams.name = "LuminousGauntletSeams"
    seams.mesh = _seam_mesh()
    seams.material_override = display_glow
    add_child(seams)
    var knuckle := MeshInstance3D.new()
    knuckle.name = "LayeredKnuckleGuard"
    knuckle.mesh = _knuckle_mesh()
    knuckle.material_override = fabric
    add_child(knuckle)
    for i in range(4):
        var pivot := Node3D.new()
        pivot.name = "ArticulatedFinger%d" % i
        pivot.position = Vector3((float(i) - 1.5) * 0.082, -0.255, 0.015)
        add_child(pivot)
        var finger := MeshInstance3D.new()
        finger.name = "TaperedFingerMesh"
        finger.mesh = _finger_mesh(0.16 + 0.02 * (1.0 - absf(float(i) - 1.5)), 0.038)
        finger.material_override = fabric
        pivot.add_child(finger)
        finger_pivots.append(pivot)
    var thumb := MeshInstance3D.new()
    thumb.name = "SculptedThumb"
    thumb.mesh = _finger_mesh(0.13, 0.051)
    thumb.material_override = fabric
    thumb.position = Vector3(side_sign * 0.20, -0.19, -0.018)
    thumb.rotation.z = -side_sign * 0.85
    add_child(thumb)
    display_pivot = Node3D.new()
    display_pivot.name = "AnimatedWristDisplay"
    display_pivot.position = Vector3(0.0, -0.07, 0.155)
    add_child(display_pivot)
    var display := MeshInstance3D.new()
    display.name = "CurvedHolographicDisplay"
    display.mesh = _display_mesh()
    display.material_override = display_glow
    display_pivot.add_child(display)

func _forearm_point(t: float, a: float) -> Vector3:
    var radius := lerpf(0.162, 0.125, t) + 0.012 * sin(t * PI)
    return Vector3(
        cos(a) * radius,
        0.13 - 0.39 * t,
        sin(a) * radius * 0.88 + 0.025 * sin(t * PI)
    )

func _color_vertex(tool: SurfaceTool, p: Vector3, t: float) -> void:
    tool.set_color(Color(0.11, 0.12, 0.30).lerp(Color(0.54, 0.25, 0.72), t * 0.68))
    tool.add_vertex(p)

func _forearm_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 14
    const SIDES := 16
    for i in range(ROWS):
        var t0 := float(i) / float(ROWS)
        var t1 := float(i + 1) / float(ROWS)
        for j in range(SIDES):
            var a0 := TAU * float(j) / float(SIDES)
            var a1 := TAU * float(j + 1) / float(SIDES)
            var p00 := _forearm_point(t0, a0)
            var p01 := _forearm_point(t0, a1)
            var p10 := _forearm_point(t1, a0)
            var p11 := _forearm_point(t1, a1)
            _color_vertex(tool, p00, t0)
            _color_vertex(tool, p10, t1)
            _color_vertex(tool, p11, t1)
            _color_vertex(tool, p00, t0)
            _color_vertex(tool, p11, t1)
            _color_vertex(tool, p01, t0)
    tool.generate_normals()
    return tool.commit()

func _seam_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SEGMENTS := 18
    for angle in [0.46, 2.68]:
        for i in range(SEGMENTS):
            var t0 := float(i) / float(SEGMENTS)
            var t1 := float(i + 1) / float(SEGMENTS)
            var a := _forearm_point(t0, angle) * Vector3(1.04, 1.0, 1.04)
            var b := _forearm_point(t1, angle) * Vector3(1.04, 1.0, 1.04)
            var width := Vector3(0.012, 0.0, 0.014)
            tool.add_vertex(a - width)
            tool.add_vertex(b - width)
            tool.add_vertex(b + width)
            tool.add_vertex(a - width)
            tool.add_vertex(b + width)
            tool.add_vertex(a + width)
    tool.generate_normals()
    return tool.commit()

func _knuckle_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 8
    const COLUMNS := 12
    for i in range(ROWS):
        var t0 := float(i) / float(ROWS)
        var t1 := float(i + 1) / float(ROWS)
        for j in range(COLUMNS):
            var u0 := float(j) / float(COLUMNS)
            var u1 := float(j + 1) / float(COLUMNS)
            var p00 := _knuckle_point(t0, u0)
            var p01 := _knuckle_point(t0, u1)
            var p10 := _knuckle_point(t1, u0)
            var p11 := _knuckle_point(t1, u1)
            _color_vertex(tool, p00, t0)
            _color_vertex(tool, p10, t1)
            _color_vertex(tool, p11, t1)
            _color_vertex(tool, p00, t0)
            _color_vertex(tool, p11, t1)
            _color_vertex(tool, p01, t0)
    tool.generate_normals()
    return tool.commit()

func _knuckle_point(t: float, u: float) -> Vector3:
    var x := (u * 2.0 - 1.0) * 0.19
    return Vector3(x, -0.20 - t * 0.09, 0.07 + 0.10 * sqrt(maxf(0.0, 1.0 - x * x / 0.04)) + 0.02 * sin(u * TAU * 2.0))

func _finger_mesh(length: float, radius: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 10
    const SIDES := 10
    for i in range(ROWS):
        var t0 := float(i) / float(ROWS)
        var t1 := float(i + 1) / float(ROWS)
        for j in range(SIDES):
            var a0 := TAU * float(j) / float(SIDES)
            var a1 := TAU * float(j + 1) / float(SIDES)
            var p00 := _finger_point(t0, a0, length, radius)
            var p01 := _finger_point(t0, a1, length, radius)
            var p10 := _finger_point(t1, a0, length, radius)
            var p11 := _finger_point(t1, a1, length, radius)
            _color_vertex(tool, p00, t0)
            _color_vertex(tool, p10, t1)
            _color_vertex(tool, p11, t1)
            _color_vertex(tool, p00, t0)
            _color_vertex(tool, p11, t1)
            _color_vertex(tool, p01, t0)
    tool.generate_normals()
    return tool.commit()

func _finger_point(t: float, a: float, length: float, radius: float) -> Vector3:
    var r := radius * (1.0 - 0.50 * t)
    return Vector3(cos(a) * r, -length * t, sin(a) * r + 0.035 * sin(t * PI))

func _display_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 8
    const COLUMNS := 16
    for i in range(ROWS):
        var v0 := float(i) / float(ROWS)
        var v1 := float(i + 1) / float(ROWS)
        for j in range(COLUMNS):
            var u0 := float(j) / float(COLUMNS)
            var u1 := float(j + 1) / float(COLUMNS)
            var p00 := _display_point(u0, v0)
            var p01 := _display_point(u1, v0)
            var p10 := _display_point(u0, v1)
            var p11 := _display_point(u1, v1)
            tool.add_vertex(p00)
            tool.add_vertex(p10)
            tool.add_vertex(p11)
            tool.add_vertex(p00)
            tool.add_vertex(p11)
            tool.add_vertex(p01)
    tool.generate_normals()
    return tool.commit()

func _display_point(u: float, v: float) -> Vector3:
    var x := (u * 2.0 - 1.0) * 0.155
    var y := (v * 2.0 - 1.0) * 0.085
    var curved := 0.035 * (1.0 - (x / 0.155) * (x / 0.155))
    var scan := 0.012 * sin(u * TAU * 3.0)
    return Vector3(x, y, curved + scan)
