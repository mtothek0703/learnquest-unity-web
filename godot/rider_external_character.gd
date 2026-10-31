extends Node
## V124: genuine imported 65-joint skinned CC0 humanoid, not a primitive rig.
## This adapter only changes imported bone rotations; gameplay, board and touch
## remain entirely owned by RiderCharacter/LegacyRider and world.gd.
var rider: Node3D
var character: Node3D
var skeleton: Skeleton3D
var skinned_meshes: Array[MeshInstance3D] = []
var rest_rotations: Dictionary = {}
var elapsed: float = 0.0
var previous_height: float = 0.0
var last_jump: float = 0.0
# Impact compression is visual only: it never changes the collision body.
var landing_impact: float = 0.0
var vertical_speed: float = 0.0
var facial_acting: Node
var flight_mantle: Node
var hair_dynamics: Node
var skinned_hair_motion: Node
# Runtime-only visual contact: the board bobs after the initial fitting pass.
# Keep the real skinned soles at the deck without touching gameplay physics.
var board_contact_offset: float = 0.0
var board_contact_active: bool = false
# A single coordinated action-light pass across original skinned body, jacket,
# boots, trousers and shoulders; no new render passes or collision nodes.
var action_materials: Array[ShaderMaterial] = []
var action_charge: float = 0.0
# A time-based torso follow-through creates readable opposing shoulder/head
# motion without altering the original 65-bone Skin or gameplay steering.
var torso_follow: float = 0.0

