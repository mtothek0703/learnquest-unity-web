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
var aerial_pose: float = 0.0
var active_model: Node3D
var active_animator: AnimationPlayer
var pose_pivot: Node3D
var scarf_tails: Array[Node3D] = []
var balance_arms: Array[Node3D] = []
var balance_legs: Array[Node3D] = []
var hair_strands: Array[Node3D] = []

func _ready() -> void:
    _try_load_character_asset()
    # Aerial windstreams and landing shards animate independently of the model.
    var aerial := preload("res://rider_aerial_choreography.gd").new() as Node3D
    aerial.name = "Cinematic aerial choreography"
    add_child(aerial)

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
        # Blend the imported model into an actual airborne pose: arms open,
        # knees tuck and the torso pitches forward, without changing physics.
        aerial_pose = lerpf(aerial_pose, clampf(position.y / 1.25, 0.0, 1.0), minf(1.0, delta * 7.0))
        var desired_roll := -lean * 0.16
        var desired_pitch := (0.10 + aerial_pose * 0.24) if airborne else (-0.16 if boosting else 0.0)
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
                arm.rotation.x = lerpf(arm.rotation.x, turbo_pose + aerial_pose * 0.48 + sin(animation_clock * 4.0 + float(i)) * 0.025, minf(1.0, delta * 8.0))
                arm.rotation.z = lerpf(arm.rotation.z, balance + direction * aerial_pose * 0.43, minf(1.0, delta * 8.0))
        for i in range(balance_legs.size()):
            var leg := balance_legs[i]
            if is_instance_valid(leg):
                var direction := -1.0 if i == 0 else 1.0
                var target := direction * lean * 0.11 + (0.12 if boosting else 0.0) + aerial_pose * 0.42
                leg.rotation.x = lerpf(leg.rotation.x, target, minf(1.0, delta * 7.0))
                leg.rotation.z = lerpf(leg.rotation.z, -direction * absf(lean) * 0.10 + direction * aerial_pose * 0.15, minf(1.0, delta * 7.0))
        # Soft wind response on the stylized ponytail. Stay in sync with steering
        # and turbo without depending on a skeletal animation asset.
        for i in range(hair_strands.size()):
            var strand := hair_strands[i]
            if is_instance_valid(strand):
                var wind := 0.18 if boosting else 0.06
                strand.rotation.x = lerpf(strand.rotation.x, -0.28 - wind + sin(animation_clock * 5.0 + float(i) * 0.8) * 0.08, minf(1.0, delta * 5.0))
                strand.rotation.z = lerpf(strand.rotation.z, -lean * 0.12 + sin(animation_clock * 3.0 + float(i) * 1.2) * 0.08, minf(1.0, delta * 6.0))
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
    # V97: GPU-skin the ORIGINAL glTF body (not just decorative armor).
    # Install before costume generation so the imported mesh alone is weighted.
    var body_skin := preload("res://rider_original_body_skin.gd").new() as Node3D
    body_skin.name = "OriginalBodySkinRig"
    model.add_child(body_skin)
    body_skin.call("bind_original", model)
    # V99: a sculpted flight-suit shell, sleeves and leg guards are GPU-skinned
    # by the SAME original body skeleton, without altering touch or physics.
    var sculpted_suit := preload("res://rider_sculpted_skinned_suit.gd").new() as Node3D
    sculpted_suit.name = "SculptedSkinnedFlightSuit"
    model.add_child(sculpted_suit)
    # A visible breathing and balance motion works even for non-rigged glTF meshes.
    pose_pivot = model
    _add_animated_costume(model)
    _add_balance_arms(model)
    _add_balance_legs(model)
    # Original animated facial rig replaces the old box-shaped smile and brows.
    var face := preload("res://rider_face.gd").new() as Node3D
    face.name = "ExpressiveFace"
    model.add_child(face)
    _add_hairstyle(model)
    # V35 volumetric hair shell and sculpted wind-reactive curls, layered
    # behind the established braid without replacing its working animation.
    var volume := preload("res://rider_hair_volume.gd").new() as Node3D
    volume.name = "SculptedVolumetricHair"
    model.add_child(volume)
    # V39: four large, two-joint wind-reactive locks frame the original braid.
    var cascade := preload("res://rider_hair_cascade.gd").new() as Node3D
    cascade.name = "AnimatedWindHairCascade"
    model.add_child(cascade)
    var braid := preload("res://rider_braid.gd").new() as Node3D
    braid.name = "AnimatedBraidedPonytail"
    model.add_child(braid)
    # V93: synchronized head, face and hair with a shaded cinematic helmet.
    var head_rig := preload("res://rider_head_kinematics.gd").new() as Node3D
    head_rig.name = "AnimatedHeadKinematics"
    model.add_child(head_rig)
    _add_sculpted_jacket(model)
    # V38: shaped front jacket, layered chest armor and animated breathing.
    var torso := preload("res://rider_torso_detail.gd").new() as Node3D
    torso.name = "AnimatedTailoredFlightJacket"
    model.add_child(torso)
    # V94: a real five-bone Skeleton3D moves shaded exosuit armor and
    # shoulder aero-blades, without skinning or replacing the imported hero.
    var exosuit := preload("res://rider_skeletal_exosuit.gd").new() as Node3D
    exosuit.name = "AnimatedSkeletalExosuit"
    model.add_child(exosuit)
    var coat := preload("res://rider_coat.gd").new() as Node3D
    coat.name = "AnimatedSculptedCoat"
    model.add_child(coat)
    # Sculpted articulated aerofoils stay outside the coat and preserve the face.
    var wings := preload("res://rider_wings.gd").new() as Node3D
    wings.name = "AnimatedAeroWings"
    model.add_child(wings)
    # V84: six articulated translucent energy sails frame the rider in landscape.
    var kinetic_sails := preload("res://rider_kinetic_sails.gd").new() as Node3D
    kinetic_sails.name = "AnimatedKineticSails"
    model.add_child(kinetic_sails)
    # V90: three articulated cloth joints on each side form a shaded flight cloak.
    # Visual-only: the working touch controls, hoverboard and collisions stay intact.
    var motion_cloak := preload("res://rider_motion_cloak.gd").new() as Node3D
    motion_cloak.name = "AnimatedMotionCloak"
    model.add_child(motion_cloak)
    # V36: large curved back armor, rotating energy reactor and articulated jets.
    var harness := preload("res://rider_aero_harness.gd").new() as Node3D
    harness.name = "AnimatedAeroHarness"
    model.add_child(harness)
    # V98: match the jacket, coat, exosuit and aero gear to the same V97
    # skinned-body chest/hips pose. Preserve each accessory's own animation.
    var costume_follow := preload("res://rider_costume_skin_follow.gd").new() as Node3D
    costume_follow.name = "SkinnedCostumePoseFollower"
    model.add_child(costume_follow)
    # V100: V99's new skinned shell was buried under two older, rigid back
    # plates. Retire ONLY the occluding visual meshes when skinning succeeded.
    # The reactor, animated coat, footwear, touch and physics remain intact.
    _retire_occluding_legacy_shells(model, sculpted_suit, harness)
    # Keep the original animated board and lights, hide only its old body.
    var old_body := legacy_rider.get_node_or_null("Animated racer rig")
    if old_body != null:
        old_body.visible = false

