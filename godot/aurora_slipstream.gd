extends Node3D
## Aurora Glacier slipstream: four MOVING, then locked, three-lane wind tunnels.
## Catching a stream automatically grants a brief real Turbo burst. The rider
## steers with the existing confirmed touch gestures; no extra collision body,
## mid-race vocabulary question, paid asset or new ability button is introduced.

const STREAM_COUNT := 4
const LANE_X := 3.1
const START_Z := -145.0
const SPACING := 205.0
const LOCK_Z := -22.0

var running := false
var travel_speed := 14.0
var elapsed := 0.0
var caught_streams := 0
var missed_streams := 0
var current_streak := 0
var best_streak := 0
var perfect_line := false
var stations: Array[Node3D] = []
var arches: Array[MeshInstance3D] = []
var cores: Array[MeshInstance3D] = []
var helices: Array[MeshInstance3D] = []

func _material(tint: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.metallic = 0.20
    material.roughness = 0.32
    material.emission_enabled = true
    material.emission = tint
    material.emission_energy_multiplier = 1.8
    return material

func _helix_mesh(phase: float) -> ArrayMesh:
    # Two continuous curved 3D ribbon surfaces spiral through the full
    # tunnel depth. Unlike flat neon hoops, their changing silhouette
    # communicates a moving air current from a chase camera.
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(64):
        var t0 := float(step) / 64.0
        var t1 := float(step + 1) / 64.0
        # Each segment has two triangles between inner and outer spiral
        # radii. Repeated vertices allow stable mobile-compatible normals.
        for corner in [Vector2(t0, 0.0), Vector2(t1, 0.0),
                Vector2(t1, 1.0), Vector2(t0, 0.0),
                Vector2(t1, 1.0), Vector2(t0, 1.0)]:
            var t: float = corner.x
            var angle: float = phase + TAU * 1.65 * t
            var radius: float = lerpf(1.20, 1.34, corner.y)
            var point: Vector3 = Vector3(cos(angle) * radius,
                2.05 + sin(angle) * radius, -4.6 + 9.2 * t)
            tool.set_color(Color("#55dfff").lerp(Color("#f2a8ff"), t))
            tool.add_vertex(point)
    tool.generate_normals()
    return tool.commit()

func _ready() -> void:
    var ring_mesh := TorusMesh.new()
    ring_mesh.inner_radius = 1.45
    ring_mesh.outer_radius = 1.70
    ring_mesh.rings = 36
    ring_mesh.ring_segments = 8
    var core_mesh := SphereMesh.new()
    core_mesh.radial_segments = 16
    core_mesh.rings = 8
    var guide_mesh := BoxMesh.new()
    guide_mesh.size = Vector3(0.15, 0.07, 3.2)
    var cyan := _material(Color("#72ffe4"))
    var violet := _material(Color("#bc9aff"))
    var gold := _material(Color("#fff1ad"))
    var wind_material := _material(Color("#367bb5"))
    wind_material.emission_energy_multiplier = 0.80
    wind_material.vertex_color_use_as_albedo = true
    wind_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    var helix_meshes := [_helix_mesh(0.0), _helix_mesh(PI)]
    for index in range(STREAM_COUNT):
        var station := Node3D.new()
        station.name = "Moving Aurora wind tunnel %d" % index
        station.position = Vector3(float(index % 3 - 1) * LANE_X,
            0.0, START_Z - float(index) * SPACING)
        station.set_meta("passed", false)
        station.set_meta("locked", false)
        add_child(station)
        stations.append(station)
        # Three successive hoops create a readable 3D tunnel, not a flat
        # floating pickup icon. Shared meshes/materials limit WebGL cost.
        for depth in range(3):
            var ring := MeshInstance3D.new()
            ring.name = "Volumetric slipstream hoop %d" % depth
            ring.mesh = ring_mesh
            ring.material_override = cyan if index % 2 == 0 else violet
            ring.position = Vector3(0.0, 2.05, -3.0 + float(depth) * 3.0)
            ring.rotation.x = PI * 0.5
            ring.scale = Vector3.ONE * (1.0 - 0.08 * absf(float(depth - 1)))
            station.add_child(ring)
            if depth == 1:
                arches.append(ring)
        for strand in range(2):
            var spiral := MeshInstance3D.new()
            spiral.name = "Continuous sculpted wind helix %d" % strand
            spiral.mesh = helix_meshes[strand]
            spiral.material_override = wind_material
            station.add_child(spiral)
            helices.append(spiral)
        var core := MeshInstance3D.new()
        core.name = "Pulsating Aurora wind core"
        core.mesh = core_mesh
        core.material_override = gold
        core.position = Vector3(0.0, 2.05, 0.0)
        core.scale = Vector3(0.18, 0.54, 0.18)
        station.add_child(core)
        cores.append(core)
        for side in [-1.0, 1.0]:
            var guide := MeshInstance3D.new()
            guide.name = "Three-dimensional approach wind streak"
            guide.mesh = guide_mesh
            guide.material_override = cyan
            guide.position = Vector3(side * 1.35, 0.08, -9.0)
            station.add_child(guide)

func reset_course() -> void:
    elapsed = 0.0
    caught_streams = 0
    missed_streams = 0
    current_streak = 0
    best_streak = 0
    perfect_line = false
    for index in range(stations.size()):
        var station := stations[index]
        station.position = Vector3(float(index % 3 - 1) * LANE_X,
            0.0, START_Z - float(index) * SPACING)
        station.set_meta("passed", false)
        station.set_meta("locked", false)
        station.visible = true

func check_stream(rider_x: float) -> Dictionary:
    if not running:
        return {}
    for station in stations:
        if bool(station.get_meta("passed")) or station.position.z < 0.2:
            continue
        station.set_meta("passed", true)
        station.visible = false
        if absf(rider_x - station.position.x) <= 1.30:
            caught_streams += 1
            current_streak += 1
            best_streak = maxi(best_streak, current_streak)
            perfect_line = best_streak == STREAM_COUNT
            # Consecutive catches strengthen the existing Turbo, not a fifth ability.
            return {
                "caught": true, "xp": 35 + 10 * (current_streak - 1),
                "energy": 15, "turbo_seconds": 2.5 + 0.5 * (current_streak - 1),
                "count": caught_streams, "streak": current_streak,
                "perfect_line": perfect_line
            }
        missed_streams += 1
        current_streak = 0
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
        # Shift between the existing lanes while distant, then LOCK the
        # destination for the last 22 metres (~1.6 s at normal speed).
        # The rider can read the final lane before making the touch gesture.
        if station.position.z >= LOCK_Z:
            station.set_meta("locked", true)
        if not bool(station.get_meta("locked")):
            var target_lane := (int(floor(elapsed / 2.4)) + index * 2) % 3 - 1
            station.position.x = move_toward(station.position.x,
                float(target_lane) * LANE_X, delta * 5.5)
        cores[index].scale.y = 0.54 * (1.0 + 0.18 * sin(elapsed * 4.0 + float(index)))
        arches[index].rotation.z = 0.12 * sin(elapsed * 1.5 + float(index))
        helices[index * 2].rotation.z += delta * 0.45
        helices[index * 2 + 1].rotation.z -= delta * 0.45
