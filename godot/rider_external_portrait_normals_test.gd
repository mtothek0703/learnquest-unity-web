extends SceneTree
## Portrait lighting regression: the real Head-bone face, helmet and visor
## must use smooth normals on their curved surfaces, not flat triangle normals.
## This is a visual-quality test, not a claim of iPhone FPS or final art approval.

func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("EXTERNAL PORTRAIT NORMALS TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if adapter == null:
        _fail("real skinned rider adapter missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() < 50:
        _fail("original imported 65-bone rig missing")
        return
    var headwear := rig.get_node_or_null("ExternalHeroHeadgear") as BoneAttachment3D
    if headwear == null or headwear.bone_name != "Head":
        _fail("sculpted portrait must follow original Head joint")
        return
    var bounds: AABB = headwear.get("head_bounds")
    var center := bounds.get_center()
    var size := bounds.size
    var face_sign := float(headwear.get("face_sign"))
    var front_u := 0.25 if face_sign > 0.0 else 0.75
    var face_normal: Vector3 = headwear.call("_face_normal", center, size, front_u, 0.5)
    if face_normal.dot(Vector3(0.0, 0.0, face_sign)) < 0.60:
        _fail("sculpted face front normal does not point out of the portrait")
        return
    var shared_total := 0
    for name in ["SculptedContinuousFace", "CurvedFlightHelmetShell", "TranslucentFaceShield"]:
        var part := headwear.get_node_or_null(name) as MeshInstance3D
        if part == null or part.mesh == null or part.mesh.get_surface_count() != 1:
            _fail("continuous curved portrait surface missing: " + name)
            return
        var arrays: Array = part.mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        if vertices.size() < 600 or normals.size() != vertices.size():
            _fail("portrait surface has too few vertices or missing normals: " + name)
            return
        var shared: Dictionary = {}
        var duplicates := 0
        for i in range(vertices.size()):
            var point: Vector3 = vertices[i]
            var normal: Vector3 = normals[i]
            if absf(normal.length() - 1.0) > 0.025:
                _fail("non-unit smooth normal on " + name)
                return
            var key := "%0.5f,%0.5f,%0.5f" % [point.x, point.y, point.z]
            if shared.has(key):
                var earlier: Vector3 = shared[key]
                if earlier.dot(normal) < 0.985:
                    _fail("visible triangle faceting at a shared vertex on " + name)
                    return
                duplicates += 1
            else:
                shared[key] = normal
        if duplicates < 150:
            _fail("shared smooth curved vertices not verified on " + name)
            return
        shared_total += duplicates
    # Three independent curved hair systems now share smooth broad-surface
    # normals across neighboring ribbon strips, while retaining hard end caps.
    # The sampled vertices are an interior shared edge of two adjacent quads.
    var hair_samples := [
        {"name": "SculptedTaperedFringe3", "offset": 10 * (5 * 12 + 12)},
        {"name": "WindSweptBackLock4", "offset": 7 * (6 * 12 + 12)},
        {"name": "SculptedBackHairCurtain", "offset": 7 * (24 * 12 + 12)}
    ]
    for sample in hair_samples:
        var hair := headwear.get_node_or_null(sample["name"]) as MeshInstance3D
        if hair == null or hair.mesh == null:
            _fail("sculpted hair volume missing: " + str(sample["name"]))
            return
        var hair_arrays: Array = hair.mesh.surface_get_arrays(0)
        var hair_points: PackedVector3Array = hair_arrays[Mesh.ARRAY_VERTEX]
        var hair_normals: PackedVector3Array = hair_arrays[Mesh.ARRAY_NORMAL]
        var index: int = sample["offset"]
        if hair_normals.size() != hair_points.size() or index + 12 >= hair_points.size():
            _fail("hair ribbon normals missing at shared interior edge")
            return
        if hair_points[index + 5].distance_to(hair_points[index + 12]) > 0.00005:
            _fail("hair ribbon broad strips do not share a geometric edge")
            return
        if hair_normals[index + 5].dot(hair_normals[index + 12]) < 0.997:
            _fail("sculpted hair broad face has a visible normal seam")
            return
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    if hero == null or not hero.find_children("*", "CollisionObject3D", true, false).is_empty():
        _fail("portrait smoothing must not add any visual collision objects")
        return
    print("EXTERNAL PORTRAIT NORMALS TEST PASSED: face/helmet/visor smooth shared normals, %d shared vertices, original 65-bone rig and collisions preserved" % shared_total)
    quit(0)
