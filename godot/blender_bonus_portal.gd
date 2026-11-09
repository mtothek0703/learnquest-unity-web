extends Node3D
# Original Blender GLB: real race pickup, no added physics collider or save keys.
signal entered

const PORTAL_SCENE: PackedScene = preload("res://assets/3d/learnquest_portal.glb")
const START_Z := -65.0
const PICKUP_HALF_WIDTH := 1.25

var runner: Node3D
var running := false
var travel_speed := 14.0
var passed := false
var portal_model: Node3D

func _ready() -> void:
    portal_model = PORTAL_SCENE.instantiate() as Node3D
    portal_model.name = "Actual Blender 3D Portal"
    add_child(portal_model)
    # The player fills the center of the phone chase camera. Mark the lane
    # ABOVE the imported Blender artwork so its destination remains visible.
    # Purely visual: no extra collision shape, reward or save-state change.
    var cue_material := StandardMaterial3D.new()
    cue_material.albedo_color = Color("#8af9ff")
    cue_material.emission_enabled = true
    cue_material.emission = Color("#45edff")
    cue_material.emission_energy_multiplier = 2.1
    cue_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    var cue_ring := TorusMesh.new()
    cue_ring.inner_radius = 0.55
    cue_ring.outer_radius = 0.78
    cue_ring.rings = 24
    cue_ring.ring_segments = 8
    var marker := MeshInstance3D.new()
    marker.name = "Center lane portal beacon above rider"
    marker.mesh = cue_ring
    marker.material_override = cue_material
    marker.rotation.x = PI / 2.0
    marker.position = Vector3(0.0, 6.8, 0.0)
    marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(marker)
    var cue_core := SphereMesh.new()
    cue_core.radius = 0.29
    cue_core.height = 0.58
    var core_marker := MeshInstance3D.new()
    core_marker.name = "Portal beacon core"
    core_marker.mesh = cue_core
    core_marker.material_override = cue_material
    core_marker.position = Vector3(0.0, 6.8, 0.0)
    core_marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(core_marker)
    reset_for_world(0)

func reset_for_world(world_index: int) -> void:
    position = Vector3(0.0, 0.0, START_Z)
    rotation = Vector3.ZERO
    passed = false
    running = false
    visible = world_index == 0

func advance(delta: float) -> void:
    if not running or not visible or runner == null:
        return
    if not is_finite(delta) or delta <= 0.0 or not is_finite(travel_speed) or travel_speed <= 0.0:
        return
    var old_z := position.z
    position.z += travel_speed * delta
    if not passed and old_z < runner.position.z and position.z >= runner.position.z:
        passed = true
        if absf(runner.position.x - position.x) <= PICKUP_HALF_WIDTH:
            entered.emit()
    if position.z > runner.position.z + 5.0:
        visible = false

func _process(delta: float) -> void:
    advance(delta)
