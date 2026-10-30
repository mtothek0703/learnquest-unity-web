extends Node3D
## V123: five optional Star Harbor cargo transfer gates, selected using the
## existing three-lane steering. No collision bodies, new touch controls or
## interruptions to the three-question / continuous-race flow.

const DELIVERY_COUNT := 5
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
var stations: Array[Node3D] = []
var portals: Array[MeshInstance3D] = []
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

func _ready() -> void:
    var ring := TorusMesh.new()
    ring.inner_radius = 1.55
    ring.outer_radius = 1.82
    ring.rings = 40
    ring.ring_segments = 12
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.50
    capsule.height = 2.1
    capsule.radial_segments = 20
    capsule.rings = 8
    var cyan := _material(Color("#64f5fa"), true)
    var magenta := _material(Color("#ff8ee4"), true)
    var hull := _material(Color("#88b6d4"))
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
        portal.material_override = (cyan if side < 0.0 else magenta).duplicate()
        portal.position = Vector3(side * LANE_X, 2.05, 0.0)
        portal.rotation.x = PI * 0.5
        station.add_child(portal)
        portals.append(portal)
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

func check_delivery(rider_x: float) -> Dictionary:
    if not running:
        return {}
    for station in stations:
        if bool(station.get_meta("passed")) or station.position.z < 0.2:
            continue
        station.set_meta("passed", true)
        station.visible = false
        if absf(rider_x - float(station.get_meta("lane_x"))) <= 1.30:
            completed_deliveries += 1
            delivery_streak += 1
            best_delivery_streak = maxi(best_delivery_streak, delivery_streak)
            # The fifth consecutive delivery completes the optional mastery
            # objective. No bonus is paid before the full level finishes.
            perfect_convoy = delivery_streak == DELIVERY_COUNT
            _refresh_gate_guidance()
            return {"delivered": true, "xp": 30 + 10 * (delivery_streak - 1),
                "energy": 12, "count": completed_deliveries,
                "streak": delivery_streak, "perfect_convoy": perfect_convoy,
                "turbo_seconds": (2.0 + 0.5 * float(delivery_streak - 3)) if delivery_streak >= 3 else 0.0}
        missed_deliveries += 1
        delivery_streak = 0
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
