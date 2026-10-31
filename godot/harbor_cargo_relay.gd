extends Node3D
## V123: five optional Star Harbor cargo transfer gates, selected using the
## existing three-lane steering. No collision bodies, new touch controls or
## interruptions to the three-question / continuous-race flow.

const DELIVERY_COUNT := 5
# Optional skill challenge inside the existing delivery lane; the broad
# 1.30 m cargo catch zone and all touch controls remain unchanged.
const PRECISION_RADIUS := 0.42
const AERIAL_MIN_HEIGHT := 0.85
const AERIAL_MASTER_TARGET := 4
const LANE_X := 3.1
const START_Z := -85.0
const SPACING := 190.0

var running := false
var travel_speed := 14.0
var elapsed := 0.0
var completed_deliveries := 0
var missed_deliveries := 0
var delivery_streak := 0
var best_delivery_streak := 0
var perfect_convoy := false
var precision_deliveries := 0
var precision_streak := 0
var perfect_precision := false
var aerial_deliveries := 0
var aerial_mastery := false
var stations: Array[Node3D] = []
var portals: Array[MeshInstance3D] = []
var precision_targets: Array[MeshInstance3D] = []
var aerial_targets: Array[MeshInstance3D] = []
var cargo: Array[MeshInstance3D] = []

func _material(color: Color, glow: bool = false) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = 0.42
    material.roughness = 0.28
    if glow:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 2.1
        material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    return material

func _precision_guides_mesh() -> ArrayMesh:
    # Four inward-pointing, real 3D triangles frame the small precision ring.
    # One shared mesh per dock keeps the center readable on phone landscape.
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for corner in range(4):
        var angle := TAU * float(corner) / 4.0
        var radial := Vector2(cos(angle), sin(angle))
        var tangent := Vector2(-sin(angle), cos(angle))
        for point in [radial * 0.52, radial * 1.02 + tangent * 0.18,
                radial * 1.02 - tangent * 0.18]:
            tool.set_normal(Vector3.UP)
            tool.add_vertex(Vector3(point.x, 0.0, point.y))
    return tool.commit()

func _ready() -> void:
    var ring := TorusMesh.new()
    ring.inner_radius = 1.55
    ring.outer_radius = 1.82
    ring.rings = 40
    ring.ring_segments = 12
    # A concentric golden 3D aiming ring shows the narrower precision zone.
    # Shared geometry, no new collider or mobile control.
    var precision_mesh := TorusMesh.new()
    precision_mesh.inner_radius = 0.34
    precision_mesh.outer_radius = 0.45
    precision_mesh.rings = 28
    precision_mesh.ring_segments = 8
    # Raised 3D jump targets reuse the existing touch gesture.
    var aerial_mesh := TorusMesh.new()
    aerial_mesh.inner_radius = 0.58
    aerial_mesh.outer_radius = 0.73
    aerial_mesh.rings = 28
    aerial_mesh.ring_segments = 8
    var guide_mesh := _precision_guides_mesh()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.50
    capsule.height = 2.1
    capsule.radial_segments = 20
    capsule.rings = 8
    var cyan := _material(Color("#64f5fa"), true)
    var magenta := _material(Color("#ff8ee4"), true)
    var hull := _material(Color("#88b6d4"))
    var precision_gold := _material(Color("#ffe39a"), true)
    precision_gold.cull_mode = BaseMaterial3D.CULL_DISABLED
    var aerial_cyan := _material(Color("#83f7ff"), true)
    for index in range(DELIVERY_COUNT):
        var side := -1.0 if index % 2 == 0 else 1.0
        var station := Node3D.new()
        station.name = "Playable orbital cargo transfer %d" % index
        station.position.z = START_Z - float(index) * SPACING
        station.set_meta("passed", false)
        station.set_meta("lane_x", side * LANE_X)
        add_child(station)
        stations.append(station)
        var portal := MeshInstance3D.new()
        portal.name = "Illuminated cargo transfer ring"
        portal.mesh = ring
        portal.material_override = _material(Color("#64f5fa") if side < 0.0 else Color("#ff8ee4"), true)
        portal.position = Vector3(side * LANE_X, 2.05, 0.0)
        portal.rotation.x = PI * 0.5
        station.add_child(portal)
        portals.append(portal)
        var precision_target := MeshInstance3D.new()
        precision_target.name = "Golden precision docking target"
        precision_target.mesh = precision_mesh
        precision_target.material_override = precision_gold
        precision_target.position = Vector3(side * LANE_X, 2.05, -0.14)
        precision_target.rotation.x = PI * 0.5
        station.add_child(precision_target)
        precision_targets.append(precision_target)
        var aerial_target := MeshInstance3D.new()
        aerial_target.name = "Raised aerial cargo jump ring"
        aerial_target.mesh = aerial_mesh
        aerial_target.material_override = aerial_cyan
        aerial_target.position = Vector3(side * LANE_X, 4.30, -0.16)
        aerial_target.rotation.x = PI * 0.5
        station.add_child(aerial_target)
        aerial_targets.append(aerial_target)
        var guidance := MeshInstance3D.new()
        guidance.name = "Precision four-arrow guidance"
        guidance.mesh = guide_mesh
        guidance.material_override = precision_gold
        precision_target.add_child(guidance)
        var pod := MeshInstance3D.new()
        pod.name = "Suspended delivery capsule"
        pod.mesh = capsule
        pod.material_override = hull
        pod.position = Vector3(side * LANE_X, 4.65, 0.0)
        pod.rotation.z = PI * 0.5
        station.add_child(pod)
        cargo.append(pod)
        var halo := MeshInstance3D.new()
        halo.name = "Cargo capture halo"
        halo.mesh = ring
        halo.material_override = cyan if side < 0.0 else magenta
        halo.position = Vector3(side * LANE_X, 4.65, 0.0)
        halo.scale = Vector3.ONE * 0.42
        station.add_child(halo)

