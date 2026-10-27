extends Node3D
## V116: continuous sculpted hoverboard chassis, top traction deck and curved
## edge-light rails. Procedural, no third-party assets or collision changes.
## The existing board node still owns all bob/roll/boost and jet animations.
const LENGTH_STEPS := 28
const RING_STEPS := 20
var built: bool = false
var chassis: MeshInstance3D
var grip: MeshInstance3D
var keel: MeshInstance3D
var rails: Array[MeshInstance3D] = []
var rail_material: StandardMaterial3D

func _ready() -> void:
    var shell_material := StandardMaterial3D.new()
    shell_material.albedo_color = Color.WHITE
    shell_material.vertex_color_use_as_albedo = true
    shell_material.metallic = 0.63
    shell_material.roughness = 0.31
    shell_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    var grip_material := StandardMaterial3D.new()
    grip_material.albedo_color = Color.WHITE
    grip_material.vertex_color_use_as_albedo = true
    grip_material.metallic = 0.22
    grip_material.roughness = 0.75
    grip_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    rail_material = StandardMaterial3D.new()
    rail_material.albedo_color = Color("#42cce8")
    rail_material.emission_enabled = true
    rail_material.emission = Color("#1dbcf5")
    rail_material.emission_energy_multiplier = 1.25
    rail_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    rail_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    chassis = _attach("ContinuousAerodynamicChassis", _make_shell(), shell_material)
    grip = _attach("ContouredTractionDeck", _make_grip(), grip_material)
    keel = _attach("UndersideKeel", _make_keel(), shell_material)
    for side in [-1.0, 1.0]:
        var rail := _attach("PortEdgeLight" if side < 0.0 else "StarboardEdgeLight",
            _make_rail(side), rail_material)
        rails.append(rail)
    built = chassis != null and grip != null and keel != null and rails.size() == 2
    if built:
        for part in [chassis, grip, keel] + rails:
            if part.mesh == null or part.mesh.get_surface_count() == 0:
                built = false

func _process(_delta: float) -> void:
    if not built:
        return
    var controller := get_parent().get_parent() as Node3D
    if controller == null:
        return
    var boost := bool(controller.get("boosting"))
    rail_material.emission_energy_multiplier = lerpf(
        rail_material.emission_energy_multiplier, 3.0 if boost else 1.25, 0.18)

func _attach(part_name: String, mesh: ArrayMesh, material: Material) -> MeshInstance3D:
    if mesh == null or mesh.get_surface_count() == 0:
        return null
    var part := MeshInstance3D.new()
    part.name = part_name
    part.mesh = mesh
    part.material_override = material
    add_child(part)
    return part

func _half_width(t: float) -> float:
    # Narrow arrowhead at the front, broad stable mid-deck, trimmed rear.
    var nose := smoothstep(0.0, 0.28, t)
    var tail := smoothstep(0.78, 1.0, t)
    return 0.77 * (0.48 + 0.52 * nose) * (1.0 - 0.16 * tail)

func _shell_point(t: float, angle: float) -> Vector3:
    var z := lerpf(-1.37, 1.33, t)
    var width := _half_width(t)
    var raised_nose := 0.07 * (1.0 - smoothstep(0.0, 0.30, t))
    var rear_sweep := 0.025 * smoothstep(0.76, 1.0, t)
    var thickness := 0.105 + 0.025 * sin(PI * t)
    return Vector3(width * cos(angle),
        0.285 + raised_nose + rear_sweep + thickness * sin(angle), z)

func _emit_shell(tool: SurfaceTool, t: float, angle: float) -> void:
    var edge := absf(cos(angle))
    var upper := maxf(0.0, sin(angle))
    var color := Color("#101a34").lerp(Color("#44587d"), upper * 0.65)
    color = color.lerp(Color("#754b9b"), edge * (0.14 + 0.20 * t))
    tool.set_color(color)
    tool.add_vertex(_shell_point(t, angle))

