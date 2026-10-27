extends SceneTree
## V124 gate: real third-party 65-bone CC0 skin + animated hoverboard poses.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("QUATERNIUS RIG TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    if not ResourceLoader.exists("res://models/quaternius_hero.glb"):
        _fail("verified CC0 GLB not installed before Godot import")
        return
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var imported := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    var legacy := rider.get_node_or_null("ImportedRider") as Node3D
    if imported == null or adapter == null or legacy == null:
        _fail("external hero, animation adapter or legacy fallback missing")
        return
    if not imported.visible or legacy.visible:
        _fail("only real imported CC0 character may be visible when selected")
        return
    var rig: Skeleton3D = adapter.get("skeleton")
    var meshes: Array = adapter.get("skinned_meshes")
    if rig == null or rig.get_bone_count() < 50 or meshes.is_empty():
        _fail("need actual imported humanoid skeleton and skinned mesh")
        return
    var weighted := 0
    for item in meshes:
        var mesh := item as MeshInstance3D
        if mesh == null or mesh.skin == null or mesh.skin.get_bind_count() < 50:
            _fail("GPU skin must retain original imported bind poses")
            return
        for s in range(mesh.mesh.get_surface_count()):
            var arrays: Array = mesh.mesh.surface_get_arrays(s)
            var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
            var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
            if weights.size() < verts.size() * 4 or bones.size() < verts.size() * 4:
                continue
            for i in range(verts.size()):
                var sum_weight := 0.0
                for slot in range(4):
                    var weight := weights[i * 4 + slot]
                    var bone_id := bones[i * 4 + slot]
                    if bone_id < 0 or bone_id >= rig.get_bone_count() or weight < 0.0:
                        _fail("invalid imported skin weight / bone index")
                        return
                    sum_weight += weight
                if absf(sum_weight - 1.0) < 0.03:
                    weighted += 1
    if weighted < 1000:
        _fail("imported character must have >1000 normalized skinned vertices, found %d" % weighted)
        return
    if imported.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("new visual asset must not add collision or gameplay objects")
        return
    if rider.get_node_or_null("LegacyRider") == null:
        _fail("the existing hoverboard / touch visual controller disappeared")
        return
    var headwear := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if headwear == null:
        _fail("real Head bone must carry the new curved headgear")
        return
    # Preserve a compact, stylized rider-to-board proportion while fitting
    # the imported GLB using its real mesh bounds (not fixed asset units).
    var low := INF
    var high := -INF
    for item in meshes:
        var body := item as MeshInstance3D
        var aabb := body.get_aabb()
        for x in [aabb.position.x, aabb.end.x]:
            for y in [aabb.position.y, aabb.end.y]:
                for z in [aabb.position.z, aabb.end.z]:
                    var point := imported.to_local(body.to_global(Vector3(x, y, z)))
                    low = minf(low, point.y)
                    high = maxf(high, point.y)
    var scaled_height := (high - low) * imported.scale.y
    if absf(scaled_height - 2.72) > 0.035:
        _fail("original skinned character must keep the readable mobile hoverboard proportion")
        return
    var front_sign := float(headwear.get("face_sign"))
    var expected_facing := PI if front_sign > 0.0 else 0.0
    if absf(imported.rotation.y - expected_facing) > 0.01:
        _fail("new character must face menu camera using imported eye geometry")
        return
    var suit_mesh := imported.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if suit_mesh == null or not (suit_mesh.material_override is ShaderMaterial):
        _fail("real skinned body must have original procedural flight-suit material")
        return
    var left_arm := rig.find_bone("upperarm_l")
    if left_arm < 0:
        _fail("missing original humanoid left upper arm")
        return
    adapter.call("_process", 0.20)
    if rig.get_bone_pose_rotation(left_arm).get_angle() < 0.60:
        _fail("hoverboard idle must lower the source T-pose arms")
        return
    var head_id := rig.find_bone("Head")
    var head_before := rig.get_bone_pose_rotation(head_id)
    rider.set("lean", 0.85)
    rider.set("boosting", true)
    rider.position.y = 0.90
    adapter.call("_process", 0.32)
    if rig.get_bone_pose_rotation(head_id).angle_to(head_before) < 0.05:
        _fail("the imported real head bone did not animate")
        return
    rider.set("lean", 0.0)
    rider.set("boosting", false)
    rider.position.y = 0.0
    adapter.call("_process", 0.40)
    if rig.get_bone_pose_rotation(head_id).angle_to(head_before) > 0.03:
        _fail("the imported head must return to neutral")
        return
    # Missing/invalid external file must fail open to the working V123 rider.
    var fallback := preload("res://rider_character.tscn").instantiate() as Node3D
    fallback.set("prefer_cc0_rigged_hero", true)
    fallback.set("cc0_hero_asset_path", "res://models/not_a_character.glb")
    root.add_child(fallback)
    await process_frame
    var fallback_model := fallback.get_node_or_null("ImportedRider") as Node3D
    if fallback_model == null or not fallback_model.visible or fallback.get_node_or_null("ExternalRiggedHero") != null:
        _fail("missing external asset must preserve the original working character")
        return
    print("QUATERNIUS RIG TEST PASSED: %d genuine imported bones, %d weighted vertices, live pose and safe fallback" % [rig.get_bone_count(), weighted])
    quit(0)
