extends Node3D
## Skyway V44: original sculpted orbital harbor, built from reusable ArrayMeshes.
## No downloads, external textures or third-party licensing requirements.

var running := false
var travel_speed := 14.0
var elapsed := 0.0
var moving_parts: Array[Node3D] = []
var rotors: Array[Node3D] = []
var carrier_hulls: Array[Node3D] = []
var carrier_rings: Array[Node3D] = []
var carrier_engines: Array[MeshInstance3D] = []
var cinematic_drydocks: Node3D
var cargo_relay: Node3D

func _ready() -> void:
    _build_harbor()
    cinematic_drydocks = preload("res://cinematic_harbor_drydocks.gd").new() as Node3D
    cinematic_drydocks.name = "Cinematic Star Harbor loading drydocks"
    add_child(cinematic_drydocks)
    cargo_relay = preload("res://harbor_cargo_relay.gd").new() as Node3D
    cargo_relay.name = "Playable Star Harbor cargo relay"
    add_child(cargo_relay)

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
    _build_carriers()


# V82: enormous shaded orbital carriers frame Star Harbor in landscape.
# Entirely procedural, mobile-friendly geometry; no downloaded assets.
func _build_carriers() -> void:
    var hull_material := _material(Color("#667da7"))
    var wing_material := _material(Color("#354e7a"))
    var neon_material := _material(Color("#5cf7f0"), true)
    var pink_material := _material(Color("#ff83df"), true)
    var glass_material := _material(Color(0.17, 0.83, 0.98, 0.66), true)
    glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    glass_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    var fuselage_mesh := SphereMesh.new()
    fuselage_mesh.radius = 1.0
    fuselage_mesh.height = 2.0
    fuselage_mesh.radial_segments = 24
    fuselage_mesh.rings = 12
    var prow_mesh := CylinderMesh.new()
    prow_mesh.top_radius = 0.10
    prow_mesh.bottom_radius = 1.35
    prow_mesh.height = 3.8
    prow_mesh.radial_segments = 16
    var wing_mesh := BoxMesh.new()
    wing_mesh.size = Vector3(4.6, 0.30, 4.5)
    var fin_mesh := BoxMesh.new()
    fin_mesh.size = Vector3(0.20, 1.5, 2.6)
    var ring_mesh := TorusMesh.new()
    ring_mesh.inner_radius = 3.85
    ring_mesh.outer_radius = 4.14
    ring_mesh.rings = 48
    ring_mesh.ring_segments = 12
    var engine_mesh := CylinderMesh.new()
    engine_mesh.top_radius = 0.45
    engine_mesh.bottom_radius = 0.58
    engine_mesh.height = 1.4
    engine_mesh.radial_segments = 12
    var flame_mesh := SphereMesh.new()
    flame_mesh.radius = 0.42
    flame_mesh.height = 0.84
    flame_mesh.radial_segments = 12
    flame_mesh.rings = 8
    for index in range(2):
        var side := -1.0 if index == 0 else 1.0
        var carrier := Node3D.new()
        carrier.name = "Cinematic orbital carrier %d" % index
        carrier.position = Vector3(side * 17.5, 12.5, -35.0 - float(index) * 63.0)
        add_child(carrier)
        moving_parts.append(carrier)
        carrier_hulls.append(carrier)
        var hull := _instance(carrier, "Armored carrier fuselage", fuselage_mesh, Vector3.ZERO, hull_material)
        hull.scale = Vector3(2.15, 1.30, 5.0)
        var prow := _instance(carrier, "Sculpted command prow", prow_mesh, Vector3(0.0, 0.0, -5.7), hull_material)
        prow.rotation.x = PI * 0.5
        var cockpit := _instance(carrier, "Panoramic command canopy", fuselage_mesh, Vector3(0.0, 1.0, -2.2), glass_material)
        cockpit.scale = Vector3(1.15, 0.52, 1.65)
        for wing_side in [-1.0, 1.0]:
            var wing := _instance(carrier, "Swept armor wing", wing_mesh, Vector3(wing_side * 3.5, -0.20, 0.15), wing_material)
            wing.rotation.z = wing_side * 0.11
            _instance(carrier, "Wing neon running light", fin_mesh, Vector3(wing_side * 5.45, 0.58, 0.0), neon_material if index == 0 else pink_material)
        for ring_index in range(2):
            var ring_pivot := Node3D.new()
            ring_pivot.name = "Animated docking gyroscope %d" % ring_index
            ring_pivot.position.z = 0.7 + float(ring_index) * 2.3
            ring_pivot.rotation.x = PI * 0.5 + float(ring_index) * 0.23
            carrier.add_child(ring_pivot)
            carrier_rings.append(ring_pivot)
            _instance(ring_pivot, "Sculpted rotating energy torus", ring_mesh, Vector3.ZERO, neon_material if ring_index == 0 else pink_material)
        for engine_index in range(3):
            var engine_x := float(engine_index - 1) * 1.45
            var engine := _instance(carrier, "Shaded ion engine", engine_mesh, Vector3(engine_x, -0.48, 4.7), wing_material)
            engine.rotation.x = PI * 0.5
            var flame := _instance(carrier, "Pulsing ion exhaust %d" % engine_index, flame_mesh, Vector3(engine_x, -0.48, 5.65), neon_material if index == 0 else pink_material)
            carrier_engines.append(flame)
        var floodlight := OmniLight3D.new()
        floodlight.name = "Carrier cinematic engine light"
        floodlight.light_color = Color("#59fff0") if index == 0 else Color("#ff86dd")
        floodlight.light_energy = 0.85
        floodlight.omni_range = 8.0
        floodlight.shadow_enabled = false
        floodlight.position = Vector3(0.0, -0.4, 5.4)
        carrier.add_child(floodlight)

func reset_cargo_relay() -> void:
    cargo_relay.call("reset_course")

func check_cargo_delivery(rider_x: float) -> Dictionary:
    return cargo_relay.call("check_delivery", rider_x)

func get_cargo_deliveries() -> int:
    return int(cargo_relay.get("completed_deliveries"))

func _process(delta: float) -> void:
    if cargo_relay != null:
        cargo_relay.set("running", running)
        cargo_relay.set("travel_speed", travel_speed)
    if cinematic_drydocks != null:
        cinematic_drydocks.set("running", running)
        cinematic_drydocks.set("travel_speed", travel_speed)
    elapsed += delta
    for index in range(rotors.size()):
        rotors[index].rotation.y += delta * (0.55 + float(index % 3) * 0.16)
    for index in range(carrier_hulls.size()):
        var carrier := carrier_hulls[index]
        carrier.position.y = 12.5 + sin(elapsed * 1.1 + float(index) * 1.6) * 0.28
        carrier.rotation.z = sin(elapsed * 0.42 + float(index)) * 0.025
    for index in range(carrier_rings.size()):
        carrier_rings[index].rotation.y += delta * (0.38 + float(index % 2) * 0.17)
    for index in range(carrier_engines.size()):
        carrier_engines[index].scale = Vector3.ONE * (0.72 + 0.24 * sin(elapsed * 7.0 + float(index)))
    if not running:
        return
    for prop in moving_parts:
        prop.position.z += travel_speed * delta
        if prop.position.z > 23.0:
            prop.position.z -= 190.0
