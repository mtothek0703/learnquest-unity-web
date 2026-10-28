extends SceneTree
## V124 release hold: the full flight-harness is real imported 65-bone GPU
## skinning, not four unrigged ribbons. Verify diagonal seam interpolation.
func _initialize() -> void:
    call_deferred("_check")

func _fail(reason: String) -> void:
    push_error("EXTERNAL SKINNED HARNESS TEST FAILED: " + reason)
    quit(1)

func _check() -> void:
    var rider := preload("res://rider_character.tscn").instantiate() as Node3D
    rider.set("prefer_cc0_rigged_hero", true)
    root.add_child(rider)
    await process_frame
    var hero := rider.get_node_or_null("ExternalRiggedHero") as Node3D
    var adapter := rider.get_node_or_null("ExternalHeroPose") as Node
    if hero == null or adapter == null:
        _fail("real imported CC0 rider missing")
        return
    var rig := adapter.get("skeleton") as Skeleton3D
    if rig == null or rig.get_bone_count() != 65:
        _fail("harness must preserve original 65-bone skeleton")
        return
    var outfit := hero.get_node_or_null("ExternalSkinnedFlightSuit") as Node
    if outfit == null:
        _fail("skinned jacket missing")
        return
    var jacket := outfit.get("garment") as MeshInstance3D
    var harness_node := outfit.get_node_or_null("IntegratedSkinnedFlightHarness") as Node
    if jacket == null or harness_node == null:
        _fail("four-band harness controller missing")
        return
    var harness := harness_node.get("harness") as MeshInstance3D
    if harness == null or harness.mesh == null or harness.skin == null:
        _fail("actual weighted harness mesh missing")
        return
    if harness.skin != jacket.skin or harness.skeleton != jacket.skeleton or harness.get_parent() != jacket.get_parent():
        _fail("harness must share imported Skin, Skeleton3D and garment transform")
        return
    if harness.find_children("*", "CollisionObject3D", true, false).size() > 0:
        _fail("harness may not introduce gameplay collisions")
        return
    var front_count := int(harness_node.get("front_vertices"))
    var rear_count := int(harness_node.get("rear_vertices"))
    if front_count < 120 or rear_count < 120:
        _fail("front/rear sculpted costume bands missing")
        return
    var arrays: Array = harness.mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
    if vertices.size() != front_count + rear_count or vertices.size() < 240 or normals.size() != vertices.size() or colors.size() != vertices.size() or bones.size() != vertices.size() * 4 or weights.size() != vertices.size() * 4:
        _fail("four-band geometry must be fully vertex-painted and four-weight skinned")
        return
    var min_x := INF
    var max_x := -INF
    var cyan := 0
    var magenta := 0
    for i in range(vertices.size()):
        min_x = minf(min_x, vertices[i].x)
        max_x = maxf(max_x, vertices[i].x)
        if colors[i].g > colors[i].r:
            cyan += 1
        else:
            magenta += 1
        var sum := 0.0
        for j in range(4):
            var bind_id := bones[i * 4 + j]
            if bind_id < 0 or bind_id >= harness.skin.get_bind_count():
                _fail("invalid original Skin bind index")
                return
            sum += weights[i * 4 + j]
        if absf(sum - 1.0) > 0.025:
            _fail("interpolated seam weights not normalized")
            return
    if min_x >= -0.03 or max_x <= 0.03 or cyan < 90 or magenta < 90:
        _fail("mirrored front/back two-tone sculpt collapsed")
        return
    # Synthetic diagonal strip crosses both triangle edges: intersection
    # vertices must preserve normalized original weights at the cut.
    var bounds := AABB(Vector3(-1.0, 0.0, -1.0), Vector3(2.0, 1.0, 2.0))
    var source: Array[Dictionary] = []
    for x in [-0.60, 0.60, 0.0]:
        source.append({"position": Vector3(x, 0.50 if x != 0.0 else 0.85, 0.0),
            "normal": Vector3.FORWARD,
            "bones": PackedInt32Array([0, 1, 2, 3]),
            "weights": PackedFloat32Array([0.7, 0.2, 0.1, 0.0])})
    var clipped: Array[Dictionary] = harness_node.call("_clip_band", source, bounds, 1.0, 0.052)
    if clipped.size() < 3:
        _fail("diagonal seam clipping dropped an intersecting triangle")
        return
    var on_boundary := false
    for corner in clipped:
        var position: Vector3 = corner["position"]
        var distance := absf(float(harness_node.call("_signed_band", position, bounds, 1.0)))
        if distance > 0.0521 or position.y < 0.2299 or position.y > 0.8301:
            _fail("diagonal strip contains points outside fitted boundary")
            return
        if absf(distance - 0.052) < 0.0002:
            on_boundary = true
        var blend_weights: PackedFloat32Array = corner["weights"]
        if blend_weights.size() != 4 or absf(blend_weights[0] + blend_weights[1] + blend_weights[2] + blend_weights[3] - 1.0) > 0.001:
            _fail("diagonal clip lost original skin weights")
            return
    if not on_boundary:
        _fail("no weighted intersection vertices generated")
        return
    print("EXTERNAL SKINNED HARNESS TEST PASSED: %d front, %d rear, four diagonal original-Skin bands" % [front_count, rear_count])
    quit(0)
