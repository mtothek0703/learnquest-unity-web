extends SceneTree
## Regression: actual CC0 Skin, closed curved shoulder volumes, real arm pose.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("EXTERNAL PAULDRON TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or adapter == null:
        _fail("opt-in genuine CC0 hero not installed")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    var controller := hero.get_node_or_null("ExternalSkinnedFlightPauldrons") as Node
    if rig == null or rig.get_bone_count() < 60 or source == null or controller == null:
        _fail("original rig/source or new shoulder assembly missing")
        return
    var parts: Array = controller.get("shells")
    # The weighted arm surface, not the synthetic caps, is now the default
    # visible shoulder. Keep caps available only for controlled A/B QA.
    var sleeves_controller := hero.get_node_or_null("ExternalSkinnedFlightSleeves") as Node
    if sleeves_controller == null or not bool(controller.get("sleeve_integration_active")):
        _fail("two real skinned sleeves must replace the redundant outer shoulder caps")
        return
    var actual_sleeves: Array = sleeves_controller.get("sleeves")
    if actual_sleeves.size() != 2 or (actual_sleeves[0] as MeshInstance3D).skin != source.skin or \
            (actual_sleeves[1] as MeshInstance3D).skin != source.skin:
        _fail("integrated sleeves must share the imported 65-bone Skin")
        return
    for cap in parts:
        if (cap as MeshInstance3D).visible:
            _fail("redundant parametric shoulder cap still occludes the source-weighted sleeve")
            return
    if parts.size() != 2 or int(controller.get("generated_vertices")) < 5500:
        _fail("need two substantial closed, low-profile shoulder caps")
        return
    var bounds := source.mesh.get_aabb()
    if float(controller.get("shoulder_span")) < bounds.size.x * 0.46 or \
            float(controller.get("shoulder_span")) > bounds.size.x * 0.49:
        _fail("sculpted shoulder silhouette not broad enough")
        return
    var influenced := 0
    var midsection_hits := 0
    var tapered_end_hits := 0
    for part in parts:
        var shell := part as MeshInstance3D
        if shell == null or shell.mesh == null or shell.skin != source.skin or shell.skeleton != source.skeleton:
            _fail("shoulder volume must retain the original GPU Skin and Skeleton3D")
            return
        if shell.get_parent() != source.get_parent() or shell.material_override is not ShaderMaterial:
            _fail("skinned shoulder not installed beside original source mesh")
            return
        var shell_bounds := shell.mesh.get_aabb()
        if shell_bounds.size.x < bounds.size.x * 0.108 or shell_bounds.size.x > bounds.size.x * 0.125 or \
                shell_bounds.size.z < bounds.size.x * 0.12 or shell_bounds.size.z > bounds.size.x * 0.16 or \
                shell_bounds.size.y > bounds.size.y * 0.13:
            _fail("shoulder shell must be a curved 3D volume, not a flat plate")
            return
        var arrays: Array = shell.mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        if vertices.size() < 2800 or weights.size() != vertices.size() * 4 or bones.size() != weights.size() or colors.size() != vertices.size() or \
                normals.size() != vertices.size() or normals[2].dot(normals[7]) < 0.995:
            _fail("missing dense curved mesh, normals, colors or four-weight skin")
            return
        var center_x := shell_bounds.get_center().x
        for i in range(vertices.size()):
            # The new cap is a tapered deltoid, not a uniform inflated tube.
            # Test the real 3D mesh in imported rest space, not shader colors.
            var normalized_y := (vertices[i].y - shell_bounds.position.y) / maxf(shell_bounds.size.y, 0.0001)
            var radial_x := absf(vertices[i].x - center_x)
            if normalized_y > 0.30 and normalized_y < 0.70 and radial_x > bounds.size.x * 0.042:
                midsection_hits += 1
            if (normalized_y < 0.05 or normalized_y > 0.95) and radial_x > bounds.size.x * 0.042:
                tapered_end_hits += 1
            var sum_weight := 0.0
            for slot in range(4):
                var index := bones[i * 4 + slot]
                var weight := weights[i * 4 + slot]
                if index < 0 or index >= source.skin.get_bind_count() or weight < -0.0001:
                    _fail("invalid source-Skin binding")
                    return
                sum_weight += weight
                if slot == 2 and weight > 0.25:
                    influenced += 1
            if absf(sum_weight - 1.0) > 0.002:
                _fail("weights do not sum to one")
                return
    if midsection_hits < 200 or tapered_end_hits > midsection_hits / 3:
        _fail("deltoid caps must swell through the shoulder and taper toward both ends")
        return
    if influenced < 2000:
        _fail("shoulder shell must follow actual upper-arm bones")
        return
    if hero.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("visual shoulder work must not alter collisions")
        return
    var arm_id := rig.find_bone("upperarm_l")
    var before := rig.get_bone_pose_rotation(arm_id)
    rider.set("lean", 0.85)
    rider.set("boosting", true)
    adapter.call("_process", 0.30)
    if rig.get_bone_pose_rotation(arm_id).angle_to(before) < 0.04:
        _fail("original arm pose must still respond to steer and boost")
        return
    # Regression for the full front/chase silhouette, not isolated shells.
    var mantle := hero.get_node_or_null("ExternalSkinnedFlightMantle") as Node
    var thrusters := hero.get_node_or_null("ExternalSkinnedShoulderThrusters") as Node
    if mantle == null or thrusters == null:
        _fail("integrated streamlined shoulder/coat assembly missing")
        return
    var mantle_fraction := float(mantle.get("mantle_span")) / bounds.size.y
    var thruster_fraction := float(thrusters.get("shoulder_span")) / bounds.size.x
    if mantle_fraction < 0.38 or mantle_fraction > 0.40 or \
            thruster_fraction < 0.44 or thruster_fraction > 0.49:
        _fail("compact mantle and recessed thrusters must fit the skinned shoulders together")
        return
    print("EXTERNAL PAULDRON TEST PASSED: %d vertices, two QA-only shoulder caps retired behind real four-weight sleeves; animated arms" % int(controller.get("generated_vertices")))
    quit(0)