func reset_course() -> void:
    elapsed = 0.0
    completed_deliveries = 0
    missed_deliveries = 0
    delivery_streak = 0
    best_delivery_streak = 0
    perfect_convoy = false
    precision_deliveries = 0
    precision_streak = 0
    perfect_precision = false
    aerial_deliveries = 0
    aerial_mastery = false
    for index in range(stations.size()):
        stations[index].position.z = START_Z - float(index) * SPACING
        stations[index].set_meta("passed", false)
        stations[index].visible = true
    _refresh_gate_guidance()

func _refresh_gate_guidance() -> void:
    # Existing 3D dock rings brighten as the uninterrupted cargo convoy grows.
    # Each ring owns a duplicated material: no new draw calls or collisions.
    for index in range(stations.size()):
        if bool(stations[index].get_meta("passed")):
            continue
        var ring := portals[index]
        var glow := ring.material_override as StandardMaterial3D
        if glow != null:
            glow.emission_energy_multiplier = 2.1 + 0.32 * float(delivery_streak)
        ring.scale = Vector3.ONE * (1.0 + 0.035 * float(delivery_streak))
        # A successful precise catch makes the next inner target larger.
        precision_targets[index].scale = Vector3.ONE * (1.0 + 0.055 * float(precision_streak))
        aerial_targets[index].scale = Vector3.ONE * (1.0 + 0.04 * float(aerial_deliveries))

func check_delivery(rider_x: float, rider_y: float = 0.0) -> Dictionary:
    if not running:
        return {}
    for station in stations:
        if bool(station.get_meta("passed")) or station.position.z < 0.2:
            continue
        station.set_meta("passed", true)
        station.visible = false
        var lane_error := absf(rider_x - float(station.get_meta("lane_x")))
        if lane_error <= 1.30:
            completed_deliveries += 1
            delivery_streak += 1
            best_delivery_streak = maxi(best_delivery_streak, delivery_streak)
            # The fifth consecutive delivery completes the optional mastery
            # objective. No bonus is paid before the full level finishes.
            perfect_convoy = delivery_streak == DELIVERY_COUNT
            var precise := lane_error <= PRECISION_RADIUS
            if precise:
                precision_deliveries += 1
                precision_streak += 1
            else:
                precision_streak = 0
            perfect_precision = precision_deliveries == DELIVERY_COUNT
            var aerial := rider_y >= AERIAL_MIN_HEIGHT
            if aerial:
                aerial_deliveries += 1
            var aerial_mastery_award := aerial and aerial_deliveries == AERIAL_MASTER_TARGET
            aerial_mastery = aerial_deliveries >= AERIAL_MASTER_TARGET
            _refresh_gate_guidance()
            return {"delivered": true, "xp": 30 + 10 * (delivery_streak - 1) + (15 if precise else 0) + (20 if aerial else 0) + (40 if aerial_mastery_award else 0),
                "energy": 12, "count": completed_deliveries,
                "streak": delivery_streak, "perfect_convoy": perfect_convoy,
                "precision": precise, "precision_count": precision_deliveries,
                "perfect_precision": perfect_precision,
                "aerial": aerial, "aerial_count": aerial_deliveries,
                "aerial_mastery": aerial_mastery, "aerial_mastery_award": aerial_mastery_award,
                "turbo_seconds": maxf((2.0 + 0.5 * float(delivery_streak - 3)) if delivery_streak >= 3 else 0.0, 0.75 if aerial else 0.0)}
        missed_deliveries += 1
        delivery_streak = 0
        precision_streak = 0
        _refresh_gate_guidance()
        return {"missed": true, "streak": 0}
    return {}

func _process(delta: float) -> void:
    if not running:
        return
    elapsed += delta
    for index in range(stations.size()):
        var station := stations[index]
        if bool(station.get_meta("passed")):
            continue
        station.position.z += travel_speed * delta
        cargo[index].position.y = 4.65 + 0.22 * sin(elapsed * 2.0 + float(index))
        cargo[index].rotation.y = sin(elapsed * 0.7 + float(index)) * 0.18
