extends Node3D
## V144 candidate: four sculpted orbital cargo cranes frame Star Harbor.
## Original shared meshes, no collision bodies, new lights, or external assets.
## Chase-camera QA moved the structures closer and enlarged their silhouette:
## the first version changed only 52 sampled pixels at 1170x540.
const CRANE_COUNT := 4
const CRANE_SPACING := 32.0
const LOOP_LENGTH := CRANE_COUNT * CRANE_SPACING
var running := false
var travel_speed := 14.0
var elapsed := 0.0
var cranes: Array[Node3D] = []
var supports: Array[MeshInstance3D] = []
var transfer_rings: Array[MeshInstance3D] = []
var freight_pods: Array[MeshInstance3D] = []

func _support_point(side: float, t: float, angle: float) -> Vector3:
    # An actual bent, tapered 360-degree tube, not a flat billboard or box stack.
    var radius := 0.61 - 0.19 * t
    return Vector3(-side * (4.65 * t * t) + radius * cos(angle),
        0.4 + 10.8 * t,
        0.34 * sin(PI * t) + radius * sin(angle))

func _support_mesh(side: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(22):
        var t0 := float(step) / 22.0
        var t1 := float(step + 1) / 22.0
        for radial in range(14):
            var a0 := TAU * float(radial) / 14.0
            var a1 := TAU * float(radial + 1) / 14.0
            var tint := Color("#1e4568").lerp(Color("#b3e5f2"), 0.16 + 0.64 * t0)
            if radial % 4 == 0:
                tint = tint.lerp(Color("#59c8df"), 0.40)
            for sample in [Vector2(t0, a0), Vector2(t1, a0), Vector2(t1, a1),
                    Vector2(t0, a0), Vector2(t1, a1), Vector2(t0, a1)]:
                tool.set_color(tint)
                tool.add_vertex(_support_point(side, sample.x, sample.y))
    tool.generate_normals()
    return tool.commit()

func _attach(parent: Node3D, title: String, mesh: Mesh,
        location: Vector3, material: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = title
    node.mesh = mesh
    node.position = location
    node.material_override = material
    parent.add_child(node)
    return node

func _ready() -> void:
    var metal := StandardMaterial3D.new()
    metal.albedo_color = Color.WHITE
    metal.vertex_color_use_as_albedo = true
    metal.metallic = 0.48
    metal.roughness = 0.36
    metal.cull_mode = BaseMaterial3D.CULL_DISABLED
    var pod_metal := StandardMaterial3D.new()
    pod_metal.albedo_color = Color("#678cb1")
    pod_metal.metallic = 0.45
    pod_metal.roughness = 0.36
    var cyan := StandardMaterial3D.new()
    cyan.albedo_color = Color("#63f5f5")
    cyan.emission_enabled = true
    cyan.emission = Color("#31d8ff")
    cyan.emission_energy_multiplier = 1.65
    var gold := StandardMaterial3D.new()
    gold.albedo_color = Color("#ffd69a")
    gold.emission_enabled = true
    gold.emission = Color("#ff9e53")
    gold.emission_energy_multiplier = 1.45
    var tube_left := _support_mesh(-1.0)
    var tube_right := _support_mesh(1.0)
    var ring_mesh := TorusMesh.new()
    ring_mesh.inner_radius = 2.20
    ring_mesh.outer_radius = 2.50
    ring_mesh.rings = 40
    ring_mesh.ring_segments = 10
    var pod_mesh := SphereMesh.new()
    pod_mesh.radial_segments = 20
    pod_mesh.rings = 12
    var cable_mesh := CylinderMesh.new()
    cable_mesh.top_radius = 0.065
    cable_mesh.bottom_radius = 0.065
    cable_mesh.height = 2.0
    cable_mesh.radial_segments = 8
    for index in range(CRANE_COUNT):
        var side := -1.0 if index % 2 == 0 else 1.0
        var root_node := Node3D.new()
        root_node.name = "Orbital transfer crane %02d" % index
        root_node.position = Vector3(side * 9.8, 0.0,
            -12.0 - float(index) * CRANE_SPACING)
        add_child(root_node)
        cranes.append(root_node)
        supports.append(_attach(root_node, "Sculpted tapered orbital support",
            tube_left if side < 0.0 else tube_right, Vector3.ZERO, metal))
        var ring := _attach(root_node, "Three-dimensional cargo docking halo",
            ring_mesh, Vector3(-side * 4.65, 10.5, 0.35),
            cyan if index % 2 == 0 else gold)
        ring.rotation.x = PI * 0.5
        transfer_rings.append(ring)
        for pod_index in range(2):
            var offset := float(pod_index) * 1.35
            var pod_x := -side * (4.65 + offset)
            var pod := _attach(root_node, "Suspended freight shuttle %d" % pod_index,
                pod_mesh, Vector3(pod_x, 6.6 + float(pod_index) * 0.35, 0.0), pod_metal)
            pod.scale = Vector3(1.05, 0.72, 1.90)
            freight_pods.append(pod)
            _attach(root_node, "Visible cargo hoist cable %d" % pod_index,
                cable_mesh, Vector3(pod_x, 8.2, 0.0), metal)

func _process(delta: float) -> void:
    if not running:
        return
    elapsed += delta
    for index in range(cranes.size()):
        var crane := cranes[index]
        crane.position.z += travel_speed * delta
        if crane.position.z > 23.0:
            crane.position.z -= LOOP_LENGTH
        transfer_rings[index].rotation.z = sin(elapsed * 0.62 + float(index)) * 0.15
    for index in range(freight_pods.size()):
        freight_pods[index].position.y = 6.6 + float(index % 2) * 0.35 + sin(
            elapsed * 1.1 + float(index) * 0.9) * 0.23
