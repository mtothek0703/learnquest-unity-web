extends SceneTree
## V124: real Head-bone continuous hair sculpt, vertex paint, normals and
## imported four-weight CC0 Skin must coexist without gameplay collisions.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("CONTINUOUS BACK HAIR SCULPT TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if adapter == null:
        _fail("external rigged hero adapter missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    var source_meshes: Array = adapter.get("skinned_meshes")
    if rig == null or rig.get_bone_count() != 65 or source_meshes.is_empty():
        _fail("original CC0 65-bone skinned character was lost")
        return
    var headwear := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if headwear == null or headwear.bone_name != "Head":
        _fail("sculpted hair must follow the original Head bone")
        return
    var curtain := headwear.get_node_or_null("SculptedBackHairCurtain") as MeshInstance3D
    if curtain == null or curtain.mesh == null or curtain.mesh.get_surface_count() != 1:
        _fail("one continuous closed rear hair shell is required")
        return
    var material := curtain.material_override as StandardMaterial3D
    if material == null or not material.vertex_color_use_as_albedo or material.roughness < 0.80:
        _fail("continuous matte hair must use actual vertex-painted relief")
        return
    var arrays: Array = curtain.mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
    if vertices.size() < 5800 or normals.size() != vertices.size() or colors.size() != vertices.size():
        _fail("closed five-channel shell lacks sculpted geometry, normals or vertex paint")
        return
    var low := 2.0
    var high := -1.0
    for i in range(vertices.size()):
        if not vertices[i].is_finite() or not normals[i].is_finite() or absf(normals[i].length() - 1.0) > 0.035:
            _fail("invalid hair vertex or smooth normal")
            return
        low = minf(low, colors[i].r)
        high = maxf(high, colors[i].r)
    if high - low < 0.13:
        _fail("five hair streams lost their sculpt-following painted highlights")
        return
    var sculpt := preload("res://rider_external_back_hair_sculpt.gd").new()
    if sculpt.channel_count() != 5:
        _fail("the continuous shell must have five flowing channels")
        return
    var region: AABB = headwear.get("head_bounds")
    var size := region.size
    var facing := float(headwear.get("face_sign"))
    var peak := sculpt.sculpt(Vector3.ZERO, size, facing, 0.5, 0.1, true)
    var groove := sculpt.sculpt(Vector3.ZERO, size, facing, 0.5, 0.2, true)
    if absf(peak.z - groove.z) < size.z * 0.045:
        _fail("rear silhouette must have genuine modeled depth, not painted stripes")
        return
    for strand in range(5):
        var u := (float(strand) + 0.5) / 5.0
        if sculpt.ridge(0.5, u) < 0.48 or sculpt.ridge(0.0, u) > 0.001:
            _fail("five smooth scalp-to-tip hair ridges must rise and taper")
            return
    # The lower five-channel curtain now draws inward above the shoulders,
    # while the scalp stays at its original width. Check real procedural
    # vertex offsets rather than accepting a shader-only appearance change.
    var root_left: Vector3 = sculpt.sculpt(Vector3.ZERO, size, facing, 0.0, 0.0, true)
    var root_right: Vector3 = sculpt.sculpt(Vector3.ZERO, size, facing, 0.0, 1.0, true)
    var tip_left: Vector3 = sculpt.sculpt(Vector3.ZERO, size, facing, 0.9, 0.0, true)
    var tip_right: Vector3 = sculpt.sculpt(Vector3.ZERO, size, facing, 0.9, 1.0, true)
    var tip_inset := (tip_left.x - tip_right.x) - (root_left.x - root_right.x)
    if tip_inset < size.x * 0.055 or tip_inset > size.x * 0.09:
        _fail("lower hair must taper symmetrically toward neck, not flare over shoulders")
        return
    var upper_left: Vector3 = sculpt.sculpt(Vector3.ZERO, size, facing, 0.25, 0.0, true)
    var upper_right: Vector3 = sculpt.sculpt(Vector3.ZERO, size, facing, 0.25, 1.0, true)
    if absf(upper_left.x - upper_right.x) > size.x * 0.001:
        _fail("scalp and upper hair must retain their original width")
        return
    var original := source_meshes[0] as MeshInstance3D
    if original == null or original.skin == null or original.skin.get_bind_count() < 50:
        _fail("the original weighted humanoid Skin was replaced")
        return
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    if hero == null or not hero.find_children("*", "CollisionObject3D", true, false).is_empty():
        _fail("hair sculpt may not add any physics or gameplay colliders")
        return
    print("CONTINUOUS BACK HAIR SCULPT TEST PASSED: five sculpted channels, painted continuous shell, Head binding and original 65-bone Skin")
    quit(0)
