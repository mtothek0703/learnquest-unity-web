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
# Blender GLB's imported AnimationPlayer drives actual keyframed orbit shards.
var energy_animator: AnimationPlayer

func _ready() -> void:
    portal_model = PORTAL_SCENE.instantiate() as Node3D
    portal_model.name = "Actual Blender 3D Portal"
    add_child(portal_model)
    _init_blender_animation()
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
    cue_ring.inner_radius = 0.76
    cue_ring.outer_radius = 1.08
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
    # Actual 1280x720 / 1170x540 Godot race captures show that the chase
    # rider hides the portal's center. Two small side beacons remain visible
    # outside that silhouette without moving the pickup or changing its hitbox.
    # These are intentionally unlit, low-poly meshes for mobile Compatibility.
    for side in [-1.0, 1.0]:
        var side_marker := MeshInstance3D.new()
        side_marker.name = "Portal side visibility beacon"
        var side_mesh := CylinderMesh.new()
        side_mesh.top_radius = 0.10
        side_mesh.bottom_radius = 0.18
        side_mesh.height = 2.6
        side_mesh.radial_segments = 8
        side_marker.mesh = side_mesh
        side_marker.position = Vector3(side * 2.2, 2.2, 0.0)
        side_marker.material_override = cue_material
        side_marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        add_child(side_marker)
    reset_for_world(0)

# Play animation tracks exported by Blender; never substitute a fake rotating
# ring when the imported model is static. Old saved runs stay unaffected.
func _init_blender_animation() -> void:
    for node in portal_model.find_children("*", "AnimationPlayer", true, false):
        if node is AnimationPlayer:
            var animator := node as AnimationPlayer
            for name in animator.get_animation_list():
                if name == "RESET":
                    continue
                var clip := animator.get_animation(name)
                if clip == null:
                    continue
                clip.loop_mode = Animation.LOOP_LINEAR
                energy_animator = animator
                energy_animator.play(name)
                energy_animator.speed_scale = 0.0
                return

func reset_for_world(world_index: int) -> void:
    position = Vector3(0.0, 0.0, START_Z)
    rotation = Vector3.ZERO
    passed = false
    running = false
    visible = world_index == 0
    if energy_animator != null:
        energy_animator.speed_scale = 0.0
        energy_animator.seek(0.0, true)

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
    # Both race travel and the Blender-authored animation freeze during
    # mandatory vocabulary, menus, pause and hidden Safari tabs.
    if energy_animator != null:
        energy_animator.speed_scale = 1.0 if running and visible else 0.0
    advance(delta)
