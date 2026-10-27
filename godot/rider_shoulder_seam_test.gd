extends SceneTree
## V111: the actual V110 16:9/19.5:9 renders exposed magenta shoulder
## gaps and cuffs displaced from the hands. Test the sleeve's real 3D
## cross-section and shoulder-to-wrist continuity, not just its vertex count.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("SHOULDER SEAM TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("imported character missing")
        return
    var garment := model.get_node_or_null("OrganicSkinnedArmwear") as Node3D
    var jacket := model.get_node_or_null("UnifiedSkinnedUpperJacket") as Node3D
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    if garment == null or jacket == null or rig == null:
        _fail("unified jacket, sleeves and original rig required")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    var sleeves: Array = garment.get("sleeves")
    var cuffs: Array = garment.get("cuffs")
    if skeleton == null or skeleton.get_bone_count() != 13 or sleeves.size() != 2 or cuffs.size() != 2:
        _fail("both shoulders and cuffs must use the original 13-bone skeleton")
        return
    for index in range(2):
        var side := -1.0 if index == 0 else 1.0
        var sleeve := sleeves[index] as MeshInstance3D
        var cuff := cuffs[index] as MeshInstance3D
        if sleeve == null or cuff == null or sleeve.skin == null or cuff.skin == null:
            _fail("both fabric and cuff must be real skinned meshes")
            return
        for part in [sleeve, cuff]:
            if part.skin.get_bind_count() != 13 or part.get_node_or_null(part.skeleton) != skeleton:
                _fail("sleeve or cuff detached from original GPU skeleton")
                return
        var min_y := INF
        var max_y := -INF
        var min_z := INF
        var max_z := -INF
        var inner_x := INF
        var outer_x := -INF
        for step in range(24):
            var p: Vector3 = garment.call("_point", 0.0, float(step) / 24.0, side, 0)
            min_y = minf(min_y, p.y)
            max_y = maxf(max_y, p.y)
            min_z = minf(min_z, p.z)
            max_z = maxf(max_z, p.z)
            inner_x = minf(inner_x, absf(p.x))
            outer_x = maxf(outer_x, absf(p.x))
        # The old sleeve used X/Z rings with almost zero Y thickness.
        # A genuine sloping 3D shoulder needs a perpendicular, rounded ring.
        if max_y - min_y < 0.18 or max_z - min_z < 0.58:
            _fail("shoulder ring is still flat instead of volumetric")
            return
        if max_y < 2.22 or min_z > -0.55 or inner_x > 0.39 or outer_x < 0.92:
            _fail("sleeve root does not cover the exposed front shoulder")
            return
        var arm := model.get_node_or_null("BalanceArm%d" % index) as Node3D
        if arm == null or arm.get_node_or_null("SculptedRiderGauntlet") == null:
            _fail("articulated gauntlet must remain")
            return
        var hand: MeshInstance3D
        for child in arm.get_children():
            if child is MeshInstance3D and child.mesh is SphereMesh:
                hand = child as MeshInstance3D
                break
        if hand == null:
            _fail("original animated hand is missing")
            return
        var wrist_a: Vector3 = garment.call("_point", 1.0, 0.0, side, 0)
        var wrist_b: Vector3 = garment.call("_point", 1.0, 0.5, side, 0)
        var wrist_center := (wrist_a + wrist_b) * 0.5
        var hand_center := arm.position + hand.position
        if wrist_center.distance_to(hand_center) > 0.12:
            _fail("skinned cuff terminates away from the original hand")
            return
    if model.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("visual shoulder repair changed collision objects")
        return
    print("SHOULDER SEAM TEST PASSED: real 3D shoulder rings, jacket overlap, wrist alignment, original 13-bone skin and gameplay collision safety")
    quit(0)
