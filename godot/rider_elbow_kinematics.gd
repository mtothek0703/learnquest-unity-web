extends Node3D
## V91: true two-joint arm posing. The shoulder keeps the existing balance
## animation while the detailed forearm/hand pivots around a separate elbow.
## Original shaded geometry; purely visual, no touch, physics or collision edits.
@export var side_sign: float = 1.0

const ARMOR_ROWS := 12
const ARMOR_SIDES := 18
var elapsed: float = 0.0
var elbow_joint: Node3D
var forearm: Node3D
var luminous_trim: StandardMaterial3D

func _ready() -> void:
    forearm = get_parent().get_node_or_null("SculptedRiderGauntlet") as Node3D
    _build_elbow()

func _process(delta: float) -> void:
    if elbow_joint == null or forearm == null:
        return
    elapsed += delta
    var rider := get_parent().get_parent().get_parent() as Node3D
    if rider == null:
        return
    var steering := clampf(float(rider.get("lean")), -1.0, 1.0)
    var turbo := bool(rider.get("boosting"))
    var air := clampf(rider.position.y / 1.25, 0.0, 1.0)
    # Bend the elbow forward under acceleration and tuck the hands in a jump.
    # Opposing lateral angles make the rider visibly counter-steer.
    var bend := 0.10 + (0.47 if turbo else 0.0) + 0.61 * air + absf(steering) * 0.14
    bend += sin(elapsed * (9.0 if turbo else 3.4) + side_sign) * 0.018
    var bank := side_sign * (0.07 + 0.18 * air) - steering * 0.23
    var twist := -steering * 0.12 + side_sign * (0.10 if turbo else 0.0)
    var weight := minf(1.0, delta * 9.0)
    elbow_joint.rotation.x = lerpf(elbow_joint.rotation.x, bend, weight)
    elbow_joint.rotation.z = lerpf(elbow_joint.rotation.z, bank, weight)
    elbow_joint.rotation.y = lerpf(elbow_joint.rotation.y, twist, weight)
    # The existing sculpted gauntlet, fingers and wrist display move as a
    # single lower-arm unit; its original parent path remains unchanged.
    forearm.rotation = elbow_joint.rotation
    forearm.position = Vector3(side_sign * 0.10, -0.31, 0.0)
    if luminous_trim != null:
        luminous_trim.emission_energy_multiplier = 1.2 + (0.85 if turbo else 0.12) * (0.7 + 0.3 * sin(elapsed * 7.0))

func _armor_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.metallic = 0.38
    material.roughness = 0.33
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _trim_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("#85eaff")
    material.emission_enabled = true
    material.emission = Color("#4ccfff")
    material.emission_energy_multiplier = 1.2
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _build_elbow() -> void:
    var armor := _armor_material()
    luminous_trim = _trim_material()
    var socket := MeshInstance3D.new()
    socket.name = "ShadedElbowSocket"
    var sphere := SphereMesh.new()
    sphere.radius = 0.16
    sphere.height = 0.27
    sphere.radial_segments = 16
    sphere.rings = 8
    socket.mesh = sphere
    socket.material_override = armor
    socket.position = Vector3(side_sign * 0.10, -0.31, 0.0)
    add_child(socket)

    elbow_joint = Node3D.new()
    elbow_joint.name = "ArticulatedElbow"
    elbow_joint.position = Vector3(side_sign * 0.10, -0.31, 0.0)
    add_child(elbow_joint)
    var plate := MeshInstance3D.new()
    plate.name = "CurvedForearmArmor"
    plate.mesh = _armored_plate_mesh()
    plate.material_override = armor
    elbow_joint.add_child(plate)
    var neon := MeshInstance3D.new()
    neon.name = "LuminousElbowCuff"
    neon.mesh = _luminous_cuff_mesh()
    neon.material_override = luminous_trim
    elbow_joint.add_child(neon)

func _plate_point(t: float, u: float) -> Vector3:
    var angle := -PI * 0.70 + u * PI * 1.40
    var radius := lerpf(0.18, 0.125, t) + 0.012 * sin(t * PI)
    return Vector3(
        side_sign * 0.012 + sin(angle) * radius,
        0.06 - 0.37 * t,
        cos(angle) * radius + 0.035 * sin(t * PI)
    )

func _vertex(tool: SurfaceTool, point: Vector3, progress: float) -> void:
    tool.set_color(Color("#272b63").lerp(Color("#9871c7"), progress * 0.75))
    tool.add_vertex(point)

func _armored_plate_mesh() -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(ARMOR_ROWS):
        var t0 := float(row) / float(ARMOR_ROWS)
        var t1 := float(row + 1) / float(ARMOR_ROWS)
        for col in range(ARMOR_SIDES):
            var u0 := float(col) / float(ARMOR_SIDES)
            var u1 := float(col + 1) / float(ARMOR_SIDES)
            var a := _plate_point(t0, u0)
            var b := _plate_point(t1, u0)
            var c := _plate_point(t1, u1)
            var d := _plate_point(t0, u1)
            _vertex(surface, a, t0)
            _vertex(surface, b, t1)
            _vertex(surface, c, t1)
            _vertex(surface, a, t0)
            _vertex(surface, c, t1)
            _vertex(surface, d, t0)
    surface.generate_normals()
    return surface.commit()

func _luminous_cuff_mesh() -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SEGMENTS := 28
    for index in range(SEGMENTS):
        var u0 := float(index) / float(SEGMENTS)
        var u1 := float(index + 1) / float(SEGMENTS)
        var a := _plate_point(0.16, u0) * Vector3(1.03, 1.0, 1.03)
        var b := _plate_point(0.16, u1) * Vector3(1.03, 1.0, 1.03)
        var c := _plate_point(0.23, u1) * Vector3(1.03, 1.0, 1.03)
        var d := _plate_point(0.23, u0) * Vector3(1.03, 1.0, 1.03)
        surface.add_vertex(a)
        surface.add_vertex(b)
        surface.add_vertex(c)
        surface.add_vertex(a)
        surface.add_vertex(c)
        surface.add_vertex(d)
    surface.generate_normals()
    return surface.commit()
