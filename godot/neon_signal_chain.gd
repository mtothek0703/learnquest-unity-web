extends Node3D
## Neon City signal-chain mission: six 3D courier gates across all three
## existing touch lanes. Correct successive lanes build an overdrive streak.
## Entirely optional: no collision bodies, extra controls or mid-run questions.

const SIGNAL_COUNT := 6
const LANE_X := 3.1
const START_Z := -92.0
const SPACING := 112.0
const TARGET_SIGNALS := 4
const PRECISION_RADIUS := 0.42
const PRECISION_XP := 10
const PERFECT_PRECISION_XP := 40

var running := false
var travel_speed := 14.0
var elapsed := 0.0
var completed_signals := 0
var missed_signals := 0
var streak := 0
var best_streak := 0
# All six correctly steered gates in a single uninterrupted streak.
var perfect_chain := false
var precision_hits := 0
var precision_mastery := false
var gates: Array[Node3D] = []
var rings: Array[MeshInstance3D] = []
var precision_rings: Array[MeshInstance3D] = []
var beacons: Array[MeshInstance3D] = []

func _material(tint: Color, glow: bool = false) -> StandardMaterial3D:
    var result := StandardMaterial3D.new()
    result.albedo_color = tint
    result.metallic = 0.45
    result.roughness = 0.28
    if glow:
        result.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        result.emission_enabled = true
        result.emission = tint
        result.emission_energy_multiplier = 2.0
    return result

func _ready() -> void:
    var ring_mesh := TorusMesh.new()
    ring_mesh.inner_radius = 1.52
    ring_mesh.outer_radius = 1.83
    ring_mesh.rings = 36
    ring_mesh.ring_segments = 10
    var precision_mesh := TorusMesh.new()
    precision_mesh.inner_radius = 0.58
    precision_mesh.outer_radius = 0.78
    precision_mesh.rings = 28
    precision_mesh.ring_segments = 8
    var core_mesh := CylinderMesh.new()
    core_mesh.top_radius = 0.0
    core_mesh.bottom_radius = 0.50
    core_mesh.height = 1.20
    core_mesh.radial_segments = 6
    var bar_mesh := BoxMesh.new()
    bar_mesh.size = Vector3(0.22, 0.08, 2.7)
    var colors := [Color("#ff96df"), Color("#6bfff0"), Color("#ffc875")]
    var steel := _material(Color("#405477"))
    for index in range(SIGNAL_COUNT):
        var lane_index: int = (index + 2) % 3 - 1
        var lane_x := float(lane_index) * LANE_X
        var gate := Node3D.new()
        gate.name = "Courier signal gate %d" % index
        gate.position.z = START_Z - float(index) * SPACING
        gate.set_meta("lane", lane_index)
        gate.set_meta("passed", false)
        add_child(gate)
        gates.append(gate)

        var tint: Color = colors[lane_index + 1]
        var glowing := _material(tint, true)
        var ring := MeshInstance3D.new()
        ring.name = "Full-size luminous signal arch"
        ring.mesh = ring_mesh
        ring.material_override = glowing
        ring.position = Vector3(lane_x, 2.05, 0.0)
        ring.rotation.x = PI * 0.5
        gate.add_child(ring)
        rings.append(ring)
        # Real 3D gold bullseye inside the original catch arch; no collider.
        var bullseye := MeshInstance3D.new()
        bullseye.name = "Precision gold inner target"
        bullseye.mesh = precision_mesh
        bullseye.material_override = _material(Color("#ffe59b"), true)
        bullseye.position = ring.position
        bullseye.rotation = ring.rotation
        gate.add_child(bullseye)
        precision_rings.append(bullseye)

        var beacon := MeshInstance3D.new()
        beacon.name = "Animated hexagonal lane signal"
        beacon.mesh = core_mesh
        beacon.material_override = glowing
        beacon.position = Vector3(lane_x, 4.45, 0.0)
        beacon.rotation.z = PI
        gate.add_child(beacon)
        beacons.append(beacon)

        for side in [-1.0, 1.0]:
            var pylon := MeshInstance3D.new()
            pylon.name = "Sculpted signal pylon"
            var pylon_mesh := CylinderMesh.new()
            pylon_mesh.top_radius = 0.15
            pylon_mesh.bottom_radius = 0.30
            pylon_mesh.height = 2.0
            pylon_mesh.radial_segments = 8
            pylon.mesh = pylon_mesh
            pylon.material_override = steel
            pylon.position = Vector3(lane_x + side * 1.78, 1.0, 0.0)
            gate.add_child(pylon)

        for offset in range(3):
            var guide := MeshInstance3D.new()
            guide.name = "Three-dimensional approach chevron"
            guide.mesh = bar_mesh
            guide.material_override = glowing
            guide.position = Vector3(lane_x, 0.08, -9.0 + float(offset) * 3.0)
            guide.rotation.y = -0.28 if offset % 2 == 0 else 0.28
            gate.add_child(guide)

