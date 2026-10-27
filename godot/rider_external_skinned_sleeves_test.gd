extends SceneTree
## V124: validate real imported-skin upper/lower-arm sleeves, symmetry, bone
## deformation and no changes to game collisions or legacy fallback.
func _initialize() -> void:
    call_deferred("_check")
func _fail(reason: String) -> void:
    push_error("EXTERNAL SKINNED SLEEVES TEST FAILED: " + reason)
    quit(1)
func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or adapter == null:
        _fail("original CC0 rig unavailable")
        return
    var controller := hero.get_node_or_null("ExternalSkinnedFlightSleeves") as Node
    var original := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    var rig := adapter.get("skeleton") as Skeleton3D
    if controller == null or original == null or rig == null or rig.get_bone_count() < 50:
        _fail("sleeves must attach to the genuine 65-bone imported body")
        return
    var sleeves: Array = controller.get("sleeves")
    if sleeves.size() != 2:
        _fail("both arms must be sculpted and GPU skinned")
        return
    var counts: Array = controller.get("arm_vertex_counts")
    if counts.size() != 2 or int(counts[0]) < 150 or int(counts[1]) < 150:
        _fail("missing substantial sculpted source arm triangles")
        return
    var left_count := int(counts[0])
    var right_count := int(counts[1])
    if float(maxi(left_count, right_count)) / float(maxi(1, mini(left_count, right_count))) > 1.4:
        _fail("asymmetric left/right arm mesh extraction")
        return
    for index in range(2):
        var sleeve := sleeves[index] as MeshInstance3D
        if sleeve == null or sleeve.mesh == null or sleeve.skin != original.skin or \
                sleeve.skeleton != original.skeleton or sleeve.get_parent() != original.get_parent():
            _fail("sleeves must reuse the exact original Skin, skeleton and parent")
            return
        var material := sleeve.material_override as ShaderMaterial
        if material == null or material.shader == null or not material.shader.code.contains("shoulder_weight"):
            _fail("mobile sleeve PBR material missing")
            return
        var upper_name := "upperarm_l" if index == 0 else "upperarm_r"
        var lower_name := "lowerarm_l" if index == 0 else "lowerarm_r"
        var upper_bind: int = controller.call("_bind", original.skin, rig, upper_name)
        var lower_bind: int = controller.call("_bind", original.skin, rig, lower_name)
        if upper_bind < 0 or lower_bind < 0:
            _fail("original arm joints missing from Skin")
            return
        var upper_hits := 0
        var lower_hits := 0
        var panel_hits := 0
        var elbow_hits := 0
        for surface in range(sleeve.mesh.get_surface_count()):
            var arrays: Array = sleeve.mesh.surface_get_arrays(surface)
            var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
            var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
            var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
            if verts.size() < 150 or bones.size() != verts.size() * 4 or \
                    weights.size() != verts.size() * 4 or colors.size() != verts.size():
                _fail("sleeves must have full four-weight skinning and original influence zones")
                return
            for i in range(verts.size()):
                var total := 0.0
                for j in range(4):
                    var bind := bones[i * 4 + j]
                    var weight := weights[i * 4 + j]
                    if bind < 0 or bind >= original.skin.get_bind_count() or weight < 0.0:
                        _fail("invalid imported bind index/weight")
                        return
                    if bind == upper_bind and weight > 0.25:
                        upper_hits += 1
                    if bind == lower_bind and weight > 0.25:
                        lower_hits += 1
                    total += weight
                if absf(total - 1.0) > 0.04:
                    _fail("original four skin weights no longer normalized")
                    return
                if colors[i].b > 0.48:
                    panel_hits += 1
                if colors[i].r > 0.32 and colors[i].r < 0.66:
                    elbow_hits += 1
        if panel_hits < 60 or elbow_hits < 25:
            _fail("modeled shoulder/forearm panels or articulated elbow bellows missing")
            return
        if upper_hits < 30 or lower_hits < 30:
            _fail("sleeve lacks genuinely articulated shoulder/elbow geometry")
            return
    # Check actual rest-space sculpt instead of accepting a color-only change.
    # Shoulder armor must be materially thicker than a flat 2-cm skin copy;
    # wrist and elbow profiles must remain distinct for readable articulation.
    var sample_bounds := AABB(Vector3(-0.5, 0.0, -0.5), Vector3(1.0, 2.0, 1.0))
    var shoulder_shape: Vector3 = controller.call("_sculpt_offset",
        Vector3(0.45, 1.5, 0.0), Vector3.RIGHT, sample_bounds, Vector2(1.0, 0.96))
    var elbow_shape: Vector3 = controller.call("_sculpt_offset",
        Vector3(0.45, 1.3, 0.0), Vector3.RIGHT, sample_bounds, Vector2(0.99, 0.48))
    var wrist_shape: Vector3 = controller.call("_sculpt_offset",
        Vector3(0.45, 1.0, 0.0), Vector3.RIGHT, sample_bounds, Vector2(0.20, 0.02))
    if shoulder_shape.x < 0.12 or elbow_shape.x < 0.06 or wrist_shape.x > 0.07:
        _fail("sleeves must have substantial shoulder volume, elbow shaping and a wrist taper")
        return
    var shoulder_panel: float = controller.call("_armor_panel", Vector2(1.0, 0.96))
    var elbow_panel: float = controller.call("_armor_panel", Vector2(1.0, 0.48))
    if shoulder_panel < 0.80 or elbow_panel < 0.55:
        _fail("original-skin armor panel zones are missing")
        return
    if hero.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("visual sleeve redesign must not add collisions")
        return
    var left_arm := rig.find_bone("upperarm_l")
    var before := rig.get_bone_pose_rotation(left_arm)
    rider.set("lean", 0.8)
    rider.set("boosting", true)
    adapter.call("_process", 0.25)
    if rig.get_bone_pose_rotation(left_arm).angle_to(before) < 0.03:
        _fail("real source arm must still animate under the new sleeve")
        return
    if rider.get_node_or_null("LegacyRider") == null:
        _fail("the proven touch/hoverboard fallback was removed")
        return
    print("EXTERNAL SKINNED SLEEVES TEST PASSED: %d+%d original-skin vertices, two sculpted articulated shoulder/elbow/forearm armor zones" % [left_count, right_count])
    quit(0)
