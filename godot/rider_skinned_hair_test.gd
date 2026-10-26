extends SceneTree
## V103: shared original-body GPU hair skin, authored scalp/locks/fringe,
## retained reactive curls and facial readability; visual-only changes.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("SKINNED HAIR TEST FAILED: " + message)
    quit(1)

func _deformed(mesh: MeshInstance3D, vertex_index: int, rig: Skeleton3D) -> Vector3:
    var arrays: Array = mesh.mesh.surface_get_arrays(0)
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var ids: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var result := Vector3.ZERO
    for slot in range(4):
        var offset := vertex_index * 4 + slot
        var bone := ids[offset]
        result += (rig.get_bone_global_pose(bone) *
            mesh.skin.get_bind_pose(bone) * points[vertex_index]) * weights[offset]
    return result

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("imported rider missing")
        return
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    var hair := model.get_node_or_null("SculptedSkinnedHair") as Node3D
    var old := model.get_node_or_null("SculptedVolumetricHair") as Node3D
    var face := model.get_node_or_null("SculptedSkinnedFace") as Node3D
    if rig == null or hair == null or old == null or face == null:
        _fail("face, hair and shared original rig must coexist")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    var mesh := hair.get_node_or_null("UnifiedSkinnedHairSilhouette") as MeshInstance3D
    if skeleton == null or mesh == null or mesh.skin == null:
        _fail("new hair must have an actual GPU skin")
        return
    if mesh.skin.get_bind_count() != 13 or mesh.get_node_or_null(mesh.skeleton) != skeleton:
        _fail("hair must share original 13-bone skeleton, not a duplicate")
        return
    var arrays: Array = mesh.mesh.surface_get_arrays(0)
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
    if points.size() < 11000 or bones.size() != points.size() * 4 or weights.size() != bones.size() or normals.size() != points.size() or colors.size() != points.size():
        _fail("shaded scalp, seven swept locks and bangs need normals, colors and 4 GPU weights")
        return
    var min_y := INF
    var max_y := -INF
    var min_x := INF
    var max_x := -INF
    var min_z := INF
    var max_z := -INF
    var blended_nape := 0
    var rooted_scalp := 0
    for i in range(points.size()):
        min_y = minf(min_y, points[i].y)
        max_y = maxf(max_y, points[i].y)
        min_x = minf(min_x, points[i].x)
        max_x = maxf(max_x, points[i].x)
        min_z = minf(min_z, points[i].z)
        max_z = maxf(max_z, points[i].z)
        var sum := 0.0
        for slot in range(4):
            var offset := i * 4 + slot
            if bones[offset] < 0 or bones[offset] >= 13 or weights[offset] < 0.0:
                _fail("invalid original bone index or negative weight")
                return
            sum += weights[offset]
        if absf(sum - 1.0) > 0.002:
            _fail("hair skin weights must be normalized")
            return
        if weights[i * 4 + 1] > 0.10:
            blended_nape += 1
        if weights[i * 4] > 0.95:
            rooted_scalp += 1
    if min_y > 2.20 or max_y < 3.10 or min_x > -0.43 or max_x < 0.43 or min_z > -0.40 or max_z < 0.75:
        _fail("hair must visibly cover scalp, side-swept locks and front fringe")
        return
    if blended_nape < 300 or rooted_scalp < 1500:
        _fail("nape must blend to Neck while scalp is anchored to Head")
        return
    var material := mesh.material_override as StandardMaterial3D
    if material == null or not material.vertex_color_use_as_albedo or material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
        _fail("hair must use physically shaded authored vertex colors")
        return
    for part in old.get_children():
        if part is MeshInstance3D:
            var name := String(part.name)
            if name == "VolumetricScalp" or name.begins_with("SweptLayer") or name.begins_with("LuminousHairSheen"):
                if part.visible:
                    _fail("rigid overlapping hair plates must be retired")
                    return
    for name in ["LeftTempleCurl", "RightTempleCurl"]:
        var curl := old.get_node_or_null(name) as Node3D
        if curl == null or not curl.visible:
            _fail("reactive temple curls must remain animated")
            return
    if hair.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("new hair must not change collisions or touch")
        return
    var before := _deformed(mesh, points.size() - 1, skeleton)
    rider.set("lean", 0.9)
    rider.set("boosting", true)
    rider.position.y = 1.1
    rig.call("_process", 0.3)
    var after := _deformed(mesh, points.size() - 1, skeleton)
    if before.distance_to(after) < 0.02:
        _fail("sculpted hair must deform with the real moving Head/Neck bones")
        return
    print("SKINNED HAIR TEST PASSED: unified scalp, seven swept locks, face-safe bangs, original rig, preserved curls")
    quit(0)
