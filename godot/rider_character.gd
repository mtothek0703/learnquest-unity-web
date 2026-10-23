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
var balance_arms: Array[Node3D] = []
var balance_legs: Array[Node3D] = []

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
        for i in range(balance_arms.size()):
            var arm := balance_arms[i]
            if is_instance_valid(arm):
                var direction := -1.0 if i == 0 else 1.0
                var balance := clampf(lean * 0.22 * direction, -0.32, 0.32)
                var turbo_pose := -0.20 if boosting else 0.0
                arm.rotation.x = lerpf(arm.rotation.x, turbo_pose + sin(animation_clock * 4.0 + float(i)) * 0.025, minf(1.0, delta * 8.0))
                arm.rotation.z = lerpf(arm.rotation.z, balance, minf(1.0, delta * 8.0))
        for i in range(balance_legs.size()):
            var leg := balance_legs[i]
            if is_instance_valid(leg):
                var direction := -1.0 if i == 0 else 1.0
                var target := direction * lean * 0.11 + (0.12 if boosting else 0.0)
                leg.rotation.x = lerpf(leg.rotation.x, target, minf(1.0, delta * 7.0))
                leg.rotation.z = lerpf(leg.rotation.z, -direction * absf(lean) * 0.10, minf(1.0, delta * 7.0))
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
    _add_balance_arms(model)
    _add_balance_legs(model)
    _add_face_details(model)
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

func _add_balance_arms(model: Node3D) -> void:
    balance_arms.clear()
    var sleeve := StandardMaterial3D.new()
    sleeve.albedo_color = Color(0.35, 0.23, 0.85)
    sleeve.roughness = 0.6
    var glove := StandardMaterial3D.new()
    glove.albedo_color = Color(0.10, 0.14, 0.28)
    glove.roughness = 0.5
    for i in range(2):
        var direction := -1.0 if i == 0 else 1.0
        var pivot := Node3D.new()
        pivot.name = "BalanceArm%d" % i
        pivot.position = Vector3(direction * 0.57, 1.86, -0.01)
        model.add_child(pivot)
        var upper := MeshInstance3D.new()
        var shape := CapsuleMesh.new()
        shape.radius = 0.13
        shape.height = 0.61
        upper.mesh = shape
        upper.material_override = sleeve
        upper.position = Vector3(direction * 0.06, -0.22, 0.0)
        pivot.add_child(upper)
        var hand := MeshInstance3D.new()
        var hand_shape := SphereMesh.new()
        hand_shape.radius = 0.14
        hand_shape.height = 0.23
        hand.mesh = hand_shape
        hand.material_override = glove
        hand.position = Vector3(direction * 0.1, -0.52, -0.05)
        pivot.add_child(hand)
        balance_arms.append(pivot)

func _add_balance_legs(model: Node3D) -> void:
    balance_legs.clear()
    var boots := StandardMaterial3D.new()
    boots.albedo_color = Color(0.09, 0.13, 0.28)
    boots.metallic = 0.20
    boots.roughness = 0.55
    var glow := StandardMaterial3D.new()
    glow.albedo_color = Color(0.11, 0.86, 0.96)
    glow.emission_enabled = true
    glow.emission = Color(0.05, 0.52, 0.7)
    glow.emission_energy_multiplier = 1.5
    for i in range(2):
        var direction := -1.0 if i == 0 else 1.0
        var pivot := Node3D.new()
        pivot.name = "BalanceLeg%d" % i
        pivot.position = Vector3(direction * 0.34, 0.88, 0.0)
        model.add_child(pivot)
        var shin := MeshInstance3D.new()
        var shape := CapsuleMesh.new()
        shape.radius = 0.17
        shape.height = 0.55
        shin.mesh = shape
        shin.material_override = boots
        shin.position = Vector3(0.0, -0.23, 0.02)
        pivot.add_child(shin)
        var light_band := MeshInstance3D.new()
        var band := BoxMesh.new()
        band.size = Vector3(0.30, 0.07, 0.23)
        light_band.mesh = band
        light_band.material_override = glow
        light_band.position = Vector3(0.0, -0.39, 0.18)
        pivot.add_child(light_band)
        balance_legs.append(pivot)

func _add_face_details(model: Node3D) -> void:
    # Visor is on the character's forward (-Z) side.
    var eye_white := StandardMaterial3D.new()
    eye_white.albedo_color = Color(0.98, 0.96, 0.93)
    var pupil := StandardMaterial3D.new()
    pupil.albedo_color = Color(0.04, 0.05, 0.11)
    var eyebrow := StandardMaterial3D.new()
    eyebrow.albedo_color = Color(0.20, 0.10, 0.17)
    var highlight := StandardMaterial3D.new()
    highlight.albedo_color = Color(0.18, 0.92, 0.97)
    highlight.emission_enabled = true
    highlight.emission = Color(0.04, 0.42, 0.54)
    highlight.emission_energy_multiplier = 1.2
    for side in [-1.0, 1.0]:
        var eye := MeshInstance3D.new()
        var eye_mesh := SphereMesh.new()
        eye_mesh.radius = 0.105
        eye_mesh.height = 0.15
        eye.mesh = eye_mesh
        eye.material_override = eye_white
        eye.position = Vector3(side * 0.17, 2.47, -0.402)
        model.add_child(eye)
        var iris := MeshInstance3D.new()
        var iris_mesh := SphereMesh.new()
        iris_mesh.radius = 0.045
        iris_mesh.height = 0.065
        iris.mesh = iris_mesh
        iris.material_override = pupil
        iris.position = Vector3(side * 0.17, 2.47, -0.49)
        model.add_child(iris)
        var brow := MeshInstance3D.new()
        var brow_mesh := BoxMesh.new()
        brow_mesh.size = Vector3(0.19, 0.037, 0.045)
        brow.mesh = brow_mesh
        brow.material_override = eyebrow
        brow.position = Vector3(side * 0.17, 2.60, -0.403)
        model.add_child(brow)
    var smile := MeshInstance3D.new()
    var smile_mesh := BoxMesh.new()
    smile_mesh.size = Vector3(0.19, 0.028, 0.034)
    smile.mesh = smile_mesh
    smile.material_override = eyebrow
    smile.position = Vector3(0.0, 2.23, -0.414)
    model.add_child(smile)
    var headset := MeshInstance3D.new()
    var headset_mesh := BoxMesh.new()
    headset_mesh.size = Vector3(0.12, 0.13, 0.05)
    headset.mesh = headset_mesh
    headset.material_override = highlight
    headset.position = Vector3(0.44, 2.44, 0.0)
    model.add_child(headset)

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
    balance_arms.clear()
    balance_legs.clear()
    var old_body := legacy_rider.get_node_or_null("Animated racer rig")
    if old_body != null:
        old_body.visible = true
