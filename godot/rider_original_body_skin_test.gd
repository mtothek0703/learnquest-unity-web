extends SceneTree
## Sprint 1 / V97 regression: validate real imported-body GPU skinning.
## This is separate from the long gameplay smoke test and runs headlessly.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("ORIGINAL BODY SKIN TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("bundled original glTF was not loaded")
        return
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    if rig == null:
        _fail("V97 original body rig was not installed")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        _fail("original body needs a full 13-bone Skeleton3D")
        return
    for name in ["Hips", "Spine", "Chest", "Neck", "Head", "LeftUpperArm",
        "LeftForearm", "RightUpperArm", "RightForearm", "LeftThigh",
        "LeftShin", "RightThigh", "RightShin"]:
        if skeleton.find_bone(name) < 0:
            _fail("missing real original-body bone: " + name)
            return
    # Geometry-only tests previously missed a critical runtime bug:
    # inverse bind poses shifted the entire skinned character below the
    # board because all bone pose translations remained at the origin.
    var reference_skin := skeleton.create_skin_from_rest_transforms()
    for bone_id in [0, 2, 4, 6, 10, 12]:
        var rest_origin := reference_skin.get_bind_pose(bone_id).affine_inverse().origin
        var pose_origin := skeleton.get_bone_global_pose(bone_id).origin
        if pose_origin.distance_to(rest_origin) > 0.22:
            _fail("bone %d pose=%s rest=%s must retain authored translation" % [bone_id, str(pose_origin), str(rest_origin)])
            return
    if skeleton.get_bone_global_pose(4).origin.y < 2.40:
        _fail("the real skinned head must not be shifted beneath the hoverboard")
        return
    var skinned: Array = rig.get("skinned_meshes")
    if skinned.is_empty():
        _fail("original imported mesh was not skinned")
        return
    var vertex_count := 0
    var weighted_arms := 0
    var weighted_legs := 0
    var multi_bone := 0
    for source in skinned:
        var instance := source as MeshInstance3D
        if instance == null or instance.skin == null or instance.skin.get_bind_count() != 13:
            _fail("original glTF mesh is not bound to all 13 bones")
            return
        if instance.get_node_or_null(instance.skeleton) != skeleton:
            _fail("original glTF mesh references the wrong skeleton")
            return
        if not (instance.mesh is ArrayMesh):
            _fail("original glTF geometry was replaced by a non-skinned primitive")
            return
        for surface_index in range(instance.mesh.get_surface_count()):
            var arrays: Array = instance.mesh.surface_get_arrays(surface_index)
            var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var ids: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
            var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
            if ids.size() != points.size() * 4 or weights.size() != points.size() * 4:
                _fail("every original vertex needs four valid GPU skin slots")
                return
            vertex_count += points.size()
            for i in range(points.size()):
                var start := i * 4
                var total := 0.0
                var nonzero := 0
                for j in range(4):
                    var bone_id := ids[start + j]
                    var weight := weights[start + j]
                    if bone_id < 0 or bone_id >= 13 or weight < 0.0:
                        _fail("invalid bone ID or negative skin weight")
                        return
                    total += weight
                    if weight > 0.05:
                        nonzero += 1
                        if bone_id >= 5 and bone_id <= 8:
                            weighted_arms += 1
                        if bone_id >= 9 and bone_id <= 12:
                            weighted_legs += 1
                if absf(total - 1.0) > 0.002:
                    _fail("original body weights are not normalized")
                    return
                if nonzero >= 2:
                    multi_bone += 1
    # V115 retires exactly two original glTF hand primitives only AFTER
    # real skinned replacement gloves exist. Count the remaining torso,
    # upper arms, legs and boots rather than requiring obsolete hand vertices.
    if vertex_count < 1500 or weighted_arms < 30 or weighted_legs < 30 or multi_bone < 100:
        _fail("original torso/arms/legs must remain skinned: vertices=%d arms=%d legs=%d multi=%d" % [
            vertex_count, weighted_arms, weighted_legs, multi_bone])
        return
    # V108: the original glTF head was opaque and hid the newer skinned face.
    # The torso/limbs remain original; the 360-degree head is a real replacement
    # bound to the SAME original 13-bone rig, not a static visual mask.
    if int(rig.get("retired_head_surfaces")) < 3:
        _fail("three occluding original glTF head surfaces must be retired")
        return
    var face := model.get_node_or_null("SculptedSkinnedFace/ContinuousSkinnedFace") as MeshInstance3D
    if face == null or face.skin == null or face.skin.get_bind_count() != 13:
        _fail("replacement head must be truly GPU-skinned to original skeleton")
        return
    if face.get_node_or_null(face.skeleton) != skeleton:
        _fail("replacement head references wrong original skeleton")
        return
    var head_arrays: Array = face.mesh.surface_get_arrays(0)
    var head_bones: PackedInt32Array = head_arrays[Mesh.ARRAY_BONES]
    var head_weights: PackedFloat32Array = head_arrays[Mesh.ARRAY_WEIGHTS]
    var new_head_weighted := 0
    for i in range(head_bones.size()):
        if head_bones[i] == 4 and head_weights[i] > 0.5:
            new_head_weighted += 1
    if new_head_weighted < 100:
        _fail("replacement head must retain substantial real head-bone skinning")
        return
    if rig.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("the new visual skeleton must not alter gameplay collisions")
        return
    var neutral_arm := skeleton.get_bone_pose_rotation(5)
    rider.set("lean", 0.8)
    rider.set("boosting", true)
    rider.position.y = 1.0
    rig.call("_process", 0.3)
    var active_arm := skeleton.get_bone_pose_rotation(5)
    var active_knee := skeleton.get_bone_pose_rotation(10)
    var active_head := skeleton.get_bone_pose_rotation(4)
    if active_arm.angle_to(neutral_arm) < 0.05 or active_knee.get_angle() < 0.05 or active_head.get_angle() < 0.05:
        _fail("steering, boost and jump must pose the original arms, knees and head")
        return
    rider.set("lean", 0.0)
    rider.set("boosting", false)
    rider.position.y = 0.0
    rig.call("_process", 0.3)
    if skeleton.get_bone_pose_rotation(10).get_angle() >= active_knee.get_angle():
        _fail("original-body knee must relax after landing")
        return
    print("ORIGINAL BODY SKIN TEST PASSED: 13 bones, original glTF torso/limbs plus replacement skinned head, four normalized GPU weights, live full-body poses")
    quit(0)
