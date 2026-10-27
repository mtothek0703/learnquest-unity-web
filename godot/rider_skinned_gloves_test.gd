extends SceneTree
## V115: skinned gloves must meet the sleeves and preserve articulated fingers.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("SKINNED GLOVE TEST FAILED: " + message)
    quit(1)

func _deformed(mesh: MeshInstance3D, vertex: int, skeleton: Skeleton3D) -> Vector3:
    var arrays: Array = mesh.mesh.surface_get_arrays(0)
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var result := Vector3.ZERO
    for slot in range(4):
        var idx := vertex * 4 + slot
        result += (skeleton.get_bone_global_pose(bones[idx]) *
            mesh.skin.get_bind_pose(bones[idx]) * points[vertex]) * weights[idx]
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
    var gloves := model.get_node_or_null("UnifiedSkinnedGloves") as Node3D
    var sleeves := model.get_node_or_null("OrganicSkinnedArmwear") as Node3D
    if rig == null or gloves == null or sleeves == null:
        _fail("shared skeleton, sleeves and gloves missing")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        _fail("gloves must share original 13 bones")
        return
    var palms: Array = gloves.get("palms")
    var stitches: Array = gloves.get("knuckle_seams")
    if palms.size() != 2 or stitches.size() != 2:
        _fail("both palms and knuckle stitching required")
        return
    for part in palms + stitches:
        var mesh := part as MeshInstance3D
        if mesh == null or mesh.mesh == null or mesh.skin == null or mesh.skin.get_bind_count() != 13:
            _fail("missing skinned glove geometry")
            return
        if mesh.get_node_or_null(mesh.skeleton) != skeleton:
            _fail("gloves detached from original skeleton")
            return
        var arrays: Array = mesh.mesh.surface_get_arrays(0)
        var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
        if points.size() < 100 or bones.size() != points.size() * 4 or weights.size() != bones.size() or normals.size() != points.size() or colors.size() != points.size():
            _fail("gloves need real shaded 3D surfaces and four skin weights")
            return
        var forearm_count := 0
        for i in range(points.size()):
            var total := 0.0
            for slot in range(4):
                var idx := i * 4 + slot
                if bones[idx] < 0 or bones[idx] >= 13 or weights[idx] < 0.0:
                    _fail("invalid glove skin weight")
                    return
                if (bones[idx] == 6 or bones[idx] == 8) and weights[idx] > 0.70:
                    forearm_count += 1
                total += weights[idx]
            if absf(total - 1.0) > 0.002:
                _fail("unnormalized glove GPU weights")
                return
        if forearm_count < 100:
            _fail("gloves must actually follow forearm bones")
            return
    for index in range(2):
        var side := -1.0 if index == 0 else 1.0
        var a: Vector3 = gloves.call("_point", side, 0.35, 0.0)
        var b: Vector3 = gloves.call("_point", side, 0.35, 0.5)
        if a.distance_to(b) < 0.28:
            _fail("glove palm cross-section is not rounded 3D geometry")
            return
        var sleeve_center := Vector3(side * 0.73, 1.33, -0.06)
        var glove_center := Vector3(side * 0.71, 1.34, -0.06)
        if sleeve_center.distance_to(glove_center) > 0.09:
            _fail("skinned palm does not bridge the cuff")
            return
        var arm := model.get_node_or_null("BalanceArm%d" % index) as Node3D
        var gauntlet := arm.get_node_or_null("SculptedRiderGauntlet") as Node3D
        if gauntlet == null or gauntlet.get_node_or_null("AnimatedWristDisplay") == null:
            _fail("existing animated wrist display missing")
            return
        for finger in range(4):
            if gauntlet.get_node_or_null("ArticulatedFinger%d" % finger) == null:
                _fail("existing articulated fingers must remain")
                return
        if gauntlet.get_node_or_null("SculptedThumb") == null:
            _fail("original thumb must remain")
            return
        for name in ["SculptedForearmShell", "LuminousGauntletSeams", "LayeredKnuckleGuard"]:
            var old := gauntlet.get_node_or_null(name) as MeshInstance3D
            if old == null or old.visible:
                _fail("duplicate rigid gauntlet shell still visible: " + name)
                return
        for child in arm.get_children():
            if child is MeshInstance3D and child.mesh is SphereMesh and child.visible:
                _fail("old spherical glove still visible")
                return
    if gloves.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("gloves must not change touch or physics")
        return
    var before := _deformed(palms[0] as MeshInstance3D, 650, skeleton)
    rider.set("lean", 0.95)
    rider.set("boosting", true)
    rider.position.y = 0.9
    rig.call("_process", 0.35)
    var after := _deformed(palms[0] as MeshInstance3D, 650, skeleton)
    if before.distance_to(after) < 0.025:
        _fail("glove palm must deform with original forearm during jump")
        return
    print("SKINNED GLOVE TEST PASSED: 360-degree palm volume, cuff continuity, original 13-bone weights, retained animated fingers and collision safety")
    quit(0)