func reset_course() -> void:
    elapsed = 0.0
    completed_signals = 0
    missed_signals = 0
    streak = 0
    best_streak = 0
    perfect_chain = false
    precision_hits = 0
    precision_mastery = false
    for index in range(gates.size()):
        gates[index].position.z = START_Z - float(index) * SPACING
        gates[index].set_meta("passed", false)
        gates[index].visible = true
    _refresh_gate_guidance()

func _refresh_gate_guidance() -> void:
    # Real 3D arches grow/brighter as a flawless streak builds. The ring
    # materials are unique per gate, so this changes no draw calls or physics.
    for index in range(gates.size()):
        if bool(gates[index].get_meta("passed")):
            continue
        var glow := rings[index].material_override as StandardMaterial3D
        if glow != null:
            glow.emission_energy_multiplier = 2.0 + 0.24 * float(streak)
        rings[index].scale = Vector3.ONE * (1.0 + 0.03 * float(streak))
        precision_rings[index].scale = Vector3.ONE * (1.0 + 0.045 * float(precision_hits))
        var inner_glow := precision_rings[index].material_override as StandardMaterial3D
        if inner_glow != null:
            inner_glow.emission_energy_multiplier = 2.0 + 0.20 * float(precision_hits)

func check_signal(rider_x: float) -> Dictionary:
    if not running:
        return {}
    for gate in gates:
        if bool(gate.get_meta("passed")) or gate.position.z < 0.2:
            continue
        gate.set_meta("passed", true)
        gate.visible = false
        var target_x := float(int(gate.get_meta("lane"))) * LANE_X
        if absf(rider_x - target_x) <= 1.30:
            completed_signals += 1
            streak += 1
            best_streak = maxi(best_streak, streak)
            var overdrive := streak == 3
            perfect_chain = streak == SIGNAL_COUNT
            var precision := absf(rider_x - target_x) <= PRECISION_RADIUS
            if precision:
                precision_hits += 1
            precision_mastery = precision_hits == SIGNAL_COUNT
            _refresh_gate_guidance()
            return {
                "hit": true,
                "precision": precision,
                "precision_count": precision_hits,
                "precision_mastery": precision_mastery,
                "xp": 20 + mini(streak, 4) * 5 + (PRECISION_XP if precision else 0) + (PERFECT_PRECISION_XP if precision_mastery else 0),
                "energy": 12 + (18 if overdrive else 0) + (25 if perfect_chain else 0),
                "overdrive": overdrive,
                "perfect_chain": perfect_chain,
                "turbo_seconds": 3.5 if precision_mastery else (2.5 if perfect_chain else 0.0),
                "streak": streak,
                "count": completed_signals
            }
        missed_signals += 1
        streak = 0
        _refresh_gate_guidance()
        return {"missed": true, "streak": 0}
    return {}

func _process(delta: float) -> void:
    if not running:
        return
    elapsed += delta
    for index in range(gates.size()):
        if bool(gates[index].get_meta("passed")):
            continue
        gates[index].position.z += travel_speed * delta
        beacons[index].position.y = 4.45 + 0.24 * sin(elapsed * 2.3 + float(index))
        beacons[index].rotation.y += delta * 0.85
