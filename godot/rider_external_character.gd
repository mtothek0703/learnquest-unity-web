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
var facial_acting: Node
var flight_mantle: Node

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
    # Recolor the EXISTING skinned body, not an unrigged duplicate shell.
    # Lightweight procedural materials preserve original mesh + skin data.
    var suit_shader := load("res://rider_quaternius_suit.gdshader") as Shader
    if suit_shader != null:
        for mesh in skinned_meshes:
            if String(mesh.name).contains("SuperHero"):
                var suit := ShaderMaterial.new()
                suit.shader = suit_shader
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
        # Restore a readable stylized face/head silhouette at mobile chase scale.
        # The imported original head/65-bone rig remain untouched underneath.
        headgear.call("set_visual_scale", 2.30)
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
    # Build a real four-weighted, curved flight jacket from the original
    # humanoid triangles. It shares the imported Skin and skeleton.
    var outfit := preload("res://rider_external_skinned_outfit.gd").new() as Node
    outfit.name = "ExternalSkinnedFlightSuit"
    character.add_child(outfit)
    if not bool(outfit.call("install", skinned_meshes)):
        push_warning("CC0 skinned jacket shell unavailable; original body remains")
    # Weighted trousers and boots use the same original four-influence
    # skinning as the body; unlike rigid props, knees/ankles follow the rig.
    var lower := preload("res://rider_external_skinned_lower.gd").new() as Node
    lower.name = "ExternalSkinnedLowerSuit"
    character.add_child(lower)
    if not bool(lower.call("install", skinned_meshes)):
        push_warning("CC0 weighted lower garments unavailable; original legs remain")
    # Real sculpted sleeve triangles preserve imported four-weight elbow bends.
    var sleeves := preload("res://rider_external_skinned_sleeves.gd").new() as Node
    sleeves.name = "ExternalSkinnedFlightSleeves"
    character.add_child(sleeves)
    if not bool(sleeves.call("install", skinned_meshes, skeleton)):
        push_warning("CC0 weighted sleeves unavailable; original arms remain")
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
    # Deliberately do not modify bone rest positions, imported inverse bind
    # matrices or the imported Skin: those are the asset's real authoring data.
    set_process(true)
    return true

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
    elapsed += delta
    var steer := clampf(float(rider.get("lean")), -1.0, 1.0)
    var turbo := bool(rider.get("boosting"))
    var height := maxf(rider.position.y, 0.0)
    var jump := clampf(height / 1.25, 0.0, 1.0)
    var ascending := height > previous_height + 0.02
    previous_height = height
    last_jump = move_toward(last_jump, jump, delta * 7.0)
    var boost := 1.0 if turbo else 0.0
    var blend := minf(1.0, delta * 9.0)
    # Surf stance: bent knees, articulated ankles, responsive hips, elbows and
    # wrists. Every rotation acts on the genuine imported 65-bone skeleton.
    # No board physics, input mapping or game collision logic is changed.
    var carve := absf(steer)
    var crouch := 0.15 + 0.17 * carve + 0.12 * boost + 0.08 * last_jump
    var breathing := sin(elapsed * 2.3) * 0.025
    _pose(["pelvis", "Hips"], Quaternion(Vector3.FORWARD, -steer * 0.18) *
        Quaternion(Vector3.RIGHT, 0.08 + crouch * 0.27), blend)
    _pose(["spine_01", "Spine"], Quaternion(Vector3.FORWARD, steer * 0.10) *
        Quaternion(Vector3.RIGHT, -0.05 + boost * 0.13 + last_jump * 0.12 + breathing), blend)
    _pose(["spine_02", "spine_03", "Chest", "UpperChest"], Quaternion(Vector3.UP, -steer * 0.19) *
        Quaternion(Vector3.RIGHT, -0.07 + boost * 0.17 + last_jump * 0.15), blend)
    _pose(["neck_01", "Neck"], Quaternion(Vector3.UP, steer * 0.09), blend)
    _pose(["Head"], Quaternion(Vector3.UP, -steer * 0.24) *
        Quaternion(Vector3.RIGHT, -last_jump * 0.12 + boost * 0.07), blend)
    for side in [-1, 1]:
        var prefix := "Left" if side < 0 else "Right"
        var sign_side := float(side)
        var spread := -sign_side * (1.04 + 0.11 * carve -
            last_jump * (0.35 if ascending else 0.24))
        _pose(["upperarm_l" if side < 0 else "upperarm_r", prefix + "UpperArm", prefix + "Arm"],
            Quaternion(Vector3.FORWARD, spread - steer * 0.13) *
            Quaternion(Vector3.RIGHT, -0.11 - boost * 0.23), blend)
        _pose(["lowerarm_l" if side < 0 else "lowerarm_r", prefix + "LowerArm", prefix + "ForeArm", prefix + "Forearm"],
            Quaternion(Vector3.RIGHT, -0.36 - last_jump * 0.34 - boost * 0.08) *
            Quaternion(Vector3.FORWARD, sign_side * (0.10 + carve * 0.09)), blend)
        _pose(["hand_l" if side < 0 else "hand_r", prefix + "Hand"],
            Quaternion(Vector3.RIGHT, 0.14 + boost * 0.11) *
            Quaternion(Vector3.UP, -sign_side * steer * 0.12), blend)
        _pose(["thigh_l" if side < 0 else "thigh_r", prefix + "UpperLeg", prefix + "UpLeg", prefix + "Thigh"],
            Quaternion(Vector3.RIGHT, -0.24 - crouch * 0.42 + last_jump * 0.18), blend)
        _pose(["calf_l" if side < 0 else "calf_r", prefix + "LowerLeg", prefix + "Leg", prefix + "Shin"],
            Quaternion(Vector3.RIGHT, 0.34 + crouch * 0.50 - last_jump * 0.45), blend)
        _pose(["foot_l" if side < 0 else "foot_r", prefix + "Foot"],
            Quaternion(Vector3.RIGHT, -0.13 - crouch * 0.12 + last_jump * 0.19), blend)
    if flight_mantle != null:
        flight_mantle.call("set_motion", steer, boost, last_jump)
    if facial_acting != null:
        facial_acting.call("animate", steer, turbo, last_jump, elapsed)

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
    character.scale = Vector3.ONE * factor
    character.position.y = 0.08 - lowest * factor
    # Determine the *actual* imported face direction from the weighted Head
    # and eye geometry instead of assuming every CC0 GLB faces +Z.
    # Menu/front camera is -Z; chase camera is +Z.
    var headwear := skeleton.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    var forward_sign := -1.0
    if headwear != null:
        forward_sign = float(headwear.get("face_sign"))
    character.rotation.y = PI if forward_sign > 0.0 else 0.0
    return true
