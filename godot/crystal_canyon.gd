extends Node3D
## Original, license-free Crystal Canyon environment for Skyway V42.
## Faceted continuous rock meshes, broad canyon shelves, luminous crystal arches.
## No external textures or runtime downloads; geometry is built once on startup.

var running := false
var travel_speed := 14.0
var elapsed := 0.0
var moving_parts: Array[Node3D] = []
var crystal_pivots: Array[Node3D] = []
var cinematic_geodes: Node3D
var route_choices: Node3D
var completed_routes := 0

func _ready() -> void:
    _build_canyon()
    cinematic_geodes = preload("res://cinematic_canyon_geodes.gd").new() as Node3D
    cinematic_geodes.name = "Cinematic floating geode reefs"
    add_child(cinematic_geodes)
    route_choices = preload("res://canyon_route_choices.gd").new() as Node3D
    route_choices.name = "Playable canyon route choices"
    add_child(route_choices)

func _material(color: Color, glow: bool = false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.78
    m.metallic = 0.06
    if glow:
        m.emission_enabled = true
        m.emission = color
        m.emission_energy_multiplier = 2.3
        m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    return m

func _box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, glow: bool = false) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    n.mesh = mesh
    n.material_override = _material(color, glow)
    n.position = pos
    parent.add_child(n)
    return n

func _rock_mesh() -> ArrayMesh:
    # A real tapering, jagged mesh with shaded strata rather than stacked cubes.
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SIDES := 9
    const HEIGHTS := 5
    for level in range(HEIGHTS - 1):
        var t0 := float(level) / float(HEIGHTS - 1)
        var t1 := float(level + 1) / float(HEIGHTS - 1)
        for side in range(SIDES):
            var a0 := TAU * float(side) / float(SIDES)
            var a1 := TAU * float(side + 1) / float(SIDES)
            var p00 := _rock_point(t0, a0, side)
            var p01 := _rock_point(t0, a1, side + 1)
            var p10 := _rock_point(t1, a0, side)
            var p11 := _rock_point(t1, a1, side + 1)
            var shade := Color("#c27b89").lerp(Color("#f0b58b"), t0) if side % 3 == 0 else Color("#7d5685").lerp(Color("#d09b96"), t0)
            surface.set_color(shade)
            surface.add_vertex(p00)
            surface.add_vertex(p10)
            surface.add_vertex(p11)
            surface.add_vertex(p00)
            surface.add_vertex(p11)
            surface.add_vertex(p01)
    surface.generate_normals()
    return surface.commit()

func _rock_point(height_fraction: float, angle: float, side: int) -> Vector3:
    var taper := 1.0 - height_fraction * 0.80
    var facet := 1.0 + 0.12 * sin(float(side * 5 + 1))
    return Vector3(
        cos(angle) * 2.1 * taper * facet + sin(height_fraction * 3.5) * 0.42,
        height_fraction * 8.0,
        sin(angle) * 1.9 * taper * facet
    )

func _crystal(parent: Node3D, pos: Vector3, size: float, color: Color) -> Node3D:
    var pivot := Node3D.new()
    pivot.position = pos
    parent.add_child(pivot)
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.0
    mesh.bottom_radius = 0.65
    mesh.height = 2.7
    mesh.radial_segments = 6
    var upper := MeshInstance3D.new()
    upper.mesh = mesh
    upper.material_override = _material(color, true)
    upper.scale = Vector3.ONE * size
    pivot.add_child(upper)
    var lower := MeshInstance3D.new()
    lower.mesh = mesh
    lower.material_override = _material(color.darkened(0.25), true)
    lower.rotation.z = PI
    lower.position.y = -1.65 * size
    lower.scale = Vector3.ONE * size * 0.65
    pivot.add_child(lower)
    crystal_pivots.append(pivot)
    return pivot

