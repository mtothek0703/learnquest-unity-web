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
var scarf_tails: Array[Node3D] = []

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
        for i in range(scarf_tails.size()):
            var tail := scarf_tails[i]
            if is_instance_valid(tail):
                tail.rotation.x = -0.35 + sin(animation_clock * (8.0 if boosting else 4.0) + float(i) * 1.3) * (0.18 if boosting else 0.09)
                tail.rotation.z = sin(animation_clock * 3.0 + float(i)) * 0.1
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
    _add_animated_costume(model)
    # Keep the original animated board and lights, hide only its old body.
    var old_body := legacy_rider.get_node_or_null("Animated racer rig")
    if old_body != null:
        old_body.visible = false

func _add_animated_costume(model: Node3D) -> void:
    scarf_tails.clear()
    # Lightweight costume geometry belongs to the imported character, not the board.
    # Separate pivots give visible cloth motion without a paid skeleton asset.
    var cloth := StandardMaterial3D.new()
    cloth.albedo_color = Color(0.98, 0.24, 0.53)
    cloth.metallic = 0.15
    cloth.roughness = 0.52
    var trim := StandardMaterial3D.new()
    trim.albedo_color = Color(0.15, 0.95, 1.0)
    trim.emission_enabled = true
    trim.emission = Color(0.06, 0.55, 0.7)
    trim.emission_energy_multiplier = 1.8
    for i in range(2):
        var tail := Node3D.new()
        tail.name = "AnimatedScarfTail%d" % i
        tail.position = Vector3(-0.13 if i == 0 else 0.13, 2.1, 0.26)
        model.add_child(tail)
        var ribbon := MeshInstance3D.new()
        var shape := BoxMesh.new()
        shape.size = Vector3(0.16, 0.77, 0.045)
        ribbon.mesh = shape
        ribbon.material_override = cloth
        ribbon.position = Vector3(0.0, -0.37, 0.0)
        tail.add_child(ribbon)
        var stripe := MeshInstance3D.new()
        var accent := BoxMesh.new()
        accent.size = Vector3(0.18, 0.055, 0.054)
        stripe.mesh = accent
        stripe.material_override = trim
        stripe.position = Vector3(0.0, -0.69, 0.0)
        tail.add_child(stripe)
        scarf_tails.append(tail)

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
    scarf_tails.clear()
    var old_body := legacy_rider.get_node_or_null("Animated racer rig")
    if old_body != null:
        old_body.visible = true
