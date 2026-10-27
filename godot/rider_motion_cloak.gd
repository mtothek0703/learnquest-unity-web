extends Node3D
## V90: an articulated six-panel flight cloak, designed to be readable from
## behind in the primary 16:9 chase camera. Each panel is a shaded curved
## surface on its own hinge, rather than a flat sprite or a single rigid cape.
## Original procedural geometry, no imported assets, collision or input changes.
const ROWS := 14
const COLUMNS := 6
const JOINTS_PER_SIDE := 3

var elapsed: float = 0.0
# V113: narrow the cloak at cruise without deleting its articulated fabric.
var cloak_width: float = 0.52
var cloak_roots: Array[Node3D] = []
var cloak_joints: Array[Node3D] = []
var edge_materials: Array[StandardMaterial3D] = []

func _ready() -> void:
    _build_cloak()
    for cloak in cloak_roots:
        cloak.scale.x = cloak_width

func _process(delta: float) -> void:
    elapsed += delta
    var rider := get_parent().get_parent() as Node3D
    var steering := float(rider.get("lean")) if rider != null else 0.0
    var turbo := bool(rider.get("boosting")) if rider != null else false
    var airborne := clampf(rider.position.y / 1.4, 0.0, 1.0) if rider != null else 0.0
    var target_width := 1.0 if turbo else (0.86 if airborne > 0.12 else 0.52)
    cloak_width = move_toward(cloak_width, target_width, delta * (2.8 if turbo or airborne > 0.12 else 2.1))
    for i in range(cloak_roots.size()):
        var side := -1.0 if i == 0 else 1.0
        var root := cloak_roots[i]
        root.scale.x = cloak_width
        # Keep the middle of the silhouette open, even in a hard turn.
        root.rotation.z = lerpf(root.rotation.z, side * (0.14 if turbo else 0.03) - steering * 0.12, minf(1.0, delta * 7.0))
        root.rotation.y = lerpf(root.rotation.y, side * (0.16 if turbo else 0.02) - steering * 0.07, minf(1.0, delta * 6.0))
        for joint_index in range(JOINTS_PER_SIDE):
            var joint := cloak_joints[i * JOINTS_PER_SIDE + joint_index]
            var delay := float(joint_index) * 0.72
            var wave := sin(elapsed * (10.0 if turbo else 4.1) - delay + float(i) * 0.6)
            var pitch := -0.09 - float(joint_index) * 0.04 - (0.22 if turbo else 0.0) - airborne * 0.20 + wave * (0.11 if turbo else 0.07)
            joint.rotation.x = lerpf(joint.rotation.x, pitch, minf(1.0, delta * (8.0 - float(joint_index))))
            joint.rotation.z = lerpf(joint.rotation.z, -steering * 0.09 + side * wave * 0.045, minf(1.0, delta * 6.0))
        edge_materials[i].emission_energy_multiplier = 1.35 + (0.85 if turbo else 0.15) * (0.75 + 0.25 * sin(elapsed * 8.0 + float(i)))

func _cloth_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.metallic = 0.16
    material.roughness = 0.42
    return material

func _trim_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.emission_enabled = true
    material.emission = Color("#61f4ff")
    material.emission_energy_multiplier = 1.35
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    return material

func _build_cloak() -> void:
    cloak_roots.clear()
    cloak_joints.clear()
    edge_materials.clear()
    var fabric := _cloth_material()
    for i in range(2):
        var side := -1.0 if i == 0 else 1.0
        var root := Node3D.new()
        root.name = "LeftCloakRoot" if i == 0 else "RightCloakRoot"
        root.position = Vector3(side * 0.54, 1.94, 0.78)
        add_child(root)
        cloak_roots.append(root)
        var luminous := _trim_material()
        edge_materials.append(luminous)
        var parent_joint: Node3D = root
        for segment in range(JOINTS_PER_SIDE):
            var joint := Node3D.new()
            joint.name = "Joint%d" % segment
            if segment > 0:
                joint.position = Vector3(side * 0.025, -0.31, 0.32)
            parent_joint.add_child(joint)
            cloak_joints.append(joint)
            var cloth := MeshInstance3D.new()
            cloth.name = "FlowingFabric"
            cloth.mesh = _panel_mesh(side, segment, 0)
            cloth.material_override = fabric
            joint.add_child(cloth)
            var outer_edge := MeshInstance3D.new()
            outer_edge.name = "LuminousOuterHem"
            outer_edge.mesh = _panel_mesh(side, segment, 1)
            outer_edge.material_override = luminous
            joint.add_child(outer_edge)
            var inner_edge := MeshInstance3D.new()
            inner_edge.name = "LuminousInnerSeam"
            inner_edge.mesh = _panel_mesh(side, segment, 2)
            inner_edge.material_override = luminous
            joint.add_child(inner_edge)
            parent_joint = joint
        var clasp := MeshInstance3D.new()
        clasp.name = "SculptedShoulderClasp"
        var sphere := SphereMesh.new()
        sphere.radius = 0.13
        sphere.height = 0.20
        sphere.radial_segments = 12
        sphere.rings = 6
        clasp.mesh = sphere
        clasp.material_override = luminous
        root.add_child(clasp)

func _point(t: float, u: float, side: float, segment: int) -> Vector3:
    var across := u * 2.0 - 1.0
    var width := (0.48 + float(segment) * 0.075) * (1.0 - 0.10 * t)
    var pleat := sin(u * PI * 3.0) * 0.045 * sin(t * PI)
    return Vector3(
        across * width * 0.5 + side * (0.04 * t),
        -0.31 * t + sin(t * PI) * 0.045,
        0.32 * t + 0.10 * sin(t * PI) + pleat + 0.035 * across * across
    )

func _vertex(tool: SurfaceTool, point: Vector3, progress: float, edge: bool, u: float) -> void:
    var tint := Color("#222a65").lerp(Color("#c04aa8"), progress)
    tint = tint.lerp(Color("#68e4e5"), 0.12 * (1.0 - absf(u * 2.0 - 1.0)))
    if edge:
        tint = Color("#b6ffff").lerp(Color("#ff8be8"), progress * 0.60)
    tool.set_color(tint)
    tool.add_vertex(point)

func _panel_mesh(side: float, segment: int, strip: int) -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    var columns := COLUMNS if strip == 0 else 1
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        for column in range(columns):
            var u0 := float(column) / float(columns)
            var u1 := float(column + 1) / float(columns)
            if strip == 1:
                u0 = 0.94
                u1 = 0.99
            elif strip == 2:
                u0 = 0.01
                u1 = 0.06
            var offset := Vector3(0.0, 0.0, 0.012 if strip != 0 else 0.0)
            var a := _point(t0, u0, side, segment) + offset
            var b := _point(t1, u0, side, segment) + offset
            var c := _point(t1, u1, side, segment) + offset
            var d := _point(t0, u1, side, segment) + offset
            var edge := strip != 0
            var p0 := (float(segment) + t0) / float(JOINTS_PER_SIDE)
            var p1 := (float(segment) + t1) / float(JOINTS_PER_SIDE)
            _vertex(surface, a, p0, edge, u0)
            _vertex(surface, b, p1, edge, u0)
            _vertex(surface, c, p1, edge, u1)
            _vertex(surface, a, p0, edge, u0)
            _vertex(surface, c, p1, edge, u1)
            _vertex(surface, d, p0, edge, u1)
    surface.generate_normals()
    return surface.commit()
