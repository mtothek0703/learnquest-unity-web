extends SceneTree
## V110: rendered V109 showed flat triangular bangs and a forehead scalp seam.
## Assert genuine 3D tapered fringe, scalp clearance, shared GPU skin and eyes.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("VOLUMETRIC FRINGE TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("imported rider missing")
        return
    var hair := model.get_node_or_null("SculptedSkinnedHair") as Node3D
    var head := model.get_node_or_null("SculptedSkinnedFace") as Node3D
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    var face := model.get_node_or_null("ExpressiveFace") as Node3D
    if hair == null or head == null or rig == null or face == null:
        _fail("head, hair, original rig and expressions required")
        return
    var mesh := hair.get_node_or_null("UnifiedSkinnedHairSilhouette") as MeshInstance3D
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if mesh == null or mesh.skin == null or skeleton == null or skeleton.get_bone_count() != 13:
        _fail("fringe must use original 13-bone GPU skin")
        return
    if mesh.skin.get_bind_count() != 13 or mesh.get_node_or_null(mesh.skeleton) != skeleton:
        _fail("hair is not attached to original skeleton")
        return
    var arrays: Array = mesh.mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    if vertices.size() < 15500 or weights.size() != vertices.size() * 4:
        _fail("four new volumetric fringe tubes require substantial skinned geometry")
        return
    for index in range(4):
        var right: Vector3 = hair.call("_fringe_point", 0.1, 0.0, index)
        var left: Vector3 = hair.call("_fringe_point", 0.1, PI, index)
        var front: Vector3 = hair.call("_fringe_point", 0.1, PI * 1.5, index)
        var back: Vector3 = hair.call("_fringe_point", 0.1, PI * 0.5, index)
        var tip_right: Vector3 = hair.call("_fringe_point", 0.98, 0.0, index)
        var tip_left: Vector3 = hair.call("_fringe_point", 0.98, PI, index)
        if right.distance_to(left) < 0.12 or front.distance_to(back) < 0.075:
            _fail("front hair must have circular 3D thickness, not a ribbon")
            return
        if tip_right.distance_to(tip_left) > right.distance_to(left) * 0.45:
            _fail("front lock must taper toward the tip")
            return
        if tip_right.y < 2.70 or tip_right.y > 2.79:
            _fail("fringe tip must stay above eyes and animated brows")
            return
    # At the forehead the scalp must sit OUTSIDE the fuller V109 head.
    var latitude := acos((2.88 - 2.69) / 0.435)
    var scalp: Vector3 = hair.call("_cap_point", latitude / (PI * 0.5), -PI * 0.5)
    var forehead: Vector3 = head.call("_point", (2.88 - 1.98) / 1.10, 0.5)
    if scalp.z > forehead.z - 0.012:
        _fail("expanded face penetrates the front hair cap")
        return
    for name in ["LeftEye", "RightEye", "LeftBrow", "RightBrow", "CurvedSmile"]:
        if face.get_node_or_null(name) == null:
            _fail("facial expression missing: " + name)
            return
    if model.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("visual fringe must not alter collision or touch")
        return
    print("VOLUMETRIC FRINGE TEST PASSED: four tapered skinned 3D locks, scalp clears cranium, expressions and collisions preserved")
    quit(0)