func _make_shell() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(LENGTH_STEPS):
        var a := float(i) / float(LENGTH_STEPS)
        var b := float(i + 1) / float(LENGTH_STEPS)
        for j in range(RING_STEPS):
            var u := TAU * float(j) / float(RING_STEPS)
            var v := TAU * float(j + 1) / float(RING_STEPS)
            _emit_shell(tool, a, u)
            _emit_shell(tool, b, u)
            _emit_shell(tool, b, v)
            _emit_shell(tool, a, u)
            _emit_shell(tool, b, v)
            _emit_shell(tool, a, v)
    # Close both ends: the replacement is a genuine 360-degree volume.
    for end in [0.0, 1.0]:
        for j in range(RING_STEPS):
            var u := TAU * float(j) / float(RING_STEPS)
            var v := TAU * float(j + 1) / float(RING_STEPS)
            tool.set_color(Color("#101a34"))
            tool.add_vertex(Vector3(0.0, _shell_point(end, 0.0).y, lerpf(-1.37, 1.33, end)))
            _emit_shell(tool, end, v if end == 0.0 else u)
            _emit_shell(tool, end, u if end == 0.0 else v)
    tool.generate_normals()
    return tool.commit()

func _grip_point(t: float, across: float) -> Vector3:
    var z := lerpf(-0.96, 0.95, t)
    var deck_t := (z + 1.37) / 2.70
    var width := _half_width(deck_t) * 0.65
    return Vector3(across * width,
        0.415 + 0.022 * (1.0 - across * across) + 0.012 * cos(PI * t), z)

func _emit_grip(tool: SurfaceTool, t: float, across: float) -> void:
    var stripe := pow(maxf(0.0, 1.0 - absf(across)), 3.0)
    tool.set_color(Color("#1b2944").lerp(Color("#45617b"), 0.25 + 0.35 * stripe))
    tool.add_vertex(_grip_point(t, across))

func _make_grip() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(24):
        var a := float(i) / 24.0
        var b := float(i + 1) / 24.0
        for j in range(8):
            var u := -1.0 + float(j) / 4.0
            var v := -1.0 + float(j + 1) / 4.0
            _emit_grip(tool, a, u)
            _emit_grip(tool, b, v)
            _emit_grip(tool, b, u)
            _emit_grip(tool, a, u)
            _emit_grip(tool, a, v)
            _emit_grip(tool, b, v)
    tool.generate_normals()
    return tool.commit()

func _keel_point(t: float, across: float) -> Vector3:
    var z := lerpf(-1.18, 1.13, t)
    var bow := 1.0 - smoothstep(0.0, 0.25, t)
    return Vector3(across * (0.15 + 0.06 * sin(PI * t)),
        0.13 - 0.09 * (1.0 - absf(across)) + 0.035 * bow, z)

func _make_keel() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(24):
        var a := float(i) / 24.0
        var b := float(i + 1) / 24.0
        for j in range(6):
            var u := -1.0 + float(j) / 3.0
            var v := -1.0 + float(j + 1) / 3.0
            for point in [_keel_point(a, u), _keel_point(b, u), _keel_point(b, v),
                _keel_point(a, u), _keel_point(b, v), _keel_point(a, v)]:
                tool.set_color(Color("#18264a").lerp(Color("#5775a0"), 0.3 + 0.3 * absf(u)))
                tool.add_vertex(point)
    tool.generate_normals()
    return tool.commit()

func _rail_point(side: float, t: float, offset: float) -> Vector3:
    var width := _half_width(t)
    return Vector3(side * (width * 0.97 + offset),
        _shell_point(t, PI * 0.24).y + 0.004, lerpf(-1.30, 1.27, t))

func _make_rail(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(28):
        var a := float(i) / 28.0
        var b := float(i + 1) / 28.0
        for point in [_rail_point(side, a, -0.016), _rail_point(side, b, -0.016),
            _rail_point(side, b, 0.016), _rail_point(side, a, -0.016),
            _rail_point(side, b, 0.016), _rail_point(side, a, 0.016)]:
            tool.add_vertex(point)
    tool.generate_normals()
    return tool.commit()
