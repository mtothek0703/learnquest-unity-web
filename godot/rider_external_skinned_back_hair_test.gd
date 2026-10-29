extends SceneTree
## V124: original CC0 GPU Skin must deform the continuous rear hair shell.
## Unlike the previous rigid Head attachment, the lower shell has genuine
## neck/spine influences, without replacing any original glTF bone or Skin.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("TRUE SKINNED BACK HAIR TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var pose := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or pose == null:
        _fail("imported hero or original bone controller unavailable")
        return
    var rig := pose.get("skeleton") as Skeleton3D
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if rig == null or rig.get_bone_count() != 65 or source == null or source.skin == null:
        _fail("original 65-bone skinned CC0 body must remain intact")
        return
    var headwear := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    var controller := hero.get_node_or_null("ExternalSkinnedBackHair") as Node
    if headwear == null or controller == null:
        _fail("weighted back-hair controller or original Head attachment missing")
        return
    var old := headwear.get_node_or_null("SculptedBackHairCurtain") as MeshInstance3D
    var new_hair := controller.get("curtain") as MeshInstance3D
    if old == null or old.mesh == null or old.visible:
        _fail("original head-attached shell must be retained but hidden after success")
        return
    if new_hair == null or new_hair.mesh == null or not new_hair.visible:
        _fail("true GPU-skinned rear hair replacement is missing")
        return
    if new_hair.skin != source.skin or new_hair.skeleton != source.skeleton or \
            new_hair.get_parent() != source.get_parent() or \
            not new_hair.transform.is_equal_approx(source.transform):
        _fail("hair must share original body Skin, skeleton path and rest transform")
        return
    if int(controller.get("vertex_count")) < 2000:
        _fail("continuous hair must use substantial source geometry")
        return
    var bindings := PackedInt32Array()
    for name in ["Head", "neck_01", "spine_02", "spine_01"]:
        var index: int = controller.call("_bind", source.skin, rig, name)
        if index < 0:
            _fail("missing original imported joint " + name)
            return
        bindings.append(index)
    var arrays: Array = new_hair.mesh.surface_get_arrays(0)
    var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
    var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
    if points.size() < 2000 or normals.size() != points.size() or \
            weights.size() != points.size() * 4 or \
            bones.size() != points.size() * 4 or colors.size() != points.size() or \
            uvs.size() != points.size():
        _fail("hair must contain normals, vertex colors and four GPU skin influences")
        return
    for i in range(points.size()):
        if not points[i].is_finite() or not normals[i].is_finite() or \
                absf(normals[i].length() - 1.0) > 0.015:
            _fail("invalid skinned hair rest geometry or normal")
            return
        if not uvs[i].is_finite() or uvs[i].x < 0.0 or uvs[i].x > 1.0 or \
                uvs[i].y < 0.0 or uvs[i].y > 1.0:
            _fail("sculpted scalp-to-tip wind coordinates must be finite and normalized")
            return
        var total := 0.0
        for j in range(4):
            if bones[i * 4 + j] != bindings[j] or weights[i * 4 + j] <= 0.0:
                _fail("hair must use four real imported head/neck/spine influences")
                return
            total += weights[i * 4 + j]
        if absf(total - 1.0) > 0.001:
            _fail("hair GPU skin weights not normalized")
            return
    var root_weights: PackedFloat32Array = controller.call("_weights", 0.0)
    var tip_weights: PackedFloat32Array = controller.call("_weights", 1.0)
    if root_weights[0] < 0.95 or tip_weights[0] > 0.62 or \
            tip_weights[1] < root_weights[1] * 5.0 or \
            tip_weights[2] < root_weights[2] * 5.0:
        _fail("hair root must follow Head and ends must deform with neck/spine")
        return
    var wind := new_hair.material_override as ShaderMaterial
    if wind == null or wind.shader == null or \
            not wind.shader.code.contains("smoothstep(0.14, 0.98, UV.y)") or \
            not wind.shader.code.contains("hair_dye = COLOR"):
        _fail("weighted hair needs a root-anchored one-pass vertex-color wind shader")
        return
    if controller.get("wind_material") != wind:
        _fail("the wind controller must drive the installed skinned material")
        return
    var original_dye := old.material_override as StandardMaterial3D
    var weighted_dye: Color = wind.get_shader_parameter("hair_base_tint")
    if original_dye == null or not weighted_dye.is_equal_approx(original_dye.albedo_color):
        _fail("shader must retain original dark chestnut hair albedo; never render white")
        return
    controller.call("set_motion", 0.8, 1.0, 0.5, 3.0)
    if absf(float(wind.get_shader_parameter("steer_amount")) - 0.8) > 0.001 or \
            absf(float(wind.get_shader_parameter("boost_amount")) - 1.0) > 0.001 or \
            absf(float(wind.get_shader_parameter("jump_amount")) - 0.5) > 0.001 or \
            absf(float(wind.get_shader_parameter("motion_phase")) - 3.0) > 0.001:
        _fail("hair wind must respond to carve, boost, jump and elapsed phase")
        return
    controller.call("set_motion", -2.0, 0.0, 0.0, -1.0)
    if float(wind.get_shader_parameter("steer_amount")) != -1.0 or \
            float(wind.get_shader_parameter("motion_phase")) != 0.0:
        _fail("hair wind inputs must be bounded for mobile stability")
        return
    if headwear.find_children("WindSweptBackLock*", "MeshInstance3D", false, false).size() != 5:
        _fail("expressive animated hair locks must remain attached to Head")
        return
    var head_id := rig.find_bone("Head")
    var neck_id := rig.find_bone("neck_01")
    var before := rig.get_bone_pose_rotation(head_id)
    rider.set("lean", 0.85)
    rider.set("boosting", true)
    rider.position.y = 0.70
    pose.call("_process", 0.30)
    if rig.get_bone_pose_rotation(head_id).angle_to(before) < 0.03 or \
            rig.get_bone_pose_rotation(neck_id).get_angle() < 0.03:
        _fail("hair must retain genuinely animated original head/neck joints")
        return
    if hero.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("cosmetic skinned hair must not add gameplay collisions")
        return
    print("TRUE SKINNED BACK HAIR TEST PASSED: 65 original bones, four-weight head/neck/spine hair, root-anchored GPU wind and animated rig")
    quit(0)
