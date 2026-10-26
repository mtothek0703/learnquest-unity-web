extends SceneTree
## V106: genuine original-skeleton garment replaces the rigid front jacket.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("SKINNED JACKET TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("imported rider missing")
        return
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    var garment := model.get_node_or_null("UnifiedSkinnedUpperJacket") as Node3D
    if rig == null or garment == null:
        _fail("shared original rig and continuous jacket required")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        _fail("original 13-bone skeleton required")
        return
    var jacket := garment.get_node_or_null("UnifiedSkinnedJacket") as MeshInstance3D
    var rim := garment.get_node_or_null("SkinnedCollarEdge") as MeshInstance3D
    var zipper := garment.get_node_or_null("SkinnedCenterSeam") as MeshInstance3D
    for part in [jacket, rim, zipper]:
        if part == null or part.mesh == null or part.skin == null:
            _fail("all jacket layers need actual skinned mesh surfaces")
            return
        if part.skin.get_bind_count() != 13 or part.get_node_or_null(part.skeleton) != skeleton:
            _fail("jacket must share original body skeleton")
            return
    var arrays: Array = jacket.mesh.surface_get_arrays(0)
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
    var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    if points.size() < 6000 or bones.size() != points.size() * 4 or weights.size() != bones.size() or colors.size() != points.size() or normals.size() != points.size():
        _fail("continuous shaded jacket needs complete 360-degree topology and four weights")
        return
    var front := 0
    var back := 0
    var shoulders := 0
    var collar := 0
    var arm_weighted := 0
    var neck_weighted := 0
    for i in range(points.size()):
        var p := points[i]
        if p.z < -0.57 and p.y > 1.4 and p.y < 2.2:
            front += 1
        if p.z > 0.54 and p.y < 2.2:
            back += 1
        if absf(p.x) > 0.50 and p.y > 1.85 and p.y < 2.20:
            shoulders += 1
        if p.y > 2.26:
            collar += 1
        var sum := 0.0
        for slot in range(4):
            var index := i * 4 + slot
            if bones[index] < 0 or bones[index] >= 13 or weights[index] < 0.0:
                _fail("invalid bone or negative weight")
                return
            if (bones[index] == 5 or bones[index] == 7) and weights[index] > 0.10:
                arm_weighted += 1
            if bones[index] == 3 and weights[index] > 0.10:
                neck_weighted += 1
            sum += weights[index]
        if absf(sum - 1.0) > 0.002:
            _fail("non-normalized GPU skin weights")
            return
    if front < 300 or back < 300 or shoulders < 100 or collar < 100 or arm_weighted < 50 or neck_weighted < 50:
        _fail("missing continuous front/back, sculpted shoulders, collar or blended bones")
        return
    var material := jacket.material_override as StandardMaterial3D
    if material == null or not material.vertex_color_use_as_albedo or material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
        _fail("jacket must be lit with authored material colors")
        return
    var old := model.get_node_or_null("AnimatedTailoredFlightJacket") as Node3D
    if old == null:
        _fail("legacy jacket required for safe retirement")
        return
    var breathing := old.get_node_or_null("AnimatedBreathingJacket") as Node3D
    if breathing == null:
        _fail("legacy breathing pivot missing")
        return
    for name in ["TailoredLeftChest", "TailoredRightChest", "LayeredLeftChestArmor",
            "LayeredRightChestArmor", "LuminousCenterZipper", "LuminousWaistPiping",
            "LuminousLeftChestEdge", "LuminousRightChestEdge"]:
        var part := breathing.get_node_or_null(name) as MeshInstance3D
        if part == null or part.visible:
            _fail("rigid chest overlap still visible: " + name)
            return
    var old_collar := old.get_node_or_null("RaisedFlightCollar") as MeshInstance3D
    if old_collar == null or old_collar.visible:
        _fail("old rigid collar must not intersect the new skinned neck")
        return
    if garment.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("garment must not change physics or smartphone touch")
        return
    var before := skeleton.get_bone_global_pose(2)
    rider.set("lean", 0.90)
    rider.set("boosting", true)
    rider.position.y = 0.95
    rig.call("_process", 0.25)
    var after := skeleton.get_bone_global_pose(2)
    if before.basis.get_rotation_quaternion().angle_to(after.basis.get_rotation_quaternion()) < 0.02:
        _fail("garment must follow real original body animation")
        return
    print("SKINNED JACKET TEST PASSED: continuous 360-degree torso, blended shoulders/neck, original GPU skin, retired rigid overlaps")
    quit(0)
