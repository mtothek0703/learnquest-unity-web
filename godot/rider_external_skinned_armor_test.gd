extends SceneTree
## Verify actual imported 65-bone Skin on the new sculpted armor, including
## weighted clipping intersections and symmetric chest / continuous back.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("EXTERNAL SKINNED ARMOR TEST FAILED: " + message)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    if hero == null:
        _fail("missing imported hero")
        return
    var outfit := hero.get_node_or_null("ExternalSkinnedFlightSuit") as Node
    if outfit == null:
        _fail("missing original skinned jacket")
        return
    var jacket := outfit.get("garment") as MeshInstance3D
    var armor := outfit.get_node_or_null("IntegratedSkinnedArmor") as Node
    if jacket == null or armor == null:
        _fail("missing integrated armor on original jacket")
        return
    var panels: Array = armor.get("panels")
    var counts: Array = armor.get("vertex_counts")
    if panels.size() != 3 or counts.size() != 3:
        _fail("expected two chest panels and one continuous back shield")
        return
    var names := ["SkinnedLeftPectoral", "SkinnedRightPectoral", "SkinnedSpineShield"]
    var total_vertices := 0
    for i in range(3):
        var part := panels[i] as MeshInstance3D
        if part == null or part.name != names[i] or part.mesh == null:
            _fail("missing anatomical mesh: " + names[i])
            return
        if part.skin != jacket.skin or part.skeleton != jacket.skeleton or part.get_parent() != jacket.get_parent():
            _fail("armor must use exactly the same original Skin and Skeleton3D")
            return
        if part.find_children("*", "CollisionObject3D", true, false).size() > 0:
            _fail("cosmetic sculpt may not add gameplay collisions")
            return
        var arrays: Array = part.mesh.surface_get_arrays(0)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        if vertices.size() < 90 or normals.size() != vertices.size() or bones.size() != vertices.size() * 4 or weights.size() != vertices.size() * 4:
            _fail("panel is not a genuine substantial four-weight skinned surface: " + names[i])
            return
        for v in range(vertices.size()):
            var total := 0.0
            for influence in range(4):
                var bone := bones[v * 4 + influence]
                if bone < 0 or bone >= part.skin.get_bind_count():
                    _fail("bone index not present in imported CC0 Skin")
                    return
                total += weights[v * 4 + influence]
            if absf(total - 1.0) > 0.025:
                _fail("interpolated armor bone weights are not normalized")
                return
        total_vertices += vertices.size()
    var left := (panels[0] as MeshInstance3D).mesh.get_aabb()
    var right := (panels[1] as MeshInstance3D).mesh.get_aabb()
    var back := (panels[2] as MeshInstance3D).mesh.get_aabb()
    if left.size.y < 0.12 or right.size.y < 0.12 or back.size.y < 0.14:
        _fail("armor collapsed into tiny decorative strips")
        return
    if left.get_center().x >= right.get_center().x or back.size.x < left.size.x:
        _fail("anatomical chest and spine layout is not bilateral")
        return
    # Synthetic clipping must preserve both source influences at a seam.
    var a := {"position": Vector3(-1.0, 0.0, 0.0), "normal": Vector3.FORWARD,
        "bones": PackedInt32Array([0, 1, 2, 3]), "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])}
    var b := {"position": Vector3(1.0, 0.0, 0.0), "normal": Vector3.FORWARD,
        "bones": PackedInt32Array([4, 5, 6, 7]), "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])}
    var midpoint: Dictionary = armor.call("_interpolate", a, b, 0.5)
    var blended: PackedFloat32Array = midpoint["weights"]
    if absf(blended[0] - 0.5) > 0.001 or absf(blended[1] - 0.5) > 0.001:
        _fail("armor clipping must blend the two original bone influences")
        return
    var triangle: Array[Dictionary] = [a, b, {"position": Vector3(0.0, 1.0, 0.0),
        "normal": Vector3.FORWARD, "bones": a["bones"], "weights": a["weights"]}]
    var clipped: Array[Dictionary] = armor.call("_clip", triangle, 0, -0.3, true)
    clipped = armor.call("_clip", clipped, 0, 0.3, false)
    if clipped.size() < 3:
        _fail("weighted armor triangle was discarded at a cut edge")
        return
    print("EXTERNAL SKINNED ARMOR TEST PASSED: %d vertices, three anatomical panels on original Skin" % total_vertices)
    quit(0)
