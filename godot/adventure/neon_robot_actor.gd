extends Node3D
## Visible, self-contained Neon City robot. Attach to a walking arena and assign
## player_path to its CharacterBody3D; never runs during the hoverboard race.
signal player_hit
signal robot_defeated

const Combat = preload("res://adventure/robot_combat_state.gd")
@export var player_path: NodePath
@export var enabled := false

var combat = Combat.new()
var player: Node3D
var body_mesh: MeshInstance3D
var warning_ring: MeshInstance3D
var warning_material: StandardMaterial3D

func _ready() -> void:
    if not player_path.is_empty():
        player = get_node_or_null(player_path) as Node3D
    body_mesh = MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.55
    capsule.height = 1.9
    body_mesh.mesh = capsule
    body_mesh.position.y = 1.0
    add_child(body_mesh)
    warning_ring = MeshInstance3D.new()
    var ring := CylinderMesh.new()
    ring.top_radius = 1.4
    ring.bottom_radius = 1.4
    ring.height = 0.08
    warning_ring.mesh = ring
    warning_ring.position.y = 0.07
    warning_material = StandardMaterial3D.new()
    warning_material.albedo_color = Color(1.0, 0.22, 0.1, 0.65)
    warning_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    warning_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    warning_ring.material_override = warning_material
    warning_ring.visible = false
    add_child(warning_ring)
    combat.attack_resolved.connect(_on_attack_resolved)
    combat.robot_defeated.connect(_on_robot_defeated)
    set_physics_process(enabled)

func set_encounter_enabled(value: bool) -> void:
    enabled = value
    set_physics_process(value)
    if not value:
        combat.set_player_distance(-1.0)
        combat.set_guard(false)
        if warning_ring != null:
            warning_ring.visible = false

func _physics_process(delta: float) -> void:
    if not enabled or player == null:
        return
    var distance := global_position.distance_to(player.global_position)
    combat.set_player_distance(distance)
    combat.advance(delta)
    warning_ring.visible = combat.state == "warning"
    if combat.state == "warning":
        warning_material.albedo_color.a = 0.35 + 0.3 * (1.0 - combat.remaining / Combat.WARNING_SECONDS)

func player_attack() -> bool:
    if not enabled or player == null:
        return false
    return combat.player_attack(global_position.distance_to(player.global_position))

func set_player_guard(active: bool) -> void:
    combat.set_guard(enabled and active)

func reset_encounter() -> void:
    combat.reset()
    if warning_ring != null:
        warning_ring.visible = false
    if body_mesh != null:
        body_mesh.visible = true

func _on_attack_resolved(blocked: bool) -> void:
    if not blocked:
        player_hit.emit()

func _on_robot_defeated() -> void:
    warning_ring.visible = false
    body_mesh.visible = false
    robot_defeated.emit()
