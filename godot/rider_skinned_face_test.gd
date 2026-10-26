extends SceneTree
## V102: ensure the continuous face is a REAL skinned surface, not a rigid
## cosmetic plate, and does not cover animated eyes or alter gameplay.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("SKINNED FACE TEST FAILED: " + message)
    quit(1)

func _deformed(mesh: MeshInstance3D, vertex_index: int, rig: Skeleton3D) -> Vector3:
    var arrays: Array = mesh.mesh.surface_get_arrays(0)
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var result := Vector3.ZERO
    for slot in range(4):
        var index := vertex_index * 4 + slot
        var bone_id := bones[index]
        result += (rig.get_bone_global_pose(bone_id) * mesh.skin.get_bind_pose(bone_id) * points[vertex_index]) * weights[index]
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
    var face := model.get_node_or_null("SculptedSkinnedFace") as Node3D
    var expressions := model.get_node_or_null("ExpressiveFace") as Node3D
    if rig == null or face == null or expressions == null:
        _fail("skinned face, expressions and original rig must coexist")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    var mesh := face.get_node_or_null("ContinuousSkinnedFace") as MeshInstance3D
    if skeleton == null or mesh == null or mesh.skin == null or mesh.skin.get_bind_count() != 13:
        _fail("continuous face must share all 13 original bones")
        return
    if mesh.get_node_or_null(mesh.skeleton) != skeleton:
        _fail("face must not use an independent fake rig")
        return
    var arrays: Array = mesh.mesh.surface_get_arrays(0)
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var ids: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
    if points.size() < 4000 or ids.size() != points.size() * 4 or weights.size() != ids.size() or normals.size() != points.size() or colors.size() != points.size():
        _fail("continuous shaded skin needs high-resolution mesh, normals, colors and four weights")
        return
    var min_x := INF
    var max_x := -INF
    var min_y := INF
    var max_y := -INF
    var neck_vertices := 0
    var head_vertices := 0
    for i in range(points.size()):
        min_x = minf(min_x, points[i].x)
        max_x = maxf(max_x, points[i].x)
        min_y = minf(min_y, points[i].y)
        max_y = maxf(max_y, points[i].y)
        var total := 0.0
        for slot in range(4):
            var id := ids[i * 4 + slot]
            var weight := weights[i * 4 + slot]
            if id < 0 or id >= 13 or weight < 0.0:
                _fail("invalid head/neck skin weights")
                return
            total += weight
            if id == 3 and weight > 0.10:
                neck_vertices += 1
            if id == 4 and weight > 0.60:
                head_vertices += 1
        if absf(total - 1.0) > 0.002:
            _fail("head/neck weights must sum to one")
            return
    if min_x > -0.35 or max_x < 0.35 or min_y > 2.14 or max_y < 2.76 or neck_vertices < 100 or head_vertices < 1000:
        _fail("full sculpted cheek/jaw/forehead topology and blended neck required")
        return
    var face_material := mesh.material_override as StandardMaterial3D
    if face_material == null or not face_material.vertex_color_use_as_albedo or face_material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
        _fail("face must be physically shaded with authored vertex colors")
        return
    for name in ["Cheek0", "Cheek1", "SculptedNose"]:
        var old := expressions.get_node_or_null(name) as MeshInstance3D
        if old == null or old.visible:
            _fail("floating old facial spheres must be hidden: " + name)
            return
    for name in ["LeftEye", "RightEye", "LeftBrow", "RightBrow", "CurvedSmile"]:
        var feature := expressions.get_node_or_null(name) as Node3D
        if feature == null or not feature.visible:
            _fail("animated eye, brow or smile must stay visible: " + name)
            return
    if face.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("face must not alter touch or collisions")
        return
    var before := _deformed(mesh, 0, skeleton)
    rider.set("lean", 0.95)
    rider.set("boosting", true)
    rider.position.y = 1.05
    rig.call("_process", 0.3)
    var after := _deformed(mesh, 0, skeleton)
    if before.distance_to(after) < 0.025:
        _fail("facial skin must deform with the original moving head/neck bones")
        return
    print("SKINNED FACE TEST PASSED: continuous shaded head/neck mesh, 13-bone skin, preserved eyes, no collisions")
    quit(0)
