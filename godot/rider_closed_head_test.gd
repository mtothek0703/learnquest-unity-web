extends SceneTree
## V105: true closed cranial volume and shared GPU skin, not a flat face panel.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("CLOSED HEAD TEST FAILED: " + message)
    quit(1)

func _front_z(points: PackedVector3Array, x: float, y: float) -> float:
    var distance := INF
    var z := INF
    for p in points:
        if p.z >= -0.20:
            continue
        var error := absf(p.x - x) + absf(p.y - y)
        if error < distance:
            distance = error
            z = p.z
    return z

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("imported rider missing")
        return
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    var face := model.get_node_or_null("SculptedSkinnedFace") as Node3D
    var hair := model.get_node_or_null("SculptedSkinnedHair") as Node3D
    var helmet := model.get_node_or_null("AnimatedHeadKinematics") as Node3D
    if rig == null or face == null or hair == null or helmet == null:
        _fail("original rig, skinned head, hair and helmet must coexist")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    var mesh := face.get_node_or_null("ContinuousSkinnedFace") as MeshInstance3D
    if skeleton == null or mesh == null or mesh.skin == null or mesh.skin.get_bind_count() != 13:
        _fail("full head must have original 13-bone GPU skin")
        return
    if mesh.get_node_or_null(mesh.skeleton) != skeleton:
        _fail("head must use original skeleton, not a separate fake rig")
        return
    var arrays: Array = mesh.mesh.surface_get_arrays(0)
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
    if points.size() < 10000 or bones.size() != points.size() * 4 or weights.size() != bones.size() or normals.size() != points.size() or colors.size() != points.size():
        _fail("complete head needs shaded, dense, four-weight geometry")
        return
    var min_z := INF
    var max_z := -INF
    var min_x := INF
    var max_x := -INF
    var back_count := 0
    var side_count := 0
    var neck_count := 0
    for i in range(points.size()):
        var p := points[i]
        min_z = minf(min_z, p.z)
        max_z = maxf(max_z, p.z)
        min_x = minf(min_x, p.x)
        max_x = maxf(max_x, p.x)
        if p.z > 0.28:
            back_count += 1
        if absf(p.x) > 0.39:
            side_count += 1
        if p.y < 2.12 and weights[i * 4 + 1] > 0.20:
            neck_count += 1
        var total := 0.0
        for slot in range(4):
            var index := i * 4 + slot
            if bones[index] < 0 or bones[index] >= 13 or weights[index] < 0.0:
                _fail("invalid skin influence")
                return
            total += weights[index]
        if absf(total - 1.0) > 0.002:
            _fail("head/neck skin weights not normalized")
            return
    if min_z > -0.47 or max_z < 0.43 or min_x > -0.42 or max_x < 0.42:
        _fail("360-degree head volume absent")
        return
    if back_count < 700 or side_count < 700 or neck_count < 100:
        _fail("back of head, temples or blended neck missing")
        return
    var socket := _front_z(points, 0.17, 2.49)
    var cheek := _front_z(points, 0.17, 2.33)
    var nose := _front_z(points, 0.0, 2.35)
    if socket == INF or cheek == INF or nose == INF or socket < cheek + 0.03 or nose > cheek - 0.015:
        _fail("eye sockets must recede and nose must project")
        return
    var material := mesh.material_override as StandardMaterial3D
    if material == null or not material.vertex_color_use_as_albedo or material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
        _fail("head must have physically shaded vertex colors")
        return
    if face.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("head must not alter collisions or touch")
        return
    var before := skeleton.get_bone_global_pose(4)
    rider.set("lean", 0.85)
    rider.set("boosting", true)
    rider.position.y = 1.0
    rig.call("_process", 0.3)
    var after := skeleton.get_bone_global_pose(4)
    if before.basis.get_rotation_quaternion().angle_to(after.basis.get_rotation_quaternion()) < 0.02:
        _fail("head must animate with original moving bones")
        return
    print("CLOSED HEAD TEST PASSED: 360-degree volume, facial relief, original GPU skin, no collisions")
    quit(0)
