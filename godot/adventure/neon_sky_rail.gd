extends Node3D
## Original animated sci-fi skyline transit. No collisions, input or rewards.
## Reuses only a few actual meshes / MultiMeshes to keep draw calls bounded
## on Godot 4.4 Compatibility (mobile iPhone Safari WebGL).
const TRACK_Y := 7.2
const TRACK_Z := -13.2
var shuttle: Node3D
var travel_phase := 0.0

func _ready() -> void:
    _build_guideway()
    _build_skimmer()
    set_process(true)

func _process(delta: float) -> void:
    if not is_instance_valid(shuttle):
        return
    # Continuous, reversible patrol, with no teleport at the endpoints.
    travel_phase += minf(delta, 0.1)
    shuttle.position.x = sin(travel_phase * 0.42) * 8.7
    shuttle.position.y = TRACK_Y + 0.35 + 0.07 * sin(travel_phase * 1.8)
    shuttle.rotation.z = 0.028 * cos(travel_phase * 0.42)

func _material(color: Color, glow: bool = false, metal: bool = false) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.25 if metal else 0.55
    material.metallic = 0.68 if metal else 0.0
    if glow:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 2.15
        material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    return material

func _box(parent: Node3D, title: String, size: Vector3, at: Vector3, material: Material) -> MeshInstance3D:
    var result := MeshInstance3D.new()
    result.name = title
    var mesh := BoxMesh.new()
    mesh.size = size
    result.mesh = mesh
    result.material_override = material
    result.position = at
    result.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    parent.add_child(result)
    return result

func _build_guideway() -> void:
    var infrastructure := Node3D.new()
    infrastructure.name = "ElevatedTransitGuideway"
    add_child(infrastructure)
    var chassis := _material(Color("#172941"), false, true)
    var cyan := _material(Color("#46dce8"), true)
    var magenta := _material(Color("#e76ec5"), true)
    _box(infrastructure, "TrackSpine", Vector3(27.0, 0.30, 1.65), Vector3(0, TRACK_Y - 0.48, TRACK_Z), chassis)
    _box(infrastructure, "GuideRailNear", Vector3(26.5, 0.09, 0.12), Vector3(0, TRACK_Y - 0.24, TRACK_Z + 0.79), cyan)
    _box(infrastructure, "GuideRailFar", Vector3(26.5, 0.09, 0.12), Vector3(0, TRACK_Y - 0.24, TRACK_Z - 0.79), magenta)
    # One batched draw for six supports rather than six MeshInstances.
    var support_mesh := CylinderMesh.new()
    support_mesh.top_radius = 0.22
    support_mesh.bottom_radius = 0.35
    support_mesh.height = 6.25
    support_mesh.radial_segments = 8
    support_mesh.material = chassis
    var support_instances := MultiMesh.new()
    support_instances.transform_format = MultiMesh.TRANSFORM_3D
    support_instances.mesh = support_mesh
    support_instances.instance_count = 6
    for i in range(6):
        support_instances.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(-11.0 + float(i) * 4.4, 3.0, TRACK_Z)))
    var pylons := MultiMeshInstance3D.new()
    pylons.name = "RailSupports"
    pylons.multimesh = support_instances
    pylons.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    infrastructure.add_child(pylons)
    # Light-running repeating ties are instanced for the phone GPU.
    for side in [-1.0, 1.0]:
        var tie_mesh := BoxMesh.new()
        tie_mesh.size = Vector3(0.34, 0.035, 0.08)
        tie_mesh.material = cyan if side > 0.0 else magenta
        var ties := MultiMesh.new()
        ties.transform_format = MultiMesh.TRANSFORM_3D
        ties.mesh = tie_mesh
        ties.instance_count = 22
        for i in range(22):
            ties.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(-12.6 + 1.2 * float(i), TRACK_Y - 0.12, TRACK_Z + side * 0.73)))
        var marker := MultiMeshInstance3D.new()
        marker.name = "GuidewayLEDNear" if side > 0.0 else "GuidewayLEDFar"
        marker.multimesh = ties
        marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        infrastructure.add_child(marker)
    # Glowing rings and dark pylons form a distinct, tall architectural layer.
    var ring_mesh := TorusMesh.new()
    ring_mesh.inner_radius = 1.35
    ring_mesh.outer_radius = 1.41
    ring_mesh.material = magenta
    var rings := MultiMesh.new()
    rings.transform_format = MultiMesh.TRANSFORM_3D
    rings.mesh = ring_mesh
    rings.instance_count = 4
    for i in range(4):
        rings.set_instance_transform(i, Transform3D(Basis(Vector3(0, 0, 1), PI * 0.5), Vector3(-10.2 + float(i) * 6.8, TRACK_Y + 0.35, TRACK_Z)))
    var gates := MultiMeshInstance3D.new()
    gates.name = "TransitArchGates"
    gates.multimesh = rings
    gates.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    infrastructure.add_child(gates)
    var direction := Label3D.new()
    direction.name = "TransitDestination"
    direction.text = "NEON CITY / SKYLINE EXPRESS"
    direction.font_size = 48
    direction.pixel_size = 0.006
    direction.outline_size = 10
    direction.modulate = Color("#b9faff")
    direction.outline_modulate = Color("#0b1a2c")
    direction.position = Vector3(-1.8, TRACK_Y + 2.1, TRACK_Z - 0.8)
    infrastructure.add_child(direction)

