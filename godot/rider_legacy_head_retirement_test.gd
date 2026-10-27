extends SceneTree
## V108 regression: the opaque original glTF head must no longer hide the
## newer 360-degree GPU-skinned face. All other original body surfaces survive.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("HEAD REPLACEMENT TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("bundled original glTF missing")
        return
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    var face := model.get_node_or_null("SculptedSkinnedFace/ContinuousSkinnedFace") as MeshInstance3D
    if rig == null or face == null:
        _fail("original body and replacement face required")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        _fail("13 original bones required")
        return
    if int(rig.get("retired_head_surfaces")) != 3:
        _fail("the three original Skin/Navy/Cyan head occluders must be retired")
        return
    var originals: Array = rig.get("skinned_meshes")
    if originals.is_empty():
        _fail("must preserve imported glTF torso and limbs")
        return
    var surviving := 0
    var has_arms := false
    var has_legs := false
    for source in originals:
        var part := source as MeshInstance3D
        if part == null or part.skin == null or part.skin.get_bind_count() != 13:
            _fail("original body must remain skinned")
            return
        for surface_index in range(part.mesh.get_surface_count()):
            var arrays: Array = part.mesh.surface_get_arrays(surface_index)
            if bool(rig.call("_is_original_head_surface", arrays)):
                _fail("an opaque original head surface still covers the new face")
                return
            surviving += 1
            var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
            var low := INF
            var high := -INF
            if indices.is_empty():
                for point in points:
                    low = minf(low, point.y)
                    high = maxf(high, point.y)
            else:
                for index in indices:
                    low = minf(low, points[index].y)
                    high = maxf(high, points[index].y)
            has_arms = has_arms or (high > 1.3 and low < 1.9)
            has_legs = has_legs or low < 0.9
    if surviving < 15 or not has_arms or not has_legs:
        _fail("retirement removed original body geometry beyond the head")
        return
    if face.skin == null or face.skin.get_bind_count() != 13 or face.get_node_or_null(face.skeleton) != skeleton:
        _fail("replacement head is not attached to original GPU skeleton")
        return
    var mesh_arrays: Array = face.mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = mesh_arrays[Mesh.ARRAY_VERTEX]
    var colors: PackedColorArray = mesh_arrays[Mesh.ARRAY_COLOR]
    if vertices.size() < 6000 or colors.size() != vertices.size():
        _fail("replacement must have a shaded sculpted 360-degree head")
        return
    var expressions := model.get_node_or_null("ExpressiveFace") as Node3D
    if expressions == null or expressions.get_node_or_null("LeftEye") == null or expressions.get_node_or_null("RightEye") == null:
        _fail("blinking eyes must remain visible")
        return
    for name in ["SculptedNose", "Cheek0", "Cheek1"]:
        var old := expressions.get_node_or_null(name) as MeshInstance3D
        if old == null or old.visible:
            _fail("old floating face spheres still overlap the new head")
            return
    if rig.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("head retirement must not alter collision or touch")
        return
    print("HEAD REPLACEMENT TEST PASSED: 3 old occluding glTF head surfaces retired, original 13-bone torso/limbs and new skinned head retained")
    quit(0)
