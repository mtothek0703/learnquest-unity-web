extends Node3D
## V121: playable Crystal Canyon route-choice junctions.
## Two clearly readable 3D portal paths at each junction share the existing
## three-lane touch steering. No collision bodies, new assets or mid-run quiz.

const JUNCTION_COUNT := 4
const LANE_X := 3.1
const START_Z := -78.0
const SPACING := 200.0

var running := false
var travel_speed := 14.0
var elapsed := 0.0
var completed_routes := 0
var missed_routes := 0
var junctions: Array[Node3D] = []
var portals: Array[MeshInstance3D] = []
var ribbons: Array[MeshInstance3D] = []

func _material(tint: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.vertex_color_use_as_albedo = true
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.emission_enabled = true
    material.emission = tint
    material.emission_energy_multiplier = 1.5
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material

func _route_point(side: float, t: float, angle: float) -> Vector3:
    # A curved, fully 3D route ribbon leads from the center approach into
    # the chosen lane. This is a visual guide, never a physical obstacle.
    var bend := smoothstep(0.0, 1.0, t)
    var radius := 0.16
    return Vector3(side * LANE_X * bend + cos(angle) * radius,
        0.10 + 0.025 * sin(t * PI) + sin(angle) * radius,
        -13.0 + 13.0 * t)

func _route_mesh(side: float) -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(24):
        var t0 := float(step) / 24.0
        var t1 := float(step + 1) / 24.0
        for edge in range(10):
            var a0 := TAU * float(edge) / 10.0
            var a1 := TAU * float(edge + 1) / 10.0
            var p00 := _route_point(side, t0, a0)
            var p01 := _route_point(side, t0, a1)
            var p10 := _route_point(side, t1, a0)
            var p11 := _route_point(side, t1, a1)
            var tint := Color("#6dfff2") if side < 0.0 else Color("#ff9bdf")
            surface.set_color(tint.lerp(Color.WHITE, 0.23 * t0))
            surface.add_vertex(p00)
            surface.add_vertex(p10)
            surface.add_vertex(p11)
            surface.add_vertex(p00)
            surface.add_vertex(p11)
            surface.add_vertex(p01)
    surface.generate_normals()
    return surface.commit()

func _ready() -> void:
    var portal_mesh := TorusMesh.new()
    portal_mesh.inner_radius = 1.62
    portal_mesh.outer_radius = 1.87
    portal_mesh.rings = 40
    portal_mesh.ring_segments = 10
    var guide_mesh_left := _route_mesh(-1.0)
    var guide_mesh_right := _route_mesh(1.0)
    var cyan := _material(Color("#63ffe7"))
    var pink := _material(Color("#ff8ee0"))
    for index in range(JUNCTION_COUNT):
        var junction := Node3D.new()
        junction.name = "Playable canyon route fork %d" % index
        junction.position.z = START_Z - float(index) * SPACING
        junction.set_meta("passed", false)
        add_child(junction)
        junctions.append(junction)
        for side in [-1.0, 1.0]:
            var material := cyan if side < 0.0 else pink
            var portal := MeshInstance3D.new()
            portal.name = "Energy route portal" if side < 0.0 else "XP route portal"
            portal.mesh = portal_mesh
            portal.material_override = material
            portal.position = Vector3(side * LANE_X, 2.15, 0.0)
            portal.rotation.x = PI * 0.5
            junction.add_child(portal)
            portals.append(portal)
            var guide := MeshInstance3D.new()
            guide.name = "Curved lane choice guide"
            guide.mesh = guide_mesh_left if side < 0.0 else guide_mesh_right
            guide.material_override = material
            junction.add_child(guide)
            ribbons.append(guide)
            var beacon := MeshInstance3D.new()
            beacon.name = "Floating route beacon"
            var crystal := CylinderMesh.new()
            crystal.top_radius = 0.0
            crystal.bottom_radius = 0.42
            crystal.height = 1.7
            crystal.radial_segments = 7
            beacon.mesh = crystal
            beacon.material_override = material
            beacon.position = Vector3(side * LANE_X, 4.55, 0.0)
            junction.add_child(beacon)

func reset_course() -> void:
    completed_routes = 0
    missed_routes = 0
    elapsed = 0.0
    for index in range(junctions.size()):
        var junction := junctions[index]
        junction.position.z = START_Z - float(index) * SPACING
        junction.set_meta("passed", false)
        junction.visible = true

func check_route_choice(rider_x: float) -> Dictionary:
    # A junction is scored once when it crosses the rider plane.
    # Steering selects a reward, but neither path damages the player.
    # The center lane is allowed and simply skips the optional bonus.
    if not running:
        return {}
    for junction in junctions:
        if bool(junction.get_meta("passed")) or junction.position.z < 0.2:
            continue
        junction.set_meta("passed", true)
        junction.visible = false
        if absf(rider_x + LANE_X) <= 1.35:
            completed_routes += 1
            return {"choice": "energy", "energy": 20, "xp": 15, "count": completed_routes}
        if absf(rider_x - LANE_X) <= 1.35:
            completed_routes += 1
            return {"choice": "xp", "energy": 0, "xp": 40, "count": completed_routes}
        missed_routes += 1
        return {"missed": true}
    return {}

func _process(delta: float) -> void:
    if not running:
        return
    elapsed += delta
    for index in range(junctions.size()):
        var junction := junctions[index]
        if bool(junction.get_meta("passed")):
            continue
        junction.position.z += travel_speed * delta
        # Small beacon pulse without extra dynamic lights or shadows.
        for child in junction.get_children():
            if child is MeshInstance3D and child.name == "Floating route beacon":
                child.position.y = 4.55 + 0.18 * sin(elapsed * 2.0 + float(index))
