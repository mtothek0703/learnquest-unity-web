extends Node3D
## Visual model adapter for LearnQuest riders. The working hoverboard, jets,
## trails and gameplay remain in LegacyRider when a new character is installed.
## A CC0 glTF/GLB can be placed at the exported path without rewriting world.gd.
@export_file("*.glb", "*.gltf", "*.tscn") var character_asset_path: String = "res://models/rider.gltf"
@export var model_scale: float = 1.0
@export var model_vertical_offset: float = 0.0

@onready var legacy_rider: Node3D = $LegacyRider
var lean: float = 0.0
var boosting: bool = false
var animation_clock: float = 0.0
var active_model: Node3D
var active_animator: AnimationPlayer
var pose_pivot: Node3D

func _ready() -> void:
    _try_load_character_asset()

func _try_load_character_asset() -> void:
    if not ResourceLoader.exists(character_asset_path):
        return
    var scene := load(character_asset_path) as PackedScene
    if scene == null:
        push_warning("LearnQuest character asset could not be loaded: " + character_asset_path)
        return
    var model := scene.instantiate() as Node3D
    if model != null:
        set_character_model(model)

func _process(delta: float) -> void:
    animation_clock += delta
    if is_instance_valid(legacy_rider):
        legacy_rider.set("lean", lean)
        legacy_rider.set("boosting", boosting)
    if is_instance_valid(active_model):
        # world.gd drives the root's real jump arc. Animate the imported visual
        # separately, preserving the original physics and lane collision logic.
        var airborne := position.y > 0.12
        var desired_roll := -lean * 0.16
        var desired_pitch := 0.10 if airborne else (-0.16 if boosting else 0.0)
        var desired_y := model_vertical_offset + (0.10 if airborne else 0.0)
        var pulse := sin(animation_clock * (13.0 if boosting else 5.0)) * (0.035 if boosting else 0.018)
        active_model.rotation.z = lerpf(active_model.rotation.z, desired_roll, minf(1.0, delta * 6.0))
        active_model.rotation.x = lerpf(active_model.rotation.x, desired_pitch, minf(1.0, delta * 5.0))
        active_model.position.y = lerpf(active_model.position.y, desired_y + pulse, minf(1.0, delta * 7.0))
        if is_instance_valid(pose_pivot):
            pose_pivot.rotation.y = sin(animation_clock * 2.0) * (0.03 if boosting else 0.015)
        if active_animator != null:
            var wanted := "jump" if airborne else ("boost" if boosting else ("steer" if absf(lean) > 0.25 else "idle"))
            if active_animator.has_animation(wanted) and active_animator.current_animation != wanted:
                active_animator.play(wanted, 0.2)

func set_character_model(model: Node3D) -> void:
    if model == null:
        return
    if is_instance_valid(active_model):
        active_model.queue_free()
    active_model = model
    model.name = "ImportedRider"
    add_child(model)
    model.scale = Vector3.ONE * model_scale
    model.position.y = model_vertical_offset
    active_animator = _find_animator(model)
    # A visible breathing and balance motion works even for non-rigged glTF meshes.
    pose_pivot = model
    # Keep the original animated board and lights, hide only its old body.
    var old_body := legacy_rider.get_node_or_null("Animated racer rig")
    if old_body != null:
        old_body.visible = false

func _find_animator(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node as AnimationPlayer
    for child in node.get_children():
        var player := _find_animator(child)
        if player != null:
            return player
    return null

func restore_fallback() -> void:
    if is_instance_valid(active_model):
        active_model.queue_free()
    active_model = null
    active_animator = null
    pose_pivot = null
    var old_body := legacy_rider.get_node_or_null("Animated racer rig")
    if old_body != null:
        old_body.visible = true