func configure(owner_rider: Node3D, imported: Node3D) -> bool:
    rider = owner_rider
    character = imported
    if character == null:
        return false
    var skeletons := character.find_children("*", "Skeleton3D", true, false)
    for candidate in skeletons:
        var candidate_rig := candidate as Skeleton3D
        if candidate_rig == null or candidate_rig.get_bone_count() < 50:
            continue
        var attached: Array[MeshInstance3D] = []
        for node in character.find_children("*", "MeshInstance3D", true, false):
            var mesh := node as MeshInstance3D
            if mesh == null or mesh.mesh == null or mesh.skin == null:
                continue
            if mesh.get_node_or_null(mesh.skeleton) != candidate_rig:
                continue
            var has_weights := false
            for surface_index in range(mesh.mesh.get_surface_count()):
                var arrays: Array = mesh.mesh.surface_get_arrays(surface_index)
                var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
                var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
                var indices: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
                if points.size() >= 50 and weights.size() >= points.size() * 4 and indices.size() >= points.size() * 4:
                    has_weights = true
                    break
            if has_weights:
                attached.append(mesh)
        if not attached.is_empty():
            skeleton = candidate_rig
            skinned_meshes = attached
            break
    if skeleton == null:
        return false
    for name in ["pelvis", "spine_01", "Head"]:
        if skeleton.find_bone(name) < 0:
            return false
    for i in range(skeleton.get_bone_count()):
        rest_rotations[i] = skeleton.get_bone_pose_rotation(i)
    # First reshape the ACTUAL four-weight imported body mesh, so every
    # downstream jacket/leg/shoulder panel is sampled from the same coherent
    # anatomical silhouette. This is a runtime mesh copy: the CC0 GLB and
    # its 65-bone Skeleton3D / Skin inverse binds are never edited.
    var body_sculpt := preload("res://rider_external_body_resculpt.gd").new() as Node
    body_sculpt.name = "ExternalContinuousBodySculpt"
    character.add_child(body_sculpt)
    if not bool(body_sculpt.call("install", skinned_meshes)):
        body_sculpt.queue_free()
        push_warning("CC0 continuous body sculpt unavailable; original weighted body preserved")
    # Recolor the EXISTING skinned body, not an unrigged duplicate shell.
    # Lightweight procedural materials preserve original mesh + skin data.
    var suit_shader := load("res://rider_quaternius_suit.gdshader") as Shader
    if suit_shader != null:
        for mesh in skinned_meshes:
            if String(mesh.name).contains("SuperHero"):
                var suit := ShaderMaterial.new()
                suit.shader = suit_shader
                var source_bounds := mesh.mesh.get_aabb()
                suit.set_shader_parameter("rest_bottom", source_bounds.position.y)
                suit.set_shader_parameter("rest_height", source_bounds.size.y)
                suit.set_shader_parameter("rest_center_x", source_bounds.get_center().x)
                suit.set_shader_parameter("rest_width", source_bounds.size.x)
                mesh.material_override = suit
            elif String(mesh.name).to_lower().contains("eyebrow"):
                var brow := StandardMaterial3D.new()
                brow.albedo_color = Color(0.085, 0.07, 0.18)
                brow.roughness = 0.7
                mesh.material_override = brow
            elif String(mesh.name).to_lower().contains("eyes"):
                var eyes := StandardMaterial3D.new()
                eyes.albedo_color = Color(0.92, 0.96, 1.0)
                eyes.roughness = 0.3
                mesh.material_override = eyes
    # The helmet/hair are attached to the ORIGINAL imported Head bone, with
    # dimensions sampled from head-weighted vertices; the skinned face stays.
    var headgear := preload("res://rider_external_headgear.gd").new() as BoneAttachment3D
    if bool(headgear.call("install", skeleton, skinned_meshes)):
        # Match the expressive V123 mobile head-to-body ratio without scaling
        # the original 65-bone GLB or its GPU skin. Rear drape is shortened
        # in Head-local space to protect the shoulders during lean/jump.
        # V124 unified silhouette trial: reduce the oversized floating-head
        # look while retaining readable eyes in landscape. Original imported
        # head, 65 bones and inverse bind matrices remain unchanged.
        # Keep the readable mobile face while reducing the oversized
        # head/helmet/hair silhouette relative to the skinned torso.
        # All generated Head-local meshes scale around their sampled center;
        # the imported 65-bone Skin and board contact stay unchanged.
        headgear.call("set_visual_scale", 1.96)
        # Wind-reactive rear locks remain Head-bone attachments. Pivoted
        # movement preserves their scalp roots and avoids extra draw calls.
        var hair_motion := preload("res://rider_external_hair_dynamics.gd").new() as Node
        hair_motion.name = "ExternalHairDynamics"
        headgear.add_child(hair_motion)
        if not bool(hair_motion.call("configure", headgear)):
            hair_motion.queue_free()
            push_warning("CC0 dynamic hair unavailable; static hair preserved")
        else:
            hair_dynamics = hair_motion
        # Animate existing eye/lid/brow/lip meshes on the same real Head bone.
        # This remains purely visual and does not alter the imported Skin.
        var acting := preload("res://rider_external_expression.gd").new() as Node
        acting.name = "ExternalFacialActing"
        headgear.add_child(acting)
        if bool(acting.call("configure", headgear)):
            facial_acting = acting
        else:
            acting.queue_free()
            push_warning("CC0 hero facial acting unavailable; static face preserved")
    else:
        headgear.queue_free()
        push_warning("CC0 hero headwear could not fit imported Head bone")
    # Replace the Head-attached sculpted 360-degree face with an actual
    # four-weight GPU-skinned surface sharing the original 65-bone CC0 Skin.
    # The expressive eye/lid/brow nodes remain on the Head attachment.
    var skinned_portrait := preload("res://rider_external_skinned_portrait.gd").new() as Node
    skinned_portrait.name = "ExternalTrueSkinnedPortrait"
    character.add_child(skinned_portrait)
    var portrait_headwear := skeleton.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if not bool(skinned_portrait.call("install", skinned_meshes, skeleton, portrait_headwear)):
        skinned_portrait.queue_free()
        push_warning("CC0 weighted portrait unavailable; Head-attached sculpted face preserved")
    # The long rear hair curtain is no longer a rigid Head-bone shell.
    # Convert its actual sculpted triangles to the imported four-weight Skin
    # in original rest coordinates; keep animated loose locks and facial
    # attachments on Head. The rigid source remains as a safe fallback.
    var skinned_hair := preload("res://rider_external_skinned_back_hair.gd").new() as Node
    skinned_hair.name = "ExternalSkinnedBackHair"
    character.add_child(skinned_hair)
    var hair_headwear := skeleton.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if not bool(skinned_hair.call("install", skinned_meshes, skeleton, hair_headwear)):
        skinned_hair.queue_free()
        push_warning("CC0 weighted rear hair unavailable; Head-attached original preserved")
    else:
        skinned_hair_motion = skinned_hair
        # The five broad rear sculpted volumes were still rigid Head props.
        # Replace them atomically with the same ORIGINAL four-weight CC0
        # Head/Neck/Spine Skin as the continuous hair curtain. Keep the
        # hidden source volumes for fallback/visual comparisons.
        var source_body: MeshInstance3D
        for item in skinned_meshes:
            if String(item.name).contains("SuperHero"):
                source_body = item
                break
        if source_body != null:
            var weighted_locks := preload("res://rider_external_weighted_locks.gd").new() as Node
            weighted_locks.name = "ExternalWeightedRearLocks"
            skinned_hair.add_child(weighted_locks)
            if bool(weighted_locks.call("install", source_body, skeleton, hair_headwear, skinned_hair)):
                skinned_hair.set("weighted_locks", weighted_locks)
            else:
                weighted_locks.queue_free()
                push_warning("CC0 weighted rear locks unavailable; original sculpted locks remain")
    # Build a real four-weighted, curved flight jacket from the original
    # humanoid triangles. It shares the imported Skin and skeleton.
    var outfit := preload("res://rider_external_skinned_outfit.gd").new() as Node
    outfit.name = "ExternalSkinnedFlightSuit"
    character.add_child(outfit)
    if not bool(outfit.call("install", skinned_meshes)):
        push_warning("CC0 skinned jacket shell unavailable; original body remains")
    else:
        # Anatomical plates share the imported Skin and original joint poses.
        # Resolve the actual forward direction from the fitted head, never
        # assume the GLB faces a hardcoded local Z direction.
        var armor_face_sign := -1.0
        var armor_head := skeleton.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
        if armor_head != null:
            armor_face_sign = float(armor_head.get("face_sign"))
        var armor := preload("res://rider_external_skinned_armor.gd").new() as Node
        armor.name = "IntegratedSkinnedArmor"
        outfit.add_child(armor)
        if not bool(armor.call("install", outfit.get("garment") as MeshInstance3D, armor_face_sign)):
            push_warning("CC0 skinned anatomical armor unavailable")
    # The four diagonal flight-harness bands are clipped from the SAME
    # weighted jacket, not rigid decals. Both camera sides stay legible.
    if outfit.get("garment") is MeshInstance3D:
        var harness := preload("res://rider_external_skinned_harness.gd").new() as Node
        harness.name = "IntegratedSkinnedFlightHarness"
        outfit.add_child(harness)
        var harness_head := skeleton.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
        var harness_face_sign := float(harness_head.get("face_sign")) if harness_head != null else -1.0
        if not bool(harness.call("install", outfit.get("garment") as MeshInstance3D, harness_face_sign)):
            harness.queue_free()
            push_warning("CC0 four-weight flight harness unavailable")
    # The open-front, raised-back neck yoke connects the imported Head to the
    # true four-weight jacket/shoulder silhouette without a rigid collar ring.
    # It shares the CC0 Skin and is cosmetic only (no touch/physics changes).
    var neck_yoke := preload("res://rider_external_skinned_neck_yoke.gd").new() as Node
    neck_yoke.name = "ExternalSkinnedNeckYoke"
    character.add_child(neck_yoke)
    var neck_headwear := skeleton.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    var neck_face_sign := float(neck_headwear.get("face_sign")) if neck_headwear != null else -1.0
    if not bool(neck_yoke.call("install", skinned_meshes, skeleton, neck_face_sign)):
        neck_yoke.queue_free()
        push_warning("CC0 weighted neck yoke unavailable; original jacket remains")
    # Weighted trousers and boots use the same original four-influence
    # skinning as the body; unlike rigid props, knees/ankles follow the rig.
    var lower := preload("res://rider_external_skinned_lower.gd").new() as Node
    lower.name = "ExternalSkinnedLowerSuit"
    character.add_child(lower)
    var boot_headgear := skeleton.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    var boot_face_sign := float(boot_headgear.get("face_sign")) if boot_headgear != null else -1.0
    if not bool(lower.call("install", skinned_meshes, boot_face_sign)):
        push_warning("CC0 weighted lower garments unavailable; original legs remain")
    # Real sculpted sleeve triangles preserve imported four-weight elbow bends.
    var sleeves := preload("res://rider_external_skinned_sleeves.gd").new() as Node
    sleeves.name = "ExternalSkinnedFlightSleeves"
    character.add_child(sleeves)
    var sleeves_installed := bool(sleeves.call("install", skinned_meshes, skeleton))
    if not sleeves_installed:
        push_warning("CC0 weighted sleeves unavailable; original arms remain")
    elif outfit.get("garment") is MeshInstance3D and not neck_yoke.is_queued_for_deletion():
        # The real four-weight jacket + sleeves already bridge the neck and
        # deltoids. The extra full-volume yoke reads as an inflated blue ring
        # in the 1280x720 front camera; retire only this redundant overlay.
        # Keep its original Skin mesh for isolated QA and fallback if either
        # fitted garment piece is unavailable.
        var redundant_collar := neck_yoke.get("collar") as MeshInstance3D
        if redundant_collar != null:
            redundant_collar.visible = false
    # Broad split flight-mantle panels inherit four real bone weights each,
    # adding a readable chase silhouette without rigid props or collisions.
    var mantle := preload("res://rider_external_skinned_mantle.gd").new() as Node
    mantle.name = "ExternalSkinnedFlightMantle"
    character.add_child(mantle)
    var mantle_face_sign := -1.0
    var fitted_headgear := skeleton.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if fitted_headgear != null:
        mantle_face_sign = float(fitted_headgear.get("face_sign"))
    if not bool(mantle.call("install", skinned_meshes, skeleton, mantle_face_sign)):
        push_warning("CC0 skinned split mantle unavailable; original suit remains")
    else:
        flight_mantle = mantle
    # Broader, luminous shoulder flight hardware is also genuinely weighted to
    # the imported shoulder/spine/pelvis joints. Cosmetic, no new collisions.
    var thrusters := preload("res://rider_external_skinned_thrusters.gd").new() as Node
    thrusters.name = "ExternalSkinnedShoulderThrusters"
    character.add_child(thrusters)
    if not bool(thrusters.call("install", skinned_meshes, skeleton, mantle_face_sign)):
        push_warning("CC0 weighted shoulder thrusters unavailable; original rider remains")
    # Coherent front/chase shoulder armor, sculpted around the actual CC0
    # torso and GPU-skinned to the same arm/spine/pelvis bones.
    var pauldrons := preload("res://rider_external_skinned_pauldron.gd").new() as Node
    pauldrons.name = "ExternalSkinnedFlightPauldrons"
    character.add_child(pauldrons)
    if not bool(pauldrons.call("install", skinned_meshes, skeleton, mantle_face_sign)):
        pauldrons.queue_free()
        push_warning("CC0 weighted shoulder armor unavailable; original silhouette preserved")
    # Register only the actual shader materials that expose all three action
    # uniforms. Every piece remains bound to the original imported Skin.
    for source in skinned_meshes:
        if String(source.name).contains("SuperHero"):
            _register_action_material(source)
    if outfit.get("garment") is MeshInstance3D:
        _register_action_material(outfit.get("garment") as MeshInstance3D)
    if lower.get("trousers") is MeshInstance3D:
        _register_action_material(lower.get("trousers") as MeshInstance3D)
    if lower.get("boots") is MeshInstance3D:
        _register_action_material(lower.get("boots") as MeshInstance3D)
    if not pauldrons.is_queued_for_deletion():
        for shell in pauldrons.get("shells"):
            _register_action_material(shell as MeshInstance3D)
    # Deliberately do not modify bone rest positions, imported inverse bind
    # matrices or the imported Skin: those are the asset's real authoring data.
    # The animated board updates at normal priority. Follow it afterwards to
    # avoid a one-frame deck/boot gap while steering, boosting or landing.
    process_priority = 100
    set_process(true)
    return true