func _retire_occluding_legacy_shells(model: Node3D, suit: Node3D, harness: Node3D) -> void:
    # The fallback path must remain intact for placeholder/non-skinned models.
    var parts: Array = suit.get("suit_parts")
    if parts.size() != 5:
        return
    var old_jacket := model.get_node_or_null("SculptedJacketBack") as MeshInstance3D
    var old_emblem := model.get_node_or_null("NeonJacketEmblem") as MeshInstance3D
    var old_harness_plate := harness.get_node_or_null("CurvedAeroBackplate") as MeshInstance3D
    for shell in [old_jacket, old_emblem, old_harness_plate]:
        if shell != null:
            shell.visible = false
    # The old cylindrical shins and boxy ankle bands overlap the skinned
    # leg guards; keep the sculpted hover boots and animated knee joints.
    for leg in balance_legs:
        for name in ["LegacyShin", "LegacyAnkleBand"]:
            var old_part := leg.get_node_or_null(name) as MeshInstance3D
            if old_part != null:
                old_part.visible = false

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
    cloth.cull_mode = BaseMaterial3D.CULL_DISABLED
    trim.cull_mode = BaseMaterial3D.CULL_DISABLED
    for i in range(2):
        var tail := Node3D.new()
        tail.name = "AnimatedScarfTail%d" % i
        # The flowing cloth clears the sculpted jacket and is visible from behind.
        tail.position = Vector3(-0.15 if i == 0 else 0.15, 2.13, 0.79)
        model.add_child(tail)
        var ribbon := MeshInstance3D.new()
        ribbon.name = "FlowingCloth"
        ribbon.mesh = _build_wind_scarf_mesh(0.93, 0.29, 0.0, 1.0)
        ribbon.material_override = cloth
        tail.add_child(ribbon)
        var stripe := MeshInstance3D.new()
        stripe.name = "NeonHem"
        stripe.mesh = _build_wind_scarf_mesh(0.93, 0.29, 0.86, 0.96)
        stripe.material_override = trim
        stripe.position.z = 0.012
        tail.add_child(stripe)
        scarf_tails.append(tail)

