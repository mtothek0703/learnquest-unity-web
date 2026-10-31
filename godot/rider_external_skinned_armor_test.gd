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
    var colored_vertices := 0
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
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
        if colors.size() != vertices.size():
            _fail("anatomical armor must have vertex-painted facets, not flat overlay plates")
            return
        for tint in colors:
            if tint.b > 0.30:
                colored_vertices += 1
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
    if colored_vertices < 90:
        _fail("missing integrated two-tone armor geometry")
        return
    # Regression: the back shield must not duplicate the body's side faces.
    # The old predicate treated any normal sum <= +0.38 as rear-facing,
    # including sideways and slightly forward-facing triangles.
    for value in [-0.2, 0.0, 0.2, 0.38]:
        if bool(armor.call("_faces_panel", value, false)):
            _fail("side/forward jacket triangles leaked into rear armor")
            return
    if not bool(armor.call("_faces_panel", -0.5, false)) or \
            bool(armor.call("_faces_panel", -0.5, true)) or \
            not bool(armor.call("_faces_panel", 0.5, true)):
        _fail("front/rear armor facing discrimination is broken")
        return
    var center_depth := float(armor.call("_panel_relief", 0.5, 0.5, true))
    var edge_depth := float(armor.call("_panel_relief", 0.01, 0.01, true))
    if center_depth <= edge_depth + 0.02 or center_depth >= 0.055:
        _fail("new chest facets must have a shallow sculpted bevel, not barrel-shaped protrusions")
        return
    var left := (panels[0] as MeshInstance3D).mesh.get_aabb()
    var right := (panels[1] as MeshInstance3D).mesh.get_aabb()
    var back := (panels[2] as MeshInstance3D).mesh.get_aabb()
    if left.size.y < 0.12 or right.size.y < 0.12 or back.size.y < 0.14:
        _fail("armor collapsed into tiny decorative strips")
        return
    if left.get_center().x >= right.get_center().x or back.size.x < left.size.x:
        _fail("anatomical chest and spine layout is not bilateral")
        return
    # The real imported Skin must now form curved, shoulder-wide armor
    # rather than three rectangular patches. Check all three waist/shoulder
    # profiles against the jacket's own rest-space bounds.
    var jacket_bounds := jacket.mesh.get_aabb()
    var profiles := [
        {"left": -0.37, "right": -0.025, "low": 0.22, "high": 0.88, "front": true},
        {"left": 0.025, "right": 0.37, "low": 0.22, "high": 0.88, "front": true},
        {"left": -0.23, "right": 0.23, "low": 0.13, "high": 0.93, "front": false}
    ]
    for spec in profiles:
        var low_y := jacket_bounds.position.y + jacket_bounds.size.y * (float(spec["low"]) * 0.95 + float(spec["high"]) * 0.05)
        var high_y := jacket_bounds.position.y + jacket_bounds.size.y * (float(spec["low"]) * 0.05 + float(spec["high"]) * 0.95)
        var low_width := float(armor.call("_profile_edge", jacket_bounds, spec, true, low_y)) - float(armor.call("_profile_edge", jacket_bounds, spec, false, low_y))
        var high_width := float(armor.call("_profile_edge", jacket_bounds, spec, true, high_y)) - float(armor.call("_profile_edge", jacket_bounds, spec, false, high_y))
        if low_width <= 0.0 or high_width < low_width * 1.25:
            _fail("original-skinned anatomical armor must widen continuously toward shoulders")
            return
    # Synthetic triangle crosses a CURVED left profile. The binary clipping
    # intersection must lie on that profile, retaining normalized source Skin.
    var curved_spec: Dictionary = profiles[2]
    var curve_y := jacket_bounds.position.y + jacket_bounds.size.y * 0.53
    var curve_x := float(armor.call("_profile_edge", jacket_bounds, curved_spec, false, curve_y))
    var curved_triangle: Array[Dictionary] = [
        {"position": Vector3(curve_x - 0.15, curve_y - 0.10, 0.0),
            "normal": Vector3.FORWARD, "bones": PackedInt32Array([0, 1, 2, 3]),
            "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])},
        {"position": Vector3(curve_x + 0.18, curve_y + 0.08, 0.0),
            "normal": Vector3.FORWARD, "bones": PackedInt32Array([4, 5, 6, 7]),
            "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])},
        {"position": Vector3(curve_x + 0.21, curve_y - 0.09, 0.0),
            "normal": Vector3.FORWARD, "bones": PackedInt32Array([8, 9, 10, 11]),
            "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])}
    ]
    var curved_cut: Array[Dictionary] = armor.call("_clip_profile", curved_triangle, jacket_bounds, curved_spec, false)
    if curved_cut.size() < 3:
        _fail("curved armor clipping discarded crossing source triangle")
        return
    var boundary_count := 0
    for corner in curved_cut:
        var point: Vector3 = corner["position"]
        var edge := float(armor.call("_profile_edge", jacket_bounds, curved_spec, false, point.y))
        if point.x < edge - 0.0003:
            _fail("curved armor vertex escaped sculpted boundary")
            return
        if absf(point.x - edge) < 0.0003:
            boundary_count += 1
        var skin_weights: PackedFloat32Array = corner["weights"]
        var skin_total := 0.0
        for influence in skin_weights:
            skin_total += influence
        if skin_weights.size() != 4 or absf(skin_total - 1.0) > 0.001:
            _fail("curved shoulder seam lost original normalized four-weight skin")
            return
    if boundary_count < 2:
        _fail("curved armor did not generate two weighted boundary intersections")
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
