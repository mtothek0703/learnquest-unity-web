extends Node3D
## Original high-top hover boots: sculpted layered upper, flexible sole,
## woven luminous laces, ankle cuff and animated edge lights.
## All meshes are generated once, with no third-party assets or GPU particles.

var clock: float = 0.0
var glow_material: StandardMaterial3D

func _ready() -> void:
    _build_boot()

func _process(delta: float) -> void:
    clock += delta
    var controller := get_parent().get_parent().get_parent() as Node3D
    var turbo := bool(controller.get("boosting")) if controller != null else false
    if glow_material != null:
        glow_material.emission_energy_multiplier = 1.5 + (0.85 if turbo else 0.15) * (0.5 + 0.5 * sin(clock * (9.0 if turbo else 3.0)))

func _fabric() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.metallic = 0.27
    material.roughness = 0.40
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _neon() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.16, 0.95, 1.0)
    material.emission_enabled = true
    material.emission = Color(0.05, 0.62, 0.95)
    material.emission_energy_multiplier = 1.6
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _build_boot() -> void:
    var fabric := _fabric()
    glow_material = _neon()
    var upper := MeshInstance3D.new()
    upper.name = "SculptedUpper"
    upper.mesh = _shoe_mesh(false)
    upper.material_override = fabric
    add_child(upper)
    var sole := MeshInstance3D.new()
    sole.name = "SculptedSole"
    sole.mesh = _shoe_mesh(true)
    sole.material_override = fabric
    add_child(sole)
    var welt := MeshInstance3D.new()
    welt.name = "NeonSoleWelt"
    welt.mesh = _welt_mesh()
    welt.material_override = glow_material
    add_child(welt)
    var laces := MeshInstance3D.new()
    laces.name = "WovenLaces"
    laces.mesh = _lace_mesh()
    laces.material_override = glow_material
    add_child(laces)
    var cuff := MeshInstance3D.new()
    cuff.name = "TailoredAnkleCuff"
    cuff.mesh = _cuff_mesh()
    cuff.material_override = fabric
    add_child(cuff)

func _shoe_point(t: float, angle: float, sole: bool) -> Vector3:
    var width := 0.155 + 0.07 * (1.0 - t) + 0.035 * sin(t * PI)
    var center_y := 0.07 + 0.05 * t
    var height := 0.09 + 0.045 * t
    if sole:
        width += 0.035
        center_y = -0.025
        height = 0.045
    return Vector3(
        cos(angle) * width,
        center_y + sin(angle) * height,
        -0.47 + 0.75 * t
    )

func _shoe_vertex(tool: SurfaceTool, point: Vector3, t: float, sole: bool) -> void:
    var front := Color(0.16, 0.11, 0.38) if not sole else Color(0.06, 0.11, 0.24)
    var back := Color(0.55, 0.23, 0.72) if not sole else Color(0.18, 0.25, 0.44)
    tool.set_color(front.lerp(back, t * 0.86))
    tool.add_vertex(point)

func _shoe_mesh(sole: bool) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const STEPS := 18
    const SIDES := 12
    for i in range(STEPS):
        var t0 := float(i) / float(STEPS)
        var t1 := float(i + 1) / float(STEPS)
        for j in range(SIDES):
            var a0 := TAU * float(j) / float(SIDES)
            var a1 := TAU * float(j + 1) / float(SIDES)
            var p00 := _shoe_point(t0, a0, sole)
            var p01 := _shoe_point(t0, a1, sole)
            var p10 := _shoe_point(t1, a0, sole)
            var p11 := _shoe_point(t1, a1, sole)
            _shoe_vertex(tool, p00, t0, sole)
            _shoe_vertex(tool, p10, t1, sole)
            _shoe_vertex(tool, p11, t1, sole)
            _shoe_vertex(tool, p00, t0, sole)
            _shoe_vertex(tool, p11, t1, sole)
            _shoe_vertex(tool, p01, t0, sole)
    tool.generate_normals()
    return tool.commit()

func _welt_point(side: float, t: float) -> Vector3:
    var width := 0.155 + 0.07 * (1.0 - t) + 0.035 * sin(t * PI)
    return Vector3(side * (width + 0.031), 0.012, -0.47 + 0.75 * t)

func _welt_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const STEPS := 18
    for side in [-1.0, 1.0]:
        for i in range(STEPS):
            var p := _welt_point(side, float(i) / float(STEPS))
            var q := _welt_point(side, float(i + 1) / float(STEPS))
            var rise := Vector3(0.0, 0.018, 0.0)
            tool.add_vertex(p - rise)
            tool.add_vertex(q - rise)
            tool.add_vertex(q + rise)
            tool.add_vertex(p - rise)
            tool.add_vertex(q + rise)
            tool.add_vertex(p + rise)
    tool.generate_normals()
    return tool.commit()

func _lace_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(6):
        var z := -0.29 + float(i) * 0.078
        var y := 0.177 + float(i) * 0.013
        var a := Vector3(-0.112, y, z + (0.035 if i % 2 == 0 else 0.0))
        var b := Vector3(0.112, y, z + (0.0 if i % 2 == 0 else 0.035))
        var across := Vector3(0.0, 0.0, 0.014)
        tool.add_vertex(a - across)
        tool.add_vertex(b - across)
        tool.add_vertex(b + across)
        tool.add_vertex(a - across)
        tool.add_vertex(b + across)
        tool.add_vertex(a + across)
    tool.generate_normals()
    return tool.commit()

func _cuff_point(angle: float, top: bool) -> Vector3:
    return Vector3(
        cos(angle) * (0.177 if top else 0.168),
        0.31 if top else 0.18,
        0.155 + sin(angle) * (0.16 if top else 0.14)
    )

func _cuff_vertex(tool: SurfaceTool, point: Vector3, top: bool) -> void:
    tool.set_color(Color(0.45, 0.19, 0.66) if top else Color(0.12, 0.11, 0.35))
    tool.add_vertex(point)

func _cuff_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SIDES := 16
    for i in range(SIDES):
        var a := TAU * float(i) / float(SIDES)
        var b := TAU * float(i + 1) / float(SIDES)
        _cuff_vertex(tool, _cuff_point(a, false), false)
        _cuff_vertex(tool, _cuff_point(a, true), true)
        _cuff_vertex(tool, _cuff_point(b, true), true)
        _cuff_vertex(tool, _cuff_point(a, false), false)
        _cuff_vertex(tool, _cuff_point(b, true), true)
        _cuff_vertex(tool, _cuff_point(b, false), false)
    tool.generate_normals()
    return tool.commit()