func _register_action_material(mesh: MeshInstance3D) -> void:
    if mesh == null or not (mesh.material_override is ShaderMaterial):
        return
    var material := mesh.material_override as ShaderMaterial
    if material.shader == null:
        return
    var shader_code := material.shader.code
    for parameter in ["action_boost", "action_carve", "action_jump"]:
        if not shader_code.contains("uniform float " + parameter):
            return
    if not action_materials.has(material):
        action_materials.append(material)

func _update_action_materials(steer: float, jump: float) -> void:
    for material in action_materials:
        material.set_shader_parameter("action_boost", action_charge)
        material.set_shader_parameter("action_carve", steer)
        material.set_shader_parameter("action_jump", jump)

func _bone(names: Array[String]) -> int:
    if skeleton == null:
        return -1
    for name in names:
        var index := skeleton.find_bone(name)
        if index >= 0:
            return index
    return -1

func _pose(names: Array[String], delta_rotation: Quaternion, blend: float) -> void:
    var index := _bone(names)
    if index < 0:
        return
    var base: Quaternion = rest_rotations.get(index, Quaternion.IDENTITY)
    var current := skeleton.get_bone_pose_rotation(index)
    skeleton.set_bone_pose_rotation(index, current.slerp(base * delta_rotation, blend))

func _process(delta: float) -> void:
    if skeleton == null or rider == null:
        return
    _follow_board_contact()
    elapsed += delta
    var steer := clampf(float(rider.get("lean")), -1.0, 1.0)
    # The board and legs answer touch immediately; the real spine follows
    # with frame-rate-independent inertia. Head and arms counter-rotate
    # briefly into a carve before settling into the same stable surf pose.
    torso_follow = lerpf(torso_follow, steer,
        1.0 - exp(-maxf(delta, 0.0) * 7.5))
    var turn_lead := clampf(steer - torso_follow, -1.0, 1.0)
    var turbo := bool(rider.get("boosting"))
    var height := maxf(rider.position.y, 0.0)
    var jump := clampf(height / 1.25, 0.0, 1.0)
    # The previous 0.02-m/frame jump-direction threshold and delta*9 pose
    # blend changed animation timing with phone refresh rate. Use metres per
    # second and an exponential response instead (30/60/120 Hz converge).
    vertical_speed = (height - previous_height) / maxf(delta, 0.001)
    var ascending := vertical_speed > 0.08
    if previous_height > 0.18 and height <= 0.04 and vertical_speed < -0.25:
        landing_impact = clampf(-vertical_speed * 0.10, 0.0, 0.50)
    landing_impact *= exp(-maxf(delta, 0.0) * 12.0)
    previous_height = height
    last_jump = move_toward(last_jump, jump, delta * 7.0)
    var boost := 1.0 if turbo else 0.0
    # The first update must fit the imported T-pose directly to the board.
    # Only subsequent pose transitions are damped; otherwise a short first
    # frame exposes T-pose arms and makes idle stance depend on startup FPS.
    var blend := 1.0 if elapsed <= delta + 0.00001 else \
        1.0 - exp(-maxf(delta, 0.0) * 9.0)
    action_charge = move_toward(action_charge, boost, delta * 6.0)
    _update_action_materials(steer, last_jump)
    # Surf stance: bent knees, articulated ankles, responsive hips, elbows and
    # wrists. Every rotation acts on the genuine imported 65-bone skeleton.
    # No board physics, input mapping or game collision logic is changed.
    var carve := absf(steer)
    var crouch := 0.15 + 0.17 * carve + 0.12 * boost + 0.08 * last_jump + landing_impact * 0.22
    var breathing := sin(elapsed * 2.3) * 0.025
    _pose(["pelvis", "Hips"], Quaternion(Vector3.FORWARD, -steer * 0.18) *
        Quaternion(Vector3.RIGHT, 0.08 + crouch * 0.27 + landing_impact * 0.14), blend)
    _pose(["spine_01", "Spine"], Quaternion(Vector3.FORWARD, torso_follow * 0.10) *
        Quaternion(Vector3.RIGHT, -0.05 + boost * 0.13 + last_jump * 0.12 + breathing - landing_impact * 0.08), blend)
    _pose(["spine_02", "spine_03", "Chest", "UpperChest"],
        Quaternion(Vector3.UP, -torso_follow * 0.19) *
        Quaternion(Vector3.FORWARD, -turn_lead * 0.07) *
        Quaternion(Vector3.RIGHT, -0.07 + boost * 0.17 + last_jump * 0.15), blend)
    _pose(["neck_01", "Neck"],
        Quaternion(Vector3.UP, steer * 0.09 + turn_lead * 0.10), blend)
    _pose(["Head"], Quaternion(Vector3.UP, -steer * 0.24 - turn_lead * 0.16) *
        Quaternion(Vector3.RIGHT, -last_jump * 0.12 + boost * 0.07 + landing_impact * 0.12), blend)
    # Keep the genuine weighted arms in a compact surfing stance rather
    # than the imported superhero's wide T-pose. Both shoulders, elbows and
    # wrists articulate on their original joints; wings/board stay untouched.
    for side in [-1, 1]:
        var prefix := "Left" if side < 0 else "Right"
        var sign_side := float(side)
        # Transfer weight between the actual left/right leg bones when
        # carving. The inside leg compresses while the outside leg extends.
        var leg_load := steer * sign_side * 0.14
        var outside := maxf(0.0, steer * sign_side)
        var inside := maxf(0.0, -steer * sign_side)
        # The outside arm opens for balance, the inside elbow tucks into the
        # turn; this is real imported shoulder/elbow/wrist articulation.
        # Bring the imported CC0 arms closer to the board-riding torso.
        # The previous broad carve pose reopened the bulky jacket/shoulder
        # silhouette even after its duplicate geometry was trimmed. Keep
        # outside-arm balance and inside-arm tuck, but reduce their extreme
        # reach and lower both arms a little further from the source T-pose.
        var spread := -sign_side * (1.42 + 0.12 * carve +
            0.24 * outside - 0.10 * inside -
            last_jump * (0.45 if ascending else 0.32))
        _pose(["upperarm_l" if side < 0 else "upperarm_r", prefix + "UpperArm", prefix + "Arm"],
            Quaternion(Vector3.FORWARD, spread - torso_follow * 0.13) *
            Quaternion(Vector3.RIGHT, -0.20 - boost * 0.30 + landing_impact * 0.14), blend)
        _pose(["lowerarm_l" if side < 0 else "lowerarm_r", prefix + "LowerArm", prefix + "ForeArm", prefix + "Forearm"],
            Quaternion(Vector3.RIGHT, -0.55 - last_jump * 0.42 - boost * 0.16 -
                inside * 0.21 + outside * 0.08) *
            Quaternion(Vector3.FORWARD, sign_side * (0.10 + carve * 0.09 +
                turn_lead * 0.10)), blend)
        _pose(["hand_l" if side < 0 else "hand_r", prefix + "Hand"],
            Quaternion(Vector3.RIGHT, 0.20 + boost * 0.14 +
                outside * 0.10 - inside * 0.08) *
            Quaternion(Vector3.UP, -sign_side * steer * 0.12), blend)
        _pose(["thigh_l" if side < 0 else "thigh_r", prefix + "UpperLeg", prefix + "UpLeg", prefix + "Thigh"],
            Quaternion(Vector3.RIGHT, -0.24 - crouch * 0.42 + last_jump * 0.18 - leg_load - landing_impact * 0.20), blend)
        _pose(["calf_l" if side < 0 else "calf_r", prefix + "LowerLeg", prefix + "Leg", prefix + "Shin"],
            Quaternion(Vector3.RIGHT, 0.34 + crouch * 0.50 - last_jump * 0.45 + leg_load * 1.25 + landing_impact * 0.34), blend)
        _pose(["foot_l" if side < 0 else "foot_r", prefix + "Foot"],
            Quaternion(Vector3.RIGHT, -0.13 - crouch * 0.12 + last_jump * 0.19 - leg_load * 0.35 - landing_impact * 0.18), blend)
    if flight_mantle != null:
        flight_mantle.call("set_motion", steer, boost, last_jump)
    if facial_acting != null:
        facial_acting.call("animate", steer, turbo, last_jump, elapsed)
    if hair_dynamics != null:
        hair_dynamics.call("set_motion", steer, boost, last_jump, elapsed)
    if skinned_hair_motion != null:
        skinned_hair_motion.call("set_motion", steer, boost, last_jump, elapsed)