func _build_wind_scarf_mesh(length: float, width: float, from_t: float, to_t: float) -> ArrayMesh:
    # Original lightweight curved cloth, not a box. Shared parametric surface
    # lets the luminous hem follow the same silhouette as the animated fabric.
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 12
    const COLUMNS := 4
    for row in range(ROWS):
        var t0 := lerpf(from_t, to_t, float(row) / float(ROWS))
        var t1 := lerpf(from_t, to_t, float(row + 1) / float(ROWS))
        for column in range(COLUMNS):
            var u0 := float(column) / float(COLUMNS)
            var u1 := float(column + 1) / float(COLUMNS)
            var p00 := _scarf_surface_point(t0, u0, length, width)
            var p01 := _scarf_surface_point(t0, u1, length, width)
            var p10 := _scarf_surface_point(t1, u0, length, width)
            var p11 := _scarf_surface_point(t1, u1, length, width)
            surface.add_vertex(p00)
            surface.add_vertex(p10)
            surface.add_vertex(p11)
            surface.add_vertex(p00)
            surface.add_vertex(p11)
            surface.add_vertex(p01)
    surface.generate_normals()
    return surface.commit()

func _scarf_surface_point(t: float, u: float, length: float, width: float) -> Vector3:
    var across := u * 2.0 - 1.0
    var taper := 1.0 - 0.42 * t
    var flutter := sin(t * PI) * 0.065 * sin(across * PI)
    return Vector3(
        across * width * taper * 0.5 + sin(t * PI) * 0.085,
        -length * t,
        0.05 + 0.28 * t * t + flutter + 0.025 * across * across
    )

func _add_balance_arms(model: Node3D) -> void:
    balance_arms.clear()
    var sleeve := StandardMaterial3D.new()
    sleeve.albedo_color = Color(0.35, 0.23, 0.85)
    sleeve.roughness = 0.6
    var glove := StandardMaterial3D.new()
    glove.albedo_color = Color(0.10, 0.14, 0.28)
    glove.roughness = 0.5
    # Original curved shoulder armor adds a readable, layered silhouette from
    # the chase camera without a heavy skeletal mesh or licensed texture.
    var armor := StandardMaterial3D.new()
    armor.albedo_color = Color(0.12, 0.15, 0.38)
    armor.metallic = 0.46
    armor.roughness = 0.34
    armor.cull_mode = BaseMaterial3D.CULL_DISABLED
    var piping := StandardMaterial3D.new()
    piping.albedo_color = Color(0.12, 0.92, 1.0)
    piping.emission_enabled = true
    piping.emission = Color(0.04, 0.58, 0.83)
    piping.emission_energy_multiplier = 2.0
    piping.cull_mode = BaseMaterial3D.CULL_DISABLED
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
        var shoulder := MeshInstance3D.new()
        shoulder.name = "SculptedShoulderGuard"
        shoulder.mesh = _build_shoulder_guard_mesh(direction)
        shoulder.material_override = armor
        pivot.add_child(shoulder)
        var trim := MeshInstance3D.new()
        trim.name = "ShoulderNeonTrim"
        trim.mesh = _build_shoulder_trim_mesh(direction)
        trim.material_override = piping
        pivot.add_child(trim)
        # V37: sculpted gauntlet and articulated fingers follow each arm.
        var gauntlet := preload("res://rider_gauntlets.gd").new() as Node3D
        gauntlet.name = "SculptedRiderGauntlet"
        gauntlet.set("side_sign", direction)
        gauntlet.position = Vector3(direction * 0.10, -0.31, 0.0)
        pivot.add_child(gauntlet)
        # V91: a second, independent elbow joint bends the sculpted gauntlet
        # during Turbo, turns and jumps; the shoulder remains the first joint.
        var elbow := preload("res://rider_elbow_kinematics.gd").new() as Node3D
        elbow.name = "AnimatedElbowKinematics"
        elbow.set("side_sign", direction)
        pivot.add_child(elbow)
        balance_arms.append(pivot)