func _hull_point(section: Vector3, angle: float) -> Vector3:
    return Vector3(section.x, cos(angle) * section.y, sin(angle) * section.z)

func _tapered_hull() -> ArrayMesh:
    # Ring-lofted 3D fuselage: elongated aerodynamic nose, actual curvature.
    # Eight sided low-poly smooth silhouette with 10-sided ring sections.
    var sections := [
        Vector3(-2.35, 0.03, 0.07),
        Vector3(-2.05, 0.32, 0.42),
        Vector3(-1.55, 0.47, 0.68),
        Vector3(1.25, 0.48, 0.67),
        Vector3(1.85, 0.32, 0.46),
        Vector3(2.25, 0.03, 0.07)
    ]
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(sections.size() - 1):
        var a: Vector3 = sections[i]
        var b: Vector3 = sections[i + 1]
        for n in range(10):
            var theta_a := TAU * float(n) / 10.0
            var theta_b := TAU * float(n + 1) / 10.0
            var a0 := _hull_point(a, theta_a)
            var a1 := _hull_point(a, theta_b)
            var b0 := _hull_point(b, theta_a)
            var b1 := _hull_point(b, theta_b)
            for point in [a0, a1, b0, a1, b1, b0]:
                tool.add_vertex(point)
    tool.generate_normals()
    return tool.commit()

func _build_skimmer() -> void:
    shuttle = Node3D.new()
    shuttle.name = "AerialTram"
    shuttle.position = Vector3(0, TRACK_Y + 0.35, TRACK_Z)
    add_child(shuttle)
    var body := MeshInstance3D.new()
    body.name = "SkimmerHull"
    body.mesh = _tapered_hull()
    body.material_override = _material(Color("#203c57"), false, true)
    body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    shuttle.add_child(body)
    var glass := _material(Color("#65f6fa"), true)
    var interior := _material(Color("#f4a876"), true)
    var underside := _material(Color("#df59bb"), true)
    for side in [-1.0, 1.0]:
        for i in range(3):
            _box(shuttle, "CabinWindow", Vector3(0.64, 0.24, 0.06),
                Vector3(-1.12 + float(i) * 1.1, 0.08, side * 0.67), glass if i != 1 else interior)
        _box(shuttle, "EngineGlow", Vector3(1.95, 0.055, 0.13),
            Vector3(0, -0.49, side * 0.43), underside)
    # Two sculpted rounded end caps hide the loft section seams.
    for side in [-1.0, 1.0]:
        var nose := MeshInstance3D.new()
        nose.name = "AerodynamicLightCap"
        var sphere := SphereMesh.new()
        sphere.radius = 0.16
        sphere.height = 0.32
        nose.mesh = sphere
        nose.scale = Vector3(1.0, 0.6, 0.75)
        nose.material_override = glass
        nose.position = Vector3(side * 2.25, 0.02, 0)
        nose.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        shuttle.add_child(nose)
