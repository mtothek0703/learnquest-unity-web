extends SceneTree
## V99 regression: five sculpted suit surfaces and their luminous piping
## must share the original 13-bone GPU skin, deform and stay visual-only.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("SCULPTED SUIT TEST FAILED: " + message)
    quit(1)

func _deformed_point(mesh: MeshInstance3D, vertex_index: int, skeleton: Skeleton3D) -> Vector3:
    var arrays: Array = mesh.mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var result := Vector3.ZERO
    for slot in range(4):
        var index := vertex_index * 4 + slot
        var bone_id := bones[index]
        var transform: Transform3D = skeleton.get_bone_global_pose(bone_id) * mesh.skin.get_bind_pose(bone_id)
        result += (transform * vertices[vertex_index]) * weights[index]
    return result

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    root.add_child(rider)
    await process_frame
    var model := rider.get_node_or_null("ImportedRider") as Node3D
    if model == null:
        _fail("imported original glTF rider missing")
        return
    var rig := model.get_node_or_null("OriginalBodySkinRig") as Node3D
    var suit := model.get_node_or_null("SculptedSkinnedFlightSuit") as Node3D
    if rig == null or suit == null:
        _fail("original body skeleton and sculpted suit must coexist")
        return
    var skeleton := rig.get_node_or_null("OriginalBodySkeleton13") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 13:
        _fail("suit must use the original 13-bone skeleton")
        return
    var shells: Array = suit.get("suit_parts")
    var piping: Array = suit.get("piping_parts")
    if shells.size() != 5 or piping.size() != 5:
        _fail("five anatomically curved suit shells and five neon piping surfaces required")
        return
    var all_parts: Array = []
    all_parts.append_array(shells)
    all_parts.append_array(piping)
    var vertices_total := 0
    var arm_weighted := 0
    var leg_weighted := 0
    var torso_weighted := 0
    for part in all_parts:
        var mesh := part as MeshInstance3D
        if mesh == null or mesh.skin == null or mesh.skin.get_bind_count() != 13:
            _fail("each sculpted surface must be bound to all original bones")
            return
        if mesh.get_node_or_null(mesh.skeleton) != skeleton:
            _fail("suit has a detached or duplicated skeleton")
            return
        if mesh.mesh.get_surface_count() != 1 or not (mesh.mesh is ArrayMesh):
            _fail("suit must use real authored curved triangle geometry")
            return
        var arrays: Array = mesh.mesh.surface_get_arrays(0)
        var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        if points.size() < 150 or bones.size() != points.size() * 4 or weights.size() != bones.size() or normals.size() != points.size():
            _fail("curved geometry, vertex normals and four GPU weights are required")
            return
        vertices_total += points.size()
        for i in range(points.size()):
            var total := 0.0
            for slot in range(4):
                var index := i * 4 + slot
                var id := bones[index]
                var weight := weights[index]
                if id < 0 or id >= 13 or weight < 0.0:
                    _fail("invalid suit bone index or weight")
                    return
                total += weight
                if weight > 0.1:
                    if id <= 3:
                        torso_weighted += 1
                    elif id <= 8:
                        arm_weighted += 1
                    else:
                        leg_weighted += 1
            if absf(total - 1.0) > 0.002:
                _fail("skin weights must sum to one")
                return
    if vertices_total < 6500 or torso_weighted < 300 or arm_weighted < 300 or leg_weighted < 300:
        _fail("insufficient detailed, fully weighted torso/arm/leg surfaces")
        return
    if suit.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("visual suit must never affect touch, physics or collisions")
        return
    var left_arm := shells[1] as MeshInstance3D
    var left_leg := shells[3] as MeshInstance3D
    var before_arm := _deformed_point(left_arm, 0, skeleton)
    var before_leg := _deformed_point(left_leg, 0, skeleton)
    rider.set("lean", 0.95)
    rider.set("boosting", true)
    rider.position.y = 1.05
    rig.call("_process", 0.35)
    var after_arm := _deformed_point(left_arm, 0, skeleton)
    var after_leg := _deformed_point(left_leg, 0, skeleton)
    if before_arm.distance_to(after_arm) < 0.025 or before_leg.distance_to(after_leg) < 0.025:
        _fail("real GPU-skinned arm and leg suit geometry must respond to jump/boost/steering")
        return
    var neon := piping[0] as MeshInstance3D
    var material := neon.material_override as StandardMaterial3D
    if material == null or not material.emission_enabled:
        _fail("sculpted suit needs actual emissive piping")
        return
    print("SCULPTED SUIT TEST PASSED: five curved skinned shells, five emissive strips, normalized weights, deforming limbs, no collisions")
    quit(0)
