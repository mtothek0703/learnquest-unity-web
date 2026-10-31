extends SceneTree
## V124: verify the new continuous neck/shoulder geometry is actually skinned,
## fitted to the imported 65-bone CC0 hero and keeps the face unobscured.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("EXTERNAL SKINNED NECK YOKE TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var pose := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or pose == null:
        _fail("real imported CC0 hero/pose adapter missing")
        return
    var rig := pose.get("skeleton") as Skeleton3D
    var yoke := hero.get_node_or_null("ExternalSkinnedNeckYoke") as Node
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if rig == null or rig.get_bone_count() < 50 or yoke == null or source == null:
        _fail("65-bone skeleton or skinned neck yoke missing")
        return
    var mesh := yoke.get("collar") as MeshInstance3D
    if mesh == null or mesh.mesh == null or mesh.skin != source.skin or             mesh.skeleton != source.skeleton or mesh.get_parent() != source.get_parent():
        _fail("neck/shoulder yoke must share imported GPU Skin and Skeleton")
        return
    if mesh.mesh.get_surface_count() != 1:
        _fail("collar must use one continuous mobile-friendly mesh")
        return
    var arrays: Array = mesh.mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    if vertices.size() < 5000 or weights.size() != vertices.size() * 4 or             bones.size() != vertices.size() * 4:
        _fail("closed yoke lacks real four-influence skinned surface")
        return
    for i in range(vertices.size()):
        var total := 0.0
        for j in range(4):
            var index := i * 4 + j
            if bones[index] < 0 or bones[index] >= source.skin.get_bind_count() or                     weights[index] < 0.0:
                _fail("invalid original Skin bind at vertex " + str(i))
                return
            total += weights[index]
        if absf(total - 1.0) > 0.001:
            _fail("neck yoke weights not normalized")
            return
    var bounds := source.mesh.get_aabb()
    var face := float(yoke.get("face_direction"))
    var front_angle := PI * 0.5 if face > 0.0 else PI * 1.5
    var back_angle := front_angle + PI
    var front: Vector3 = yoke.call("_collar_point", bounds, front_angle, 1.0, false)
    var rear: Vector3 = yoke.call("_collar_point", bounds, back_angle, 1.0, false)
    var outer_base: Vector3 = yoke.call("_collar_point", bounds, 0.0, 0.0, false)
    var outer_top: Vector3 = yoke.call("_collar_point", bounds, 0.0, 1.0, false)
    var inner_top: Vector3 = yoke.call("_collar_point", bounds, 0.0, 1.0, true)
    if rear.y - front.y < bounds.size.y * 0.05 or             front.y > bounds.position.y + bounds.size.y * 0.78:
        _fail("rear collar must rise above open face-protecting V-neck")
        return
    if outer_base.x - outer_top.x < bounds.size.x * 0.06 or             outer_top.x - inner_top.x < bounds.size.x * 0.008:
        _fail("collar must be tapered and have real closed 3D wall thickness")
        return
    # In the real landscape screenshots the former shoulder-width 360-degree
    # collar looked like a thick horizontal flying saucer across the chest.
    # The new mesh must have a compact radial footprint, a lower front V and
    # a raised rear. Keep the original four-weight closure test above.
    if outer_base.x - bounds.get_center().x > bounds.size.x * 0.18 or \
            outer_top.x - bounds.get_center().x > bounds.size.x * 0.12:
        _fail("neck yoke regressed to oversized horizontal shoulder ring")
        return
    if front.y > bounds.position.y + bounds.size.y * 0.76 or \
            rear.y < bounds.position.y + bounds.size.y * 0.80:
        _fail("collar lost low front V or protective raised rear profile")
        return
    var depth_base: Vector3 = yoke.call("_collar_point", bounds, PI * 0.5, 0.0, false)
    if absf(depth_base.z - bounds.get_center().z) > bounds.size.x * 0.14:
        _fail("collar still projects too far forward/back in mobile chase view")
        return
    var head_id := rig.find_bone("Head")
    var neck_id := rig.find_bone("neck_01")
    if head_id < 0 or neck_id < 0:
        _fail("original Head/neck joints unavailable")
        return
    var original_head := rig.get_bone_pose_rotation(head_id)
    rider.set("lean", 0.85)
    pose.call("_process", 0.25)
    if rig.get_bone_pose_rotation(head_id).angle_to(original_head) < 0.03:
        _fail("collar must coexist with real animated Head pose")
        return
    if hero.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("visual collar must not add gameplay collision")
        return
    print("EXTERNAL SKINNED NECK YOKE TEST PASSED: closed open-front 65-bone collar, four normalized original Skin weights, animated Head")
    quit(0)
