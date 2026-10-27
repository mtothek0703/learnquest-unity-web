extends SceneTree
## V114: prove the new continuous lower body is actually skinned, shaped,
## animated and free of duplicate rigid trousers; preserve boots/gameplay.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("SKINNED LOWER BODY TEST FAILED: " + reason)
    quit(1)

func _skin_point(mesh: MeshInstance3D, vertex_index: int, skeleton: Skeleton3D) -> Vector3:
    var arrays: Array = mesh.mesh.surface_get_arrays(0)
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var result := Vector3.ZERO
    for slot in range(4):
        var index := vertex_index * 4 + slot
        var bone_id := bones[index]
        result += (skeleton.get_bone_global_pose(bone_id) * mesh.skin.get_bind_pose(bone_id) * points[vertex_index]) * weights[index]
    return result

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("original imported rider missing")
        return
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    var lower := model.get_node_or_null("UnifiedSkinnedLowerBody") as Node3D
    if rig == null or lower == null:
        _fail("original rig and new continuous trousers missing")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        _fail("lower body must use original 13 bones")
        return
    var legs: Array = lower.get("legs")
    var seams: Array = lower.get("seams")
    var yoke := lower.get_node_or_null("UnifiedSkinnedHipYoke") as MeshInstance3D
    if legs.size() != 2 or seams.size() != 2 or yoke == null:
        _fail("two continuous legs, two seams and a unified hip yoke required")
        return
    for part in legs + seams + [yoke]:
        var mesh := part as MeshInstance3D
        if mesh == null or mesh.mesh == null or mesh.skin == null or mesh.skin.get_bind_count() != 13:
            _fail("lower body must have real 13-bone GPU skin")
            return
        if mesh.get_node_or_null(mesh.skeleton) != skeleton:
            _fail("lower body uses detached or duplicated skeleton")
            return
        var arrays: Array = mesh.mesh.surface_get_arrays(0)
        var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
        if points.size() < 300 or bones.size() != points.size() * 4 or weights.size() != bones.size() or normals.size() != points.size() or colors.size() != points.size():
            _fail("missing curved 3D surface, normals, colors or four weights")
            return
        var upper := 0
        var lower_leg := 0
        for i in range(points.size()):
            var total := 0.0
            for slot in range(4):
                var idx := i * 4 + slot
                if bones[idx] < 0 or bones[idx] >= 13 or weights[idx] < 0.0:
                    _fail("invalid GPU bone weights")
                    return
                total += weights[idx]
                if bones[idx] == 10 or bones[idx] == 12:
                    if weights[idx] > 0.35:
                        lower_leg += 1
                if bones[idx] == 9 or bones[idx] == 11:
                    if weights[idx] > 0.35:
                        upper += 1
            if absf(total - 1.0) > 0.002:
                _fail("unnormalized GPU skin weights")
                return
        if mesh == legs[0] or mesh == legs[1]:
            if points.size() < 4000 or upper < 300 or lower_leg < 300:
                _fail("each 360-degree trouser must blend thigh and shin skinning")
                return
    for index in range(2):
        var side := -1.0 if index == 0 else 1.0
        var a: Vector3 = lower.call("_leg_point", side, 0.58, 0.0)
        var b: Vector3 = lower.call("_leg_point", side, 0.58, 0.25)
        var c: Vector3 = lower.call("_leg_point", side, 0.58, 0.50)
        if a.distance_to(c) < 0.30 or a.distance_to(b) < 0.20:
            _fail("knee cross-section must be volumetric, not flat ribbons")
            return
        var pivot := model.get_node_or_null("BalanceLeg%d" % index) as Node3D
        if pivot == null or pivot.get_node_or_null("SculptedHoverBoot") == null:
            _fail("existing animated hover boots must remain")
            return
        var knee := pivot.get_node_or_null("AnimatedKneeKinematics/ArticulatedKnee") as Node3D
        if knee == null or knee.get_node_or_null("LuminousKneeRings") == null:
            _fail("existing animated knee and rings must remain")
            return
        var old := pivot.get_node_or_null("SculptedRiderLeg") as Node3D
        if old == null:
            _fail("legacy trousers missing for safe retirement")
            return
        for part in old.find_children("*", "MeshInstance3D", true, false):
            if (part as MeshInstance3D).visible:
                _fail("overlapping legacy trouser or knee guard still visible")
                return
    var suit := model.get_node_or_null("SculptedSkinnedFlightSuit") as Node3D
    var shells: Array = suit.get("suit_parts")
    if (shells[3] as MeshInstance3D).visible or (shells[4] as MeshInstance3D).visible:
        _fail("old separate leg guards must not occlude new lower body")
        return
    if lower.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("visual lower body must not modify collisions or touch")
        return
    var before := _skin_point(legs[0] as MeshInstance3D, 2500, skeleton)
    rider.set("lean", 0.95)
    rider.set("boosting", true)
    rider.position.y = 1.0
    rig.call("_process", 0.35)
    var after := _skin_point(legs[0] as MeshInstance3D, 2500, skeleton)
    if before.distance_to(after) < 0.025:
        _fail("skinned knee must actually deform under jump and boost")
        return
    print("SKINNED LOWER BODY TEST PASSED: continuous 360-degree hips/legs, knee deformation, safe legacy retirement and preserved boots")
    quit(0)