func _shoulder_surface_point(u: float, v: float, direction: float) -> Vector3:
    # A curved armor shell: taper toward the elbow and bulge toward the camera.
    # Positive Z is the rider's back, where the third-person camera sees it.
    var across := u * 2.0 - 1.0
    var dome := sqrt(maxf(0.0, 1.0 - across * across))
    return Vector3(
        direction * 0.055 + across * (0.30 - 0.08 * v),
        0.18 - 0.36 * v,
        0.045 + dome * (0.22 - 0.035 * v) + sin(v * PI) * 0.03
    )

func _build_shoulder_guard_mesh(direction: float) -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS := 9
    const COLUMNS := 14
    for row in range(ROWS):
        var v0 := float(row) / float(ROWS)
        var v1 := float(row + 1) / float(ROWS)
        for column in range(COLUMNS):
            var u0 := float(column) / float(COLUMNS)
            var u1 := float(column + 1) / float(COLUMNS)
            var p00 := _shoulder_surface_point(u0, v0, direction)
            var p01 := _shoulder_surface_point(u1, v0, direction)
            var p10 := _shoulder_surface_point(u0, v1, direction)
            var p11 := _shoulder_surface_point(u1, v1, direction)
            surface.add_vertex(p00)
            surface.add_vertex(p10)
            surface.add_vertex(p11)
            surface.add_vertex(p00)
            surface.add_vertex(p11)
            surface.add_vertex(p01)
    surface.generate_normals()
    return surface.commit()

func _build_shoulder_trim_mesh(direction: float) -> ArrayMesh:
    # Two thin curved neon seams follow the shell, not straight box edges.
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SEGMENTS := 14
    for band in [0.10, 0.78]:
        for column in range(SEGMENTS):
            var u0 := float(column) / float(SEGMENTS)
            var u1 := float(column + 1) / float(SEGMENTS)
            var p00 := _shoulder_surface_point(u0, band, direction) + Vector3(0.0, 0.0, 0.008)
            var p01 := _shoulder_surface_point(u1, band, direction) + Vector3(0.0, 0.0, 0.008)
            var p10 := _shoulder_surface_point(u0, band + 0.045, direction) + Vector3(0.0, 0.0, 0.008)
            var p11 := _shoulder_surface_point(u1, band + 0.045, direction) + Vector3(0.0, 0.0, 0.008)
            surface.add_vertex(p00)
            surface.add_vertex(p10)
            surface.add_vertex(p11)
            surface.add_vertex(p00)
            surface.add_vertex(p11)
            surface.add_vertex(p01)
    surface.generate_normals()
    return surface.commit()

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
        shin.name = "LegacyShin"
        shin.mesh = shape
        shin.material_override = boots
        shin.position = Vector3(0.0, -0.23, 0.02)
        pivot.add_child(shin)
        var light_band := MeshInstance3D.new()
        var band := BoxMesh.new()
        band.size = Vector3(0.30, 0.07, 0.23)
        light_band.name = "LegacyAnkleBand"
        light_band.mesh = band
        light_band.material_override = glow
        light_band.position = Vector3(0.0, -0.39, 0.18)
        pivot.add_child(light_band)
        # Original sculpted footwear is attached to each animated leg pivot.
        var footwear := preload("res://rider_footwear.gd").new() as Node3D
        footwear.name = "SculptedHoverBoot"
        footwear.position = Vector3(0.0, -0.49, -0.08)
        pivot.add_child(footwear)
        # Tailored mesh-built trousers and knee guards follow each steering leg.
        var leg_armor := preload("res://rider_leg_armor.gd").new() as Node3D
        leg_armor.name = "SculptedRiderLeg"
        pivot.add_child(leg_armor)
        # V92: the existing boot and shin now follow a second, articulated
        # knee joint, with shaded geometry and luminous moving knee rings.
        var knee := preload("res://rider_knee_kinematics.gd").new() as Node3D
        knee.name = "AnimatedKneeKinematics"
        knee.set("side_sign", direction)
        pivot.add_child(knee)
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

