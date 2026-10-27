extends Node3D
## V122: original 3D orbital drydocks for Star Harbor, no external assets.
## Eight extruded U-shaped ship cradles, animated gantries and cargo pods.
## Reused shaded meshes; all scenery remains outside the three racing lanes.

const DOCK_COUNT := 8
const DOCK_SPACING := 24.0
const LOOP_LENGTH := DOCK_COUNT * DOCK_SPACING

var running := false
var travel_speed := 14.0
var elapsed := 0.0
var docks: Array[Node3D] = []
var cradles: Array[MeshInstance3D] = []
var gantries: Array[Node3D] = []
var cargo_pods: Array[MeshInstance3D] = []

func _material(color: Color, emissive: bool = false) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.vertex_color_use_as_albedo = not emissive
    mat.metallic = 0.38
    mat.roughness = 0.42
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    if emissive:
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.emission_enabled = true
        mat.emission = color
        mat.emission_energy_multiplier = 1.8
    return mat

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(a)
    tool.add_vertex(b)
    tool.add_vertex(c)
    tool.add_vertex(a)
    tool.add_vertex(c)
    tool.add_vertex(d)

func _cradle_point(angle: float, radius: float, depth: float) -> Vector3:
    return Vector3(cos(angle) * radius, sin(angle) * radius, depth)

func _cradle_mesh() -> ArrayMesh:
    # A true hollow 3D U cradle with front/back, inner/outer curved faces.
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(32):
        var a0 := PI + PI * float(step) / 32.0
        var a1 := PI + PI * float(step + 1) / 32.0
        var tint := Color("#31577c").lerp(Color("#8ab6c9"), float(step) / 32.0)
        var p0 := _cradle_point(a0, 3.35, -2.9)
        var p1 := _cradle_point(a1, 3.35, -2.9)
        var q0 := _cradle_point(a0, 3.85, -2.9)
        var q1 := _cradle_point(a1, 3.85, -2.9)
        var p0b := _cradle_point(a0, 3.35, 2.9)
        var p1b := _cradle_point(a1, 3.35, 2.9)
        var q0b := _cradle_point(a0, 3.85, 2.9)
        var q1b := _cradle_point(a1, 3.85, 2.9)
        _quad(tool, p0, q0, q1, p1, tint.lightened(0.12))
        _quad(tool, p1b, q1b, q0b, p0b, tint.darkened(0.15))
        _quad(tool, q0, q0b, q1b, q1, tint)
        _quad(tool, p1, p1b, p0b, p0, tint.darkened(0.32))
    tool.generate_normals()
    return tool.commit()

func _gantry_point(t: float, angle: float) -> Vector3:
    var radius := 0.30 + 0.05 * sin(PI * t)
    return Vector3(-3.3 + 6.6 * t,
        0.45 + 0.36 * sin(PI * t) + cos(angle) * radius,
        -2.6 + sin(angle) * radius)

func _gantry_mesh() -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(20):
        var t0 := float(step) / 20.0
        var t1 := float(step + 1) / 20.0
        for radial in range(10):
            var a0 := TAU * float(radial) / 10.0
            var a1 := TAU * float(radial + 1) / 10.0
            _quad(tool, _gantry_point(t0, a0), _gantry_point(t1, a0),
                _gantry_point(t1, a1), _gantry_point(t0, a1),
                Color("#78c9e4") if radial % 3 == 0 else Color("#41678e"))
    tool.generate_normals()
    return tool.commit()

func _mesh(parent: Node3D, title: String, geometry: Mesh, position: Vector3, material: Material) -> MeshInstance3D:
    var mesh := MeshInstance3D.new()
    mesh.name = title
    mesh.mesh = geometry
    mesh.position = position
    mesh.material_override = material
    parent.add_child(mesh)
    return mesh

func _ready() -> void:
    var cradle_mesh := _cradle_mesh()
    var gantry_mesh := _gantry_mesh()
    var metal := _material(Color.WHITE)
    var gantry_metal := _material(Color.WHITE)
    var cyan := _material(Color("#61eaff"), true)
    var magenta := _material(Color("#f68ce6"), true)
    var pod_mesh := SphereMesh.new()
    pod_mesh.radial_segments = 20
    pod_mesh.rings = 10
    var rim_mesh := TorusMesh.new()
    rim_mesh.inner_radius = 1.12
    rim_mesh.outer_radius = 1.25
    rim_mesh.rings = 32
    rim_mesh.ring_segments = 8
    for index in range(DOCK_COUNT):
        var side := -1.0 if index % 2 == 0 else 1.0
        var dock := Node3D.new()
        dock.name = "Volumetric orbital drydock %02d" % index
        dock.position = Vector3(side * (16.5 + float(index % 3) * 1.6), 5.0, -24.0 - float(index) * DOCK_SPACING)
        add_child(dock)
        docks.append(dock)
        cradles.append(_mesh(dock, "Sculpted 360-degree ship cradle", cradle_mesh, Vector3.ZERO, metal))
        var gantry := Node3D.new()
        gantry.name = "Animated overhead loading gantry"
        gantry.position.y = 4.9
        dock.add_child(gantry)
        gantries.append(gantry)
        _mesh(gantry, "Curved structural gantry", gantry_mesh, Vector3.ZERO, gantry_metal)
        var light := cyan if index % 2 == 0 else magenta
        for pod_index in range(2):
            var x := -1.55 if pod_index == 0 else 1.55
            var pod := _mesh(dock, "Suspended cargo capsule", pod_mesh,
                Vector3(x, 1.45 + float(pod_index) * 0.5, -0.6), metal)
            pod.scale = Vector3(0.95, 0.74, 1.65)
            cargo_pods.append(pod)
            var rim := _mesh(dock, "Cargo lock status ring", rim_mesh,
                Vector3(x, 1.45 + float(pod_index) * 0.5, -0.6), light)
            rim.rotation.x = PI * 0.5
            rim.scale = Vector3(0.70, 0.70, 0.70)

func _process(delta: float) -> void:
    if not running:
        return
    elapsed += delta
    for index in range(docks.size()):
        var dock := docks[index]
        dock.position.z += travel_speed * delta
        if dock.position.z > 22.0:
            dock.position.z -= LOOP_LENGTH
        gantries[index].rotation.y = sin(elapsed * 0.75 + float(index)) * 0.13
    for index in range(cargo_pods.size()):
        cargo_pods[index].position.y = 1.45 + float(index % 2) * 0.5 + sin(elapsed * 1.15 + float(index)) * 0.22
