extends SceneTree
## V124: prove new sculpted jacket is a genuine GPU-skinned surface using
## the imported CC0 Skin and bone weights, not a rigid decorative duplicate.
func _initialize() -> void:
    call_deferred("_check")
func _fail(reason: String) -> void:
    push_error("EXTERNAL SKINNED OUTFIT TEST FAILED: " + reason)
    quit(1)
func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    if adapter == null or hero == null:
        _fail("real imported character missing")
        return
    var outfit := hero.get_node_or_null("ExternalSkinnedFlightSuit") as Node
    if outfit == null:
        _fail("jacket extraction controller missing")
        return
    var garment := outfit.get("garment") as MeshInstance3D
    if garment == null or garment.mesh == null or garment.skin == null:
        _fail("weighted jacket geometry was not generated")
        return
    var source := hero.find_child("SuperHero_Male", true, false) as MeshInstance3D
    if source == null or garment.skin != source.skin:
        _fail("jacket must reuse the actual original imported Skin resource")
        return
    if garment.skeleton != source.skeleton or garment.get_parent() != source.get_parent():
        _fail("jacket must deform under the exact same original Skeleton3D")
        return
    var vertex_count := 0
    for surface in range(garment.mesh.get_surface_count()):
        var arrays: Array = garment.mesh.surface_get_arrays(surface)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        if weights.size() < vertices.size() * 4 or bones.size() < vertices.size() * 4:
            _fail("jacket surface has no actual GPU skinning weights")
            return
        for i in range(vertices.size()):
            var total := 0.0
            for j in range(4):
                var index := bones[i * 4 + j]
                if index < 0 or index >= garment.skin.get_bind_count():
                    _fail("jacket bone index outside original Skin")
                    return
                total += weights[i * 4 + j]
            if absf(total - 1.0) > 0.04:
                _fail("jacket weights must stay normalized")
                return
        vertex_count += vertices.size()
    if vertex_count < 300:
        _fail("not enough real sculpted garment geometry")
        return
    if garment.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("visual jacket must not modify game collisions")
        return
    print("EXTERNAL SKINNED OUTFIT TEST PASSED: %d jacket vertices reuse original 65-bone Skin" % vertex_count)
    quit(0)
