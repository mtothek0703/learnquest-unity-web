extends Node3D
## Original interlaced three-strand hair mesh, free of third-party assets.
## All geometry is created once; only the ponytail pivot moves each frame.
var clock: float = 0.0
var sway_root: Node3D
var clasp_material: StandardMaterial3D

func _ready() -> void:
    _build_braid()

func _process(delta: float) -> void:
    clock += delta
    if sway_root == null:
        return
    var rider := get_parent().get_parent() as Node3D
    var lean := float(rider.get("lean")) if rider != null else 0.0
    var turbo := bool(rider.get("boosting")) if rider != null else false
    var wind := -0.34 if turbo else -0.12
    var pace := 8.0 if turbo else 3.3
    sway_root.rotation.x = lerpf(sway_root.rotation.x, wind + sin(clock * pace) * (0.085 if turbo else 0.045), minf(1.0, delta * 5.5))
    sway_root.rotation.z = lerpf(sway_root.rotation.z, -lean * 0.25 + sin(clock * 2.7) * 0.045, minf(1.0, delta * 6.0))
    sway_root.rotation.y = lerpf(sway_root.rotation.y, -lean * 0.11, minf(1.0, delta * 4.0))
    if clasp_material != null:
        clasp_material.emission_energy_multiplier = 1.3 + (0.9 if turbo else 0.15) * (0.5 + 0.5 * sin(clock * pace))

func _build_braid() -> void:
    sway_root = Node3D.new()
    sway_root.name = "WindSwayPivot"
    sway_root.position = Vector3(0.0, 2.82, 0.54)
    add_child(sway_root)
    var hair := StandardMaterial3D.new()
    hair.albedo_color = Color.WHITE
    hair.vertex_color_use_as_albedo = true
    hair.roughness = 0.47
    hair.metallic = 0.12
    for strand in range(3):
        var mesh := MeshInstance3D.new()
        mesh.name = "BraidedStrand%d" % strand
        mesh.mesh = _braid_mesh(strand)
        mesh.material_override = hair
        sway_root.add_child(mesh)
    clasp_material = StandardMaterial3D.new()
    clasp_material.albedo_color = Color(0.25, 0.94, 1.0)
    clasp_material.metallic = 0.48
    clasp_material.roughness = 0.24
    clasp_material.emission_enabled = true
    clasp_material.emission = Color(0.07, 0.56, 0.83)
    clasp_material.emission_energy_multiplier = 1.5
    for i in range(2):
        var t := 0.06 if i == 0 else 0.87
        var clasp := MeshInstance3D.new()
        clasp.name = "RootClasp" if i == 0 else "TipClasp"
        var ring := TorusMesh.new()
        ring.inner_radius = 0.065 if i == 0 else 0.030
        ring.outer_radius = 0.125 if i == 0 else 0.073
        ring.rings = 12
        ring.ring_segments = 20
        clasp.mesh = ring
        clasp.material_override = clasp_material
        clasp.position = _spine(t)
        clasp.rotation.x = 0.30
        sway_root.add_child(clasp)

func _spine(t: float) -> Vector3:
    return Vector3(0.025 * sin(t * PI), -0.84 * t, 0.08 + 0.43 * t * t + 0.045 * sin(t * PI))

func _center(t: float, strand: int) -> Vector3:
    var phase := TAU * (3.5 * t + float(strand) / 3.0)
    var spread := 0.087 * (1.0 - 0.54 * t)
    return _spine(t) + Vector3(cos(phase) * spread, 0.0, sin(phase) * spread)

func _point(t: float, angle: float, strand: int) -> Vector3:
    var prev := _center(maxf(0.0, t - 0.002), strand)
    var next := _center(minf(1.0, t + 0.002), strand)
    var tangent := (next - prev).normalized()
    var across := tangent.cross(Vector3.FORWARD).normalized()
    var normal := tangent.cross(across).normalized()
    var radius := 0.066 * pow(1.0 - t, 0.72) + 0.007
    return _center(t, strand) + (across * cos(angle) + normal * sin(angle)) * radius

func _vertex(tool: SurfaceTool, t: float, angle: float, strand: int) -> void:
    var roots := [Color(0.10, 0.065, 0.24), Color(0.24, 0.11, 0.40), Color(0.43, 0.17, 0.54)]
    var tips := [Color(0.35, 0.14, 0.50), Color(0.65, 0.28, 0.72), Color(0.81, 0.39, 0.74)]
    var sheen := 0.82 + 0.18 * cos(angle)
    tool.set_color(roots[strand].lerp(tips[strand], t * 0.75) * sheen)
    tool.add_vertex(_point(t, angle, strand))

func _braid_mesh(strand: int) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SECTIONS := 28
    const SIDES := 10
    for section in range(SECTIONS):
        var t0 := float(section) / float(SECTIONS)
        var t1 := float(section + 1) / float(SECTIONS)
        for side in range(SIDES):
            var a0 := TAU * float(side) / float(SIDES)
            var a1 := TAU * float(side + 1) / float(SIDES)
            _vertex(tool, t0, a0, strand)
            _vertex(tool, t1, a0, strand)
            _vertex(tool, t1, a1, strand)
            _vertex(tool, t0, a0, strand)
            _vertex(tool, t1, a1, strand)
            _vertex(tool, t0, a1, strand)
    tool.generate_normals()
    return tool.commit()