func _add_hairstyle(model: Node3D) -> void:
    # Clearly readable from the chase camera: swept-back hair crest and
    # three separately animated locks. No external downloads or textures.
    hair_strands.clear()
    var hair := StandardMaterial3D.new()
    hair.albedo_color = Color(0.11, 0.08, 0.27)
    hair.metallic = 0.10
    hair.roughness = 0.58
    var highlight := StandardMaterial3D.new()
    highlight.albedo_color = Color(0.69, 0.23, 0.83)
    highlight.metallic = 0.15
    highlight.roughness = 0.48
    var neon := StandardMaterial3D.new()
    neon.albedo_color = Color(0.12, 0.89, 0.94)
    neon.emission_enabled = true
    neon.emission = Color(0.04, 0.49, 0.62)
    neon.emission_energy_multiplier = 1.2
    var hairstyle := Node3D.new()
    hairstyle.name = "RiderHair"
    model.add_child(hairstyle)
    # The glTF model's head is around Y=2.4; +Z is visible from behind.
    for index in range(5):
        var side := float(index - 2)
        var tuft := MeshInstance3D.new()
        tuft.name = "SweptHair%d" % index
        # Individually sculpted swept locks replace the spherical hair cap.
        tuft.mesh = _build_tapered_hair_mesh(0.55, 0.15, 0.25)
        tuft.material_override = highlight if index == 2 else hair
        tuft.position = Vector3(side * 0.17, 3.05 - absf(side) * 0.045, 0.28)
        tuft.rotation.x = -0.48
        tuft.rotation.z = side * -0.17
        hairstyle.add_child(tuft)
    for i in range(3):
        var pivot := Node3D.new()
        pivot.name = "WindHair%d" % i
        pivot.position = Vector3(float(i - 1) * 0.18, 2.71, 0.48)
        hairstyle.add_child(pivot)
        var lock := MeshInstance3D.new()
        lock.name = "HairLock"
        # Sculpted, tapered 3D strands replace the old ellipsoid ponytail.
        # Each lock keeps its own wind-reactive pivot and neon hair clip.
        lock.mesh = _build_tapered_hair_mesh(0.72 if i == 1 else 0.55, 0.17 if i == 1 else 0.12, 0.22)
        lock.material_override = highlight if i == 1 else hair
        lock.position = Vector3(0.0, -0.06, 0.12)
        lock.rotation.x = 0.18
        pivot.add_child(lock)
        var clip := MeshInstance3D.new()
        clip.name = "NeonHairClip"
        var clip_mesh := BoxMesh.new()
        clip_mesh.size = Vector3(0.20, 0.08, 0.09)
        clip.mesh = clip_mesh
        clip.material_override = neon
        clip.position = Vector3(0.0, -0.07, 0.11)
        pivot.add_child(clip)
        hair_strands.append(pivot)


func _build_tapered_hair_mesh(length: float, width: float, sweep: float) -> ArrayMesh:
    # Smooth, swept 3D hair mesh with an actual taper, rather than sphere parts.
    # Sixteen sides would be wasteful in Safari; eight keep the silhouette crisp.
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SIDES := 8
    const SECTIONS := 8
    for section in range(SECTIONS):
        var t0 := float(section) / float(SECTIONS)
        var t1 := float(section + 1) / float(SECTIONS)
        for side in range(SIDES):
            var a0 := TAU * float(side) / float(SIDES)
            var a1 := TAU * float(side + 1) / float(SIDES)
            var p00 := _hair_mesh_point(t0, a0, length, width, sweep)
            var p01 := _hair_mesh_point(t0, a1, length, width, sweep)
            var p10 := _hair_mesh_point(t1, a0, length, width, sweep)
            var p11 := _hair_mesh_point(t1, a1, length, width, sweep)
            surface.add_vertex(p00)
            surface.add_vertex(p10)
            surface.add_vertex(p11)
            surface.add_vertex(p00)
            surface.add_vertex(p11)
            surface.add_vertex(p01)
    surface.generate_normals()
    return surface.commit()

