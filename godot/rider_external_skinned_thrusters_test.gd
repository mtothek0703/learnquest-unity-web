extends SceneTree
## V124: prove the wider shoulder hardware is genuinely skinned, visible
## behind the rider, and cannot change collision, touch or game rules.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("EXTERNAL SKINNED THRUSTERS TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var pose := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or pose == null:
        _fail("real CC0 rigged hero or pose adapter missing")
        return
    var rig := pose.get("skeleton") as Skeleton3D
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    var controller := hero.get_node_or_null("ExternalSkinnedShoulderThrusters") as Node
    if rig == null or rig.get_bone_count() < 60 or source == null or controller == null:
        _fail("original 65-bone source or skinned shoulder controller missing")
        return
    var headwear := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if headwear == null or float(headwear.get("visual_scale")) < 1.89 or float(headwear.get("visual_scale")) > 1.95:
        _fail("balanced Head-bone portrait must remain visible above the weighted shoulder hardware")
        return
    var shells: Array = controller.get("nacelles")
    var cores: Array = controller.get("cores")
    if shells.size() != 2 or cores.size() != 2:
        _fail("both shoulders need a weighted nacelle and illuminated core")
        return
    if float(controller.get("shoulder_span")) < source.mesh.get_aabb().size.x * 0.44:
        _fail("shoulder geometry does not cover enough of chase silhouette")
        return
    if float(controller.get("shoulder_span")) > source.mesh.get_aabb().size.x * 0.49:
        _fail("shoulder nacelles must remain recessed inside the fitted armor silhouette")
        return
    if int(controller.get("generated_vertices")) < 6000:
        _fail("shoulder modules lack substantial actual 3D geometry")
        return
    # The original large glowing shoulder cylinders read as headphones in
    # the chase camera. This gate enforces narrow, recessed, mobile-scale pods.
    var active_arm_weights := 0
    for node in shells + cores:
        var mesh := node as MeshInstance3D
        if mesh == null or mesh.mesh == null or mesh.skin != source.skin:
            _fail("shoulder geometry does not use original imported Skin")
            return
        if mesh.skeleton != source.skeleton or mesh.get_parent() != source.get_parent():
            _fail("shoulder geometry must share the source Skeleton3D")
            return
        if mesh.get_child_count() != 0:
            _fail("shoulder hardware must remain geometry only")
            return
        # The first visual pass produced giant floating purple pods. They
        # must now overlap the actual upper torso rather than hang far away.
        var source_bounds := source.mesh.get_aabb()
        var pod_bounds := mesh.mesh.get_aabb()
        if absf(pod_bounds.get_center().x - source_bounds.get_center().x) > source_bounds.size.x * 0.34:
            _fail("shoulder nacelle is detached from the actual torso")
            return
        if pod_bounds.size.x > source_bounds.size.x * 0.17 or \
                pod_bounds.size.z > source_bounds.size.x * 0.15 or \
                pod_bounds.size.y > source_bounds.size.y * 0.13:
            _fail("shoulder nacelle is oversized for a mobile character")
            return
        var mat := mesh.material_override as StandardMaterial3D
        if mat == null or not mat.emission_enabled or \
                mat.emission_energy_multiplier > (1.10 if String(mesh.name).contains("Core") else 0.20):
            _fail("shoulder hardware needs emissive mobile-friendly materials")
            return
        var arrays: Array = mesh.mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        if vertices.size() < 1000 or weights.size() != vertices.size() * 4 or bones.size() != vertices.size() * 4 or \
                normals.size() != vertices.size() or normals[2].dot(normals[7]) < 0.995:
            _fail("missing real four-weight GPU skinning on nacelle/core")
            return
        for i in range(vertices.size()):
            var sum := 0.0
            for j in range(4):
                var index := bones[i * 4 + j]
                if index < 0 or index >= source.skin.get_bind_count():
                    _fail("invalid imported Skin index")
                    return
                var weight := weights[i * 4 + j]
                if weight < -0.001:
                    _fail("negative skinning weight")
                    return
                sum += weight
                if j == 2 and weight > 0.1:
                    active_arm_weights += 1
            if absf(sum - 1.0) > 0.002:
                _fail("shoulder Skin weights not normalized")
                return
    if active_arm_weights < 1000:
        _fail("shoulder shells do not actually follow the arm joints")
        return
    if hero.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("visual upgrade must not add gameplay collisions")
        return
    var arm_id := rig.find_bone("upperarm_l")
    if arm_id < 0:
        _fail("original shoulder bone missing")
        return
    var before := rig.get_bone_pose_rotation(arm_id)
    rider.set("lean", 0.9)
    rider.set("boosting", true)
    pose.call("_process", 0.35)
    if rig.get_bone_pose_rotation(arm_id).angle_to(before) < 0.04:
        _fail("shoulder modules cannot follow animated imported shoulder")
        return
    if rider.get_node_or_null("LegacyRider") == null:
        _fail("V123 fallback and board must remain intact")
        return
    print("EXTERNAL SKINNED THRUSTERS TEST PASSED: %d vertices, two real weighted shoulder nacelles and cores, larger readable head" % int(controller.get("generated_vertices")))
    quit(0)
