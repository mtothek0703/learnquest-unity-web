extends Node3D
## Skyway V44: original sculpted orbital harbor, built from reusable ArrayMeshes.
## No downloads, external textures or third-party licensing requirements.

var running := false
var travel_speed := 14.0
var elapsed := 0.0
var moving_parts: Array[Node3D] = []
var rotors: Array[Node3D] = []

func _ready() -> void:
    _build_harbor()

func _material(color: Color, glow: bool = false, vertex_shading: bool = false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = 0.62
    m.roughness = 0.29
    m.vertex_color_use_as_albedo = vertex_shading
    if glow:
        m.emission_enabled = true
        m.emission = color
        m.emission_energy_multiplier = 1.9
    return m

func _instance(parent: Node3D, title: String, geometry: Mesh, location: Vector3, surface: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = title
    node.mesh = geometry
    node.position = location
    node.material_override = surface
    parent.add_child(node)
    return node

func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, tint: Color) -> void:
    tool.set_color(tint)
    tool.add_vertex(a)
    tool.add_vertex(b)
    tool.add_vertex(c)
    tool.add_vertex(a)
    tool.add_vertex(c)
    tool.add_vertex(d)

func _tower_mesh() -> ArrayMesh:
    # One continuous tapering, twisted 3D tower; reuse the mesh for every skyline tower.
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SIDES := 16
    const LEVELS := 10
    for level in range(LEVELS):
        var t0 := float(level) / float(LEVELS)
        var t1 := float(level + 1) / float(LEVELS)
        for side in range(SIDES):
            var a0 := TAU * float(side) / float(SIDES)
            var a1 := TAU * float(side + 1) / float(SIDES)
            var p00 := _tower_point(t0, a0)
            var p01 := _tower_point(t0, a1)
            var p10 := _tower_point(t1, a0)
            var p11 := _tower_point(t1, a1)
            var tint := Color("#244a72").lerp(Color("#8bc5e6"), t0 * 0.75)
            if side % 4 == 0:
                tint = Color("#3999a8").lerp(Color("#a4f4f1"), t0)
            _quad(tool, p00, p10, p11, p01, tint)
    tool.generate_normals()
    return tool.commit()

func _tower_point(height_fraction: float, angle: float) -> Vector3:
    var radius := 1.6 * (1.0 - height_fraction * 0.48) + 0.24 * sin(height_fraction * TAU * 2.0)
    var twist := angle + height_fraction * 0.62
    return Vector3(cos(twist) * radius, height_fraction * 11.5, sin(twist) * radius)

func _arch_mesh() -> ArrayMesh:
    # A true curved, extruded portal, not a chain of rectangular blocks.
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SEGMENTS := 36
    for i in range(SEGMENTS):
        var a0 := PI - PI * float(i) / float(SEGMENTS)
        var a1 := PI - PI * float(i + 1) / float(SEGMENTS)
        var inner0 := Vector3(cos(a0) * 6.0, sin(a0) * 6.0, -0.35)
        var inner1 := Vector3(cos(a1) * 6.0, sin(a1) * 6.0, -0.35)
        var outer0 := Vector3(cos(a0) * 6.6, sin(a0) * 6.6, -0.35)
        var outer1 := Vector3(cos(a1) * 6.6, sin(a1) * 6.6, -0.35)
        var front_color := Color("#4df6f5").lerp(Color("#ee86f9"), float(i) / float(SEGMENTS))
        _quad(tool, inner0, outer0, outer1, inner1, front_color)
        _quad(tool, inner1 + Vector3(0, 0, 0.7), outer1 + Vector3(0, 0, 0.7), outer0 + Vector3(0, 0, 0.7), inner0 + Vector3(0, 0, 0.7), front_color.darkened(0.30))
        _quad(tool, outer0, outer0 + Vector3(0, 0, 0.7), outer1 + Vector3(0, 0, 0.7), outer1, Color("#a9b8e9"))
        _quad(tool, inner1, inner1 + Vector3(0, 0, 0.7), inner0 + Vector3(0, 0, 0.7), inner0, Color("#283e78"))
    tool.generate_normals()
    return tool.commit()

func _ship_mesh() -> ArrayMesh:
    # Closed, shaded airship hull with a rounded nose and tapered stern.
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SIDES := 16
    const LENGTHS := 18
    for section in range(LENGTHS):
        var t0 := float(section) / float(LENGTHS)
        var t1 := float(section + 1) / float(LENGTHS)
        for side in range(SIDES):
            var a0 := TAU * float(side) / float(SIDES)
            var a1 := TAU * float(side + 1) / float(SIDES)
            var p00 := _ship_point(t0, a0)
            var p01 := _ship_point(t0, a1)
            var p10 := _ship_point(t1, a0)
            var p11 := _ship_point(t1, a1)
            var tint := Color("#386ca3").lerp(Color("#b9e5f2"), t0 * 0.85)
            if side % 5 == 0:
                tint = Color("#f1a7db")
            _quad(tool, p00, p10, p11, p01, tint)
    tool.generate_normals()
    return tool.commit()

func _ship_point(t: float, angle: float) -> Vector3:
    var radius := maxf(0.025, sin(PI * t)) * (1.0 + 0.18 * sin(PI * 2.0 * t))
    return Vector3(cos(angle) * 1.8 * radius, 0.18 + sin(angle) * 0.95 * radius, (t - 0.5) * 9.5)

func _build_harbor() -> void:
    var tower_mesh := _tower_mesh()
    var tower_mat := _material(Color.WHITE, false, true)
    var ship_mesh := _ship_mesh()
    var ship_mat := _material(Color.WHITE, false, true)
    var arch_mesh := _arch_mesh()
    var arch_mat := _material(Color.WHITE, false, true)
    var ring_mesh := TorusMesh.new()
    ring_mesh.inner_radius = 1.25
    ring_mesh.outer_radius = 1.40
    ring_mesh.rings = 32
    ring_mesh.ring_segments = 8
    var ring_mat := _material(Color("#73f7ff"), true)
    for i in range(14):
        var side := -1.0 if i % 2 == 0 else 1.0
        var tower_root := Node3D.new()
        tower_root.name = "Harbor tower cluster %d" % i
        tower_root.position = Vector3(side * (11.5 + float(i % 3) * 1.9), -0.3, -14.0 - float(i) * 12.5)
        add_child(tower_root)
        moving_parts.append(tower_root)
        var tower := _instance(tower_root, "Sculpted orbital tower", tower_mesh, Vector3.ZERO, tower_mat)
        tower.scale = Vector3.ONE * (0.85 + float(i % 4) * 0.13)
        var ring := _instance(tower_root, "Glowing docking ring", ring_mesh, Vector3(0, 8.8, 0), ring_mat)
        ring.scale = Vector3.ONE * (1.0 + float(i % 3) * 0.15)
        if i % 3 == 0:
            var ship := _instance(tower_root, "Sculpted sky freighter", ship_mesh, Vector3(-side * 3.2, 11.0, -3.0), ship_mat)
            ship.rotation.y = side * 0.36
            var rotor := Node3D.new()
            rotor.name = "Animated harbor turbine"
            rotor.position = Vector3(-side * 3.2, 10.6, -3.0)
            tower_root.add_child(rotor)
            rotors.append(rotor)
            var turbine := TorusMesh.new()
            turbine.inner_radius = 1.45
            turbine.outer_radius = 1.63
            turbine.rings = 28
            turbine.ring_segments = 8
            _instance(rotor, "Turbine neon halo", turbine, Vector3.ZERO, _material(Color("#ff89e6"), true))
    for i in range(6):
        var portal := Node3D.new()
        portal.name = "Harbor flight arch %d" % i
        portal.position = Vector3(0, 0.0, -27.0 - float(i) * 28.0)
        add_child(portal)
        moving_parts.append(portal)
        _instance(portal, "Sculpted luminous harbor arch", arch_mesh, Vector3.ZERO, arch_mat)
        var beacon := SphereMesh.new()
        beacon.radial_segments = 16
        beacon.rings = 8
        for side in [-1.0, 1.0]:
            var light := _instance(portal, "Harbor portal beacon", beacon, Vector3(side * 6.2, 0.5, 0), _material(Color("#ffe7a6"), true))
            light.scale = Vector3(0.3, 0.55, 0.3)

func _process(delta: float) -> void:
    elapsed += delta
    for index in range(rotors.size()):
        rotors[index].rotation.y += delta * (0.55 + float(index % 3) * 0.16)
    if not running:
        return
    for prop in moving_parts:
        prop.position.z += travel_speed * delta
        if prop.position.z > 23.0:
            prop.position.z -= 190.0
