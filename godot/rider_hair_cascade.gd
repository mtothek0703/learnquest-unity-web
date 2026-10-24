extends Node3D
## Skyway V39: original, articulated four-lock hair cascade around the braid.
## Each lock has two tapered 3D segments with gradient vertex colors and a
## separate luminous filament. All meshes are built once for mobile WebGL.
var clock: float = 0.0
var strand_roots: Array[Node3D] = []
var strand_tips: Array[Node3D] = []
var filament_material: StandardMaterial3D

func _ready() -> void:
    _build_cascade()

func _process(delta: float) -> void:
    clock += delta
    var rider := get_parent().get_parent() as Node3D
    var lean := float(rider.get("lean")) if rider != null else 0.0
    var turbo := bool(rider.get("boosting")) if rider != null else false
    var pace := 9.0 if turbo else 3.8
    var wind := -0.35 if turbo else -0.11
    var smoothing := minf(1.0, delta * 7.0)
    for i in range(strand_roots.size()):
        var side := -1.0 if i < 2 else 1.0
        var phase := float(i) * 0.65
        var root := strand_roots[i]
        var tip := strand_tips[i]
        root.rotation.x = lerpf(root.rotation.x, wind + sin(clock * pace + phase) * (0.09 if turbo else 0.04), smoothing)
        root.rotation.z = lerpf(root.rotation.z, -lean * 0.20 + side * sin(clock * 2.6 + phase) * 0.035, smoothing)
        tip.rotation.x = lerpf(tip.rotation.x, wind * 0.55 + sin(clock * pace - 0.7 + phase) * (0.16 if turbo else 0.07), smoothing * 0.75)
        tip.rotation.z = lerpf(tip.rotation.z, -lean * 0.28 + side * sin(clock * 3.0 + phase) * 0.07, smoothing * 0.75)
    if filament_material != null:
        filament_material.emission_energy_multiplier = 1.15 + (0.85 if turbo else 0.12) * (0.5 + 0.5 * sin(clock * pace))

func _fabric() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.metallic = 0.12
    material.roughness = 0.44
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _glow() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.65, 0.40, 0.95)
    material.emission_enabled = true
    material.emission = Color(0.29, 0.13, 0.70)
    material.emission_energy_multiplier = 1.35
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _center(t: float, segment: int, side: float) -> Vector3:
    var length := 0.48 if segment == 0 else 0.56
    return Vector3(
        side * (0.055 * t + 0.028 * sin(t * PI)),
        -length * t,
        (0.20 if segment == 0 else 0.16) * t + 0.035 * sin(t * PI)
    )

func _radius(t: float, segment: int) -> float:
    if segment == 0:
        return 0.092 * (1.0 - 0.22 * t)
    return 0.075 * pow(1.0 - t, 0.7) + 0.004

func _hair_point(t: float, angle: float, segment: int, side: float) -> Vector3:
    var center := _center(t, segment, side)
    var radius := _radius(t, segment)
    return center + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius * 0.76)

func _emit_hair(tool: SurfaceTool, t: float, angle: float, segment: int, side: float, index: int) -> void:
    var root_color := Color(0.12, 0.075, 0.29).lerp(Color(0.30, 0.13, 0.44), float(index) / 3.0)
    var tip_color := Color(0.65, 0.24, 0.71).lerp(Color(0.85, 0.40, 0.73), float(index) / 3.0)
    var progression := (float(segment) + t) * 0.5
    var sheen := 0.82 + 0.18 * sin(angle)
    tool.set_color(root_color.lerp(tip_color, progression) * sheen)
    tool.add_vertex(_hair_point(t, angle, segment, side))

func _hair_mesh(segment: int, side: float, index: int) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 20
    const SIDES := 10
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        for step in range(SIDES):
            var a0 := TAU * float(step) / float(SIDES)
            var a1 := TAU * float(step + 1) / float(SIDES)
            _emit_hair(tool, t0, a0, segment, side, index)
            _emit_hair(tool, t1, a0, segment, side, index)
            _emit_hair(tool, t1, a1, segment, side, index)
            _emit_hair(tool, t0, a0, segment, side, index)
            _emit_hair(tool, t1, a1, segment, side, index)
            _emit_hair(tool, t0, a1, segment, side, index)
    tool.generate_normals()
    return tool.commit()

func _filament_mesh(segment: int, side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 24
    for row in range(ROWS):
        var t0 := 0.10 + 0.80 * float(row) / float(ROWS)
        var t1 := 0.10 + 0.80 * float(row + 1) / float(ROWS)
        var p0 := _center(t0, segment, side) + Vector3(0.0, 0.0, _radius(t0, segment) * 0.79 + 0.006)
        var p1 := _center(t1, segment, side) + Vector3(0.0, 0.0, _radius(t1, segment) * 0.79 + 0.006)
        var w0 := 0.009 * sin(PI * float(row) / float(ROWS))
        var w1 := 0.009 * sin(PI * float(row + 1) / float(ROWS))
        tool.add_vertex(p0 + Vector3(-w0, 0.0, 0.0))
        tool.add_vertex(p1 + Vector3(-w1, 0.0, 0.0))
        tool.add_vertex(p1 + Vector3(w1, 0.0, 0.0))
        tool.add_vertex(p0 + Vector3(-w0, 0.0, 0.0))
        tool.add_vertex(p1 + Vector3(w1, 0.0, 0.0))
        tool.add_vertex(p0 + Vector3(w0, 0.0, 0.0))
    tool.generate_normals()
    return tool.commit()

func _attach_segment(pivot: Node3D, segment: int, side: float, index: int, fabric: Material) -> void:
    var lock := MeshInstance3D.new()
    lock.name = "SculptedHairSegment%d" % segment
    lock.mesh = _hair_mesh(segment, side, index)
    lock.material_override = fabric
    pivot.add_child(lock)
    var filament := MeshInstance3D.new()
    filament.name = "LuminousHairFilament%d" % segment
    filament.mesh = _filament_mesh(segment, side)
    filament.material_override = filament_material
    pivot.add_child(filament)

func _build_cascade() -> void:
    var fabric := _fabric()
    filament_material = _glow()
    for i in range(4):
        var side := -1.0 if i < 2 else 1.0
        var spread := 0.22 if i == 1 or i == 2 else 0.39
        var root := Node3D.new()
        root.name = "WindCascadeRoot%d" % i
        root.position = Vector3(side * spread, 2.83, 0.60)
        add_child(root)
        _attach_segment(root, 0, side, i, fabric)
        var tip := Node3D.new()
        tip.name = "WindCascadeTip%d" % i
        tip.position = _center(1.0, 0, side)
        root.add_child(tip)
        _attach_segment(tip, 1, side, i, fabric)
        strand_roots.append(root)
        strand_tips.append(tip)