func fit_to_board() -> bool:
    # Normalize different glTF unit conventions without touching the Skin.
    if character == null or skinned_meshes.is_empty():
        return false
    var lowest := INF
    var highest := -INF
    for mesh in skinned_meshes:
        var bounds := mesh.get_aabb()
        for x in [bounds.position.x, bounds.end.x]:
            for y in [bounds.position.y, bounds.end.y]:
                for z in [bounds.position.z, bounds.end.z]:
                    var point := character.to_local(mesh.to_global(Vector3(x, y, z)))
                    lowest = minf(lowest, point.y)
                    highest = maxf(highest, point.y)
    var height := highest - lowest
    if height < 0.1 or height > 100.0:
        return false
    var factor := 2.72 / height
    # The source CC0 humanoid is exceptionally narrow in both landscape
    # cameras relative to its head and the existing board. Widen the entire
    # genuine 65-bone visual in model space, not the bones or inverse binds.
    # Keep the original 2.72 m vertical fit and all gameplay contact points.
    character.scale = Vector3(factor * 1.16, factor, factor * 1.06)
    # Align the imported skinned soles with the ACTUAL animated board's
    # sculpted traction deck. The old hard-coded 0.08 placed the rider's
    # lowest source vertex well below the ~0.44-high deck, causing overlap.
    # This is visual-only: never reposition the board, its collision or touch.
    board_contact_offset = 0.045 - lowest * factor
    board_contact_active = true
    _follow_board_contact()
    # Determine the *actual* imported face direction from the weighted Head
    # and eye geometry instead of assuming every CC0 GLB faces +Z.
    # Menu/front camera is -Z; chase camera is +Z.
    var headwear := skeleton.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    var forward_sign := -1.0
    if headwear != null:
        forward_sign = float(headwear.get("face_sign"))
    character.rotation.y = PI if forward_sign > 0.0 else 0.0
    return true

func _follow_board_contact() -> void:
    if not board_contact_active or character == null:
        return
    # No lerp: even a one-frame lag lets the moving deck intersect the boots.
    # The rider's root jump arc and original 65-bone animation remain intact.
    character.position.y = _board_deck_height() + board_contact_offset

func _board_deck_height() -> float:
    # Sample the real sculpted grip surface in rider coordinates. Using the
    # node transform also respects the board's existing hover/bob animation.
    if rider == null:
        return 0.08
    var board := rider.get_node_or_null("LegacyRider/Floating hoverboard") as Node3D
    if board == null:
        return 0.08
    var grip := board.get_node_or_null("SculptedHoverboardChassis/ContouredTractionDeck") as MeshInstance3D
    if grip == null or grip.mesh == null:
        return 0.08
    var top_y := grip.mesh.get_aabb().end.y
    return rider.to_local(grip.to_global(Vector3(0.0, top_y, 0.0))).y