func _build_canyon() -> void:
    var rock_mesh := _rock_mesh()
    var rock_material := _material(Color.WHITE)
    rock_material.vertex_color_use_as_albedo = true
    for side in [-1.0, 1.0]:
        _box(self, Vector3(side * 13.5, -0.65, -63.0), Vector3(15.0, 1.0, 160.0), Color("#8e547b"))
        _box(self, Vector3(side * 7.8, -0.1, -63.0), Vector3(4.3, 0.2, 160.0), Color("#b8758b"))
        for i in range(16):
            var cluster := Node3D.new()
            cluster.name = "Canyon rock cluster %d %d" % [int(side), i]
            cluster.position = Vector3(side * (10.0 + float(i % 4) * 2.4), -0.15, -11.0 - float(i) * 9.0)
            add_child(cluster)
            moving_parts.append(cluster)
            var rock := MeshInstance3D.new()
            rock.name = "Sculpted canyon spire"
            rock.mesh = rock_mesh
            rock.material_override = rock_material
            rock.scale = Vector3(0.8 + float(i % 3) * 0.20, 0.75 + float(i % 5) * 0.21, 0.9 + float(i % 2) * 0.25)
            rock.rotation.y = float(i) * 0.7
            cluster.add_child(rock)
            if i % 2 == 0:
                _crystal(cluster, Vector3(-side * 1.3, 2.0 + float(i % 3), 0.5), 0.75 + float(i % 3) * 0.18, Color("#68f9ee") if i % 4 == 0 else Color("#f879ef"))
    # Suspended ring gateways are large, unmistakable landmarks at racing speed.
    for i in range(5):
        var gate := Node3D.new()
        gate.name = "Crystal Canyon sky arch %d" % i
        gate.position = Vector3(0, 4.0, -25.0 - float(i) * 28.0)
        add_child(gate)
        moving_parts.append(gate)
        var mesh := TorusMesh.new()
        mesh.inner_radius = 5.4
        mesh.outer_radius = 5.75
        mesh.rings = 40
        mesh.ring_segments = 9
        var arch := MeshInstance3D.new()
        arch.name = "Luminous canyon arch"
        arch.mesh = mesh
        arch.material_override = _material(Color("#80fff3") if i % 2 == 0 else Color("#ff94de"), true)
        arch.rotation.x = PI * 0.5
        gate.add_child(arch)
        _crystal(gate, Vector3(-6.1, 0.2, 0), 1.15, Color("#f5b1ff"))
        _crystal(gate, Vector3(6.1, 0.2, 0), 1.15, Color("#8ffff5"))
    var planet := Node3D.new()
    planet.name = "Canyon double moon"
    planet.position = Vector3(29, 32, -126)
    add_child(planet)
    for i in range(2):
        var sphere := SphereMesh.new()
        sphere.radial_segments = 32
        sphere.rings = 16
        var moon := MeshInstance3D.new()
        moon.mesh = sphere
        moon.material_override = _material(Color("#ffcfad") if i == 0 else Color("#a1d9fa"), true)
        moon.position = Vector3(-7.0 * float(i), 4.0 * float(i), 0)
        moon.scale = Vector3.ONE * (8.5 if i == 0 else 3.6)
        planet.add_child(moon)

func reset_routes() -> void:
    completed_routes = 0
    if route_choices != null:
        route_choices.call("reset_course")

func get_switchback_chain() -> int:
    return int(route_choices.get("switchback_chain")) if route_choices != null else 0

func get_switchback_mastery() -> bool:
    return bool(route_choices.get("perfect_switchback")) if route_choices != null else false

func check_route_choices(rider_x: float) -> Dictionary:
    if route_choices == null:
        return {}
    var result: Dictionary = route_choices.call("check_route_choice", rider_x)
    completed_routes = int(route_choices.get("completed_routes"))
    return result

func _process(delta: float) -> void:
    elapsed += delta
    if cinematic_geodes != null:
        cinematic_geodes.set("running", running)
        cinematic_geodes.set("travel_speed", travel_speed)
    if route_choices != null:
        route_choices.set("running", running)
        route_choices.set("travel_speed", travel_speed)
    if not running:
        return
    for prop in moving_parts:
        prop.position.z += travel_speed * delta
        if prop.position.z > 18.0:
            prop.position.z -= 152.0
    for index in range(crystal_pivots.size()):
        crystal_pivots[index].rotation.y += delta * (0.24 + float(index % 3) * 0.10)
