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
    if parts.size() != 2 or int(controller.get("generated_vertices")) < 5500:
        _fail("need two substantial closed shoulder volumes")
        return
    var bounds := source.mesh.get_aabb()
    if float(controller.get("shoulder_span")) < bounds.size.x * 0.60:
        _fail("sculpted shoulder silhouette not broad enough")
        return
    var influenced := 0
    for part in parts:
        var shell := part as MeshInstance3D
        if shell == null or shell.mesh == null or shell.skin != source.skin or shell.skeleton != source.skeleton:
            _fail("shoulder volume must retain the original GPU Skin and Skeleton3D")
            return
        if shell.get_parent() != source.get_parent() or shell.material_override is not ShaderMaterial:
            _fail("skinned shoulder not installed beside original source mesh")
            return
        var shell_bounds := shell.mesh.get_aabb()
        if shell_bounds.size.x < bounds.size.x * 0.20 or shell_bounds.size.z < bounds.size.x * 0.22:
            _fail("shoulder shell must be a curved 3D volume, not a flat plate")
            return
        var arrays: Array = shell.mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        if vertices.size() < 2800 or weights.size() != vertices.size() * 4 or bones.size() != weights.size() or colors.size() != vertices.size() or normals.size() != vertices.size():
            _fail("missing dense curved mesh, normals, colors or four-weight skin")
            return
        for i in range(vertices.size()):
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
    print("EXTERNAL PAULDRON TEST PASSED: %d vertices, two closed original-skinned sculpted shoulders and animated arms" % int(controller.get("generated_vertices")))
    quit(0)