func _hair_mesh_point(t: float, angle: float, length: float, width: float, sweep: float) -> Vector3:
    var taper := pow(1.0 - t, 0.72)
    var radius := width * (0.10 + 0.90 * taper)
    return Vector3(
        cos(angle) * radius + sin(t * PI) * 0.045,
        -length * t,
        sweep * t * t + sin(t * PI) * 0.09 + sin(angle) * radius * 0.78
    )

func _add_sculpted_jacket(model: Node3D) -> void:
    # A shaped back shell and glowing chevron read clearly from the chase camera.
    # Geometry is original and generated in-engine: no paid or unlicensed assets.
    var jacket := MeshInstance3D.new()
    jacket.name = "SculptedJacketBack"
    jacket.mesh = _build_jacket_back_mesh()
    var fabric := StandardMaterial3D.new()
    fabric.albedo_color = Color(0.28, 0.16, 0.69)
    fabric.metallic = 0.16
    fabric.roughness = 0.49
    fabric.cull_mode = BaseMaterial3D.CULL_DISABLED
    jacket.material_override = fabric
    model.add_child(jacket)

    var emblem := MeshInstance3D.new()
    emblem.name = "NeonJacketEmblem"
    var lines := SurfaceTool.new()
    lines.begin(Mesh.PRIMITIVE_TRIANGLES)
    _add_jacket_ribbon(lines, Vector3(-0.27, 1.83, 0.79), Vector3(0.0, 1.46, 0.87), 0.07)
    _add_jacket_ribbon(lines, Vector3(0.27, 1.83, 0.79), Vector3(0.0, 1.46, 0.87), 0.07)
    lines.generate_normals()
    emblem.mesh = lines.commit()
    var glow := StandardMaterial3D.new()
    glow.albedo_color = Color(0.12, 0.94, 1.0)
    glow.emission_enabled = true
    glow.emission = Color(0.04, 0.62, 0.83)
    glow.emission_energy_multiplier = 2.1
    glow.cull_mode = BaseMaterial3D.CULL_DISABLED
    emblem.material_override = glow
    model.add_child(emblem)

func _build_jacket_back_mesh() -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    const COLUMNS := 12
    const ROWS := 7
    for row in range(ROWS):
        var v0 := float(row) / float(ROWS)
        var v1 := float(row + 1) / float(ROWS)
        for column in range(COLUMNS):
            var u0 := float(column) / float(COLUMNS)
            var u1 := float(column + 1) / float(COLUMNS)
            var p00 := _jacket_back_point(u0, v0)
            var p01 := _jacket_back_point(u1, v0)
            var p10 := _jacket_back_point(u0, v1)
            var p11 := _jacket_back_point(u1, v1)
            surface.add_vertex(p00)
            surface.add_vertex(p01)
            surface.add_vertex(p11)
            surface.add_vertex(p00)
            surface.add_vertex(p11)
            surface.add_vertex(p10)
    surface.generate_normals()
    return surface.commit()

func _jacket_back_point(u: float, v: float) -> Vector3:
    var centered := u * 2.0 - 1.0
    var width := lerpf(0.38, 0.53, v)
    var depth := 0.58 + (1.0 - centered * centered) * 0.17 + sin(v * PI) * 0.03
    return Vector3(centered * width, 1.12 + v * 1.04, depth)

func _add_jacket_ribbon(surface: SurfaceTool, start: Vector3, finish: Vector3, width: float) -> void:
    var direction := (finish - start).normalized()
    var perpendicular := Vector3(-direction.y, direction.x, 0.0).normalized() * width * 0.5
    surface.add_vertex(start - perpendicular)
    surface.add_vertex(finish - perpendicular)
    surface.add_vertex(finish + perpendicular)
    surface.add_vertex(start - perpendicular)
    surface.add_vertex(finish + perpendicular)
    surface.add_vertex(start + perpendicular)

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
    hair_strands.clear()
    aerial_pose = 0.0
    var old_body := legacy_rider.get_node_or_null("Animated racer rig")
    if old_body != null:
        old_body.visible = true
