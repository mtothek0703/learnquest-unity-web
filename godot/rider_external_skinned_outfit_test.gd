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
    var material := garment.material_override as ShaderMaterial
    if material == null or material.shader == null:
        _fail("mobile PBR jacket shader not attached to the real skinned garment")
        return
    var shader_code := material.shader.code
    # The entire jacket must share a sculpt-aligned PBR panel language, not
    # return to a uniform neon shell or rely on unskinned floating decals.
    for region in ["armor_field", "collar_lip", "chest_panel_seam",
            "waist_gasket", "side_joint", "stitched_panel"]:
        if not shader_code.contains(region):
            _fail("missing integrated skinned jacket material zone: " + region)
            return
    if not shader_code.contains("METALLIC = clamp") or not shader_code.contains("ROUGHNESS = clamp"):
        _fail("skinned jacket requires bounded satin armor and matte seam response")
        return
    for required in ["electric_pink", "cobalt", "weave", "EMISSION", "ROUGHNESS"]:
        if not shader_code.contains(required):
            _fail("missing coherent mobile flight-jacket material feature: " + required)
            return
    # The central navy armored section and cyan V/spine are deliberately
    # continuous on the same four-weight torso; no rigid floating chest plate.
    for required in ["center_armor", "flank_armor", "zipper", "chevron", "cyan"]:
        if not shader_code.contains(required):
            _fail("missing coherent dark-core flight-suit identity: " + required)
            return
    # New full-torso sculpt must create a genuinely differentiated silhouette,
    # not just recolor the original narrow body or attach rigid shoulder boxes.
    var imported_bounds := source.mesh.get_aabb()
    if absf(float(material.get_shader_parameter("rest_height")) - imported_bounds.size.y) > 0.001 or \
            absf(float(material.get_shader_parameter("rest_width")) - imported_bounds.size.x) > 0.001:
        _fail("jacket color panels must be fitted to the actual CC0 rest bounds")
        return
    var test_bounds := AABB(Vector3(-0.7, 0.0, -0.35), Vector3(1.4, 3.0, 0.7))
    # Actual sculpt relief must affect lighting normals, not just vertex
    # positions. Keep them outward, unit length and distinct from source skin.
    var normal_tool := preload("res://rider_sculpted_surface_normals.gd")
    var chest_normal: Vector3 = normal_tool.corrected(
        Vector3(0.25, 1.86, 0.3), Vector3.FORWARD, test_bounds,
        Callable(outfit, "_tailored_offset"))
    if not chest_normal.is_finite() or absf(chest_normal.length() - 1.0) > 0.001 or \
            chest_normal.dot(Vector3.FORWARD) < 0.65 or \
            chest_normal.dot(Vector3.FORWARD) > 0.995:
        _fail("skinned chest relief must have outward smooth normals following its sculpt")
        return
    var forward := Vector3(0.0, 0.0, 1.0)
    var chest: Vector3 = outfit.call("_tailored_offset", Vector3(0.10, 1.905, 0.3), forward, test_bounds)
    var waist: Vector3 = outfit.call("_tailored_offset", Vector3(0.10, 1.395, 0.3), forward, test_bounds)
    var shoulder: Vector3 = outfit.call("_tailored_offset", Vector3(0.30, 2.205, 0.3), forward, test_bounds)
    var opposite: Vector3 = outfit.call("_tailored_offset", Vector3(-0.30, 2.205, 0.3), forward, test_bounds)
    if chest.z < waist.z + 0.025 or shoulder.z < waist.z + 0.025:
        _fail("new skinned torso must have sculpted chest/shoulder volume and a tapered waist")
        return
    if chest.z > 0.18 or shoulder.z > 0.18:
        _fail("torso redesign regressed to the oversized barrel-chest shell")
        return
    # At actual mobile camera distance the previous thin CC0 jacket lost
    # its pectoral/deltoid silhouette. Check the new three-dimensional
    # athletic V-shape, not just a cosmetic color change.
    if chest.z < 0.09 or shoulder.z < 0.065 or shoulder.x < 0.035:
        _fail("original-skinned torso lost the fuller chest/deltoid V silhouette")
        return
    if opposite.x > -0.035 or absf(shoulder.x + opposite.x) > 0.002:
        _fail("weighted shoulder expansion must be balanced on both sides")
        return
    # The rear silhouette must be visibly different in the actual chase
    # camera: sculpted source-skin scapulae and shoulder sweep, not added
    # primitive shoulder boxes. The original CC0 forward direction is -Z.
    var dorsal_point := Vector3(0.34, 2.14, -0.30)
    var rear_normal := Vector3(0.0, 0.0, 1.0)
    var front_normal := Vector3(0.0, 0.0, -1.0)
    var dorsal_offset: Vector3 = outfit.call("_tailored_offset",
        dorsal_point, rear_normal, test_bounds)
    var ventral_offset: Vector3 = outfit.call("_tailored_offset",
        dorsal_point, front_normal, test_bounds)
    var opposite_dorsal: Vector3 = outfit.call("_tailored_offset",
        Vector3(-dorsal_point.x, dorsal_point.y, dorsal_point.z),
        rear_normal, test_bounds)
    if not dorsal_offset.is_finite() or not opposite_dorsal.is_finite():
        _fail("rear skinned jacket relief produced nonfinite vertices")
        return
    if dorsal_offset.z < absf(ventral_offset.z) + 0.045 or \
            dorsal_offset.x < ventral_offset.x + 0.018:
        _fail("rear scapular relief and broad shoulder contour are not geometric")
        return
    if absf(dorsal_offset.x + opposite_dorsal.x) > 0.001 or \
            absf(dorsal_offset.z - opposite_dorsal.z) > 0.001:
        _fail("rear jacket sculpt must remain mirrored on the same original Skin")
        return
    var waist_point := Vector3(0.34, 1.44, -0.30)
    var rear_waist: Vector3 = outfit.call("_tailored_offset",
        waist_point, rear_normal, test_bounds)
    var front_waist: Vector3 = outfit.call("_tailored_offset",
        waist_point, front_normal, test_bounds)
    if rear_waist.z > absf(front_waist.z) + 0.012:
        _fail("rear scapular contour must taper out before the skinned waist")
        return
    # The garment must keep EVERY intersecting source triangle instead of
    # dropping the neckline/waist triangles and exposing the naked CC0 torso.
    # Synthetic clipping also exercises interpolation of real skin influences.
    var corner_a := {
        "position": Vector3(-0.4, 0.20, 0.0), "normal": Vector3.FORWARD,
        "bones": PackedInt32Array([0, 1, 2, 3]),
        "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])
    }
    var corner_b := {
        "position": Vector3(0.4, 0.80, 0.0), "normal": Vector3.FORWARD,
        "bones": PackedInt32Array([4, 5, 6, 7]),
        "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])
    }
    var corner_c := {
        "position": Vector3(0.0, 0.50, 0.2), "normal": Vector3.FORWARD,
        "bones": PackedInt32Array([0, 1, 2, 3]),
        "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])
    }
    var source_triangle: Array[Dictionary] = [corner_a, corner_b, corner_c]
    var clipped: Array[Dictionary] = outfit.call("_clip_to_height", source_triangle, 0.35, true)
    clipped = outfit.call("_clip_to_height", clipped, 0.65, false)
    if clipped.size() < 3:
        _fail("waist/collar clipping discarded an intersecting weighted triangle")
        return
    var has_new_boundary := false
    for corner in clipped:
        var position: Vector3 = corner["position"]
        if position.y < 0.3499 or position.y > 0.6501:
            _fail("new jacket geometry escapes the waist/collar clipping planes")
            return
        if absf(position.y - 0.35) < 0.0001 or absf(position.y - 0.65) < 0.0001:
            has_new_boundary = true
        var ids: PackedInt32Array = corner["bones"]
        var skin_weights: PackedFloat32Array = corner["weights"]
        if ids.size() != 4 or skin_weights.size() != 4:
            _fail("clipped vertices lost their four original skin influences")
            return
        var sum_weights := 0.0
        for weight in skin_weights:
            sum_weights += weight
        if absf(sum_weights - 1.0) > 0.001:
            _fail("interpolated clipped skin weights are not normalized")
            return
    if not has_new_boundary:
        _fail("clipping failed to generate interpolated boundary vertices")
        return
    var middle: Dictionary = outfit.call("_interpolate_corner", corner_a, corner_b, 0.5)
    var middle_weights: PackedFloat32Array = middle["weights"]
    if absf(middle_weights[0] - 0.5) > 0.001 or absf(middle_weights[1] - 0.5) > 0.001:
        _fail("boundary intersection must preserve both source bone influences")
        return
    # Verify the new V-shaped ridge and collar are actual geometric relief
    # on the original weighted jacket, not a painted texture or rigid prop.
    var ridge: Vector3 = outfit.call("_tailored_offset", Vector3(0.25, 1.905, 0.3),
        forward, test_bounds)
    var ridge_off: Vector3 = outfit.call("_tailored_offset", Vector3(0.42, 1.905, 0.3),
        forward, test_bounds)
    var collar: Vector3 = outfit.call("_tailored_offset", Vector3(0.08, 2.295, 0.3),
        forward, test_bounds)
    var collar_above: Vector3 = outfit.call("_tailored_offset", Vector3(0.08, 2.34, 0.3),
        forward, test_bounds)
    # Compare the same centerline rather than outer shoulder volume, which
    # intentionally rises higher than the collar in the original CC0 shape.
    if ridge.z < ridge_off.z + 0.025 or collar.z < collar_above.z + 0.009:
        _fail("V-yoke and raised collar must have real 3D geometry on the skinned torso")
        return
    var mirrored_ridge: Vector3 = outfit.call("_tailored_offset", Vector3(-0.25, 1.905, 0.3),
        forward, test_bounds)
    if absf(ridge.z - mirrored_ridge.z) > 0.001 or absf(ridge.x + mirrored_ridge.x) > 0.001:
        _fail("skinned jacket V-yoke must remain bilaterally symmetrical")
        return
    # Anatomical shoulder and pectoral relief must exist as actual weighted
    # geometry, not merely new shader colors.
    var pectoral_center: Vector3 = outfit.call("_tailored_offset",
        Vector3(0.238, 1.965, 0.3), forward, test_bounds)
    var pectoral_outer: Vector3 = outfit.call("_tailored_offset",
        Vector3(0.58, 1.965, 0.3), forward, test_bounds)
    var deltoid_top: Vector3 = outfit.call("_tailored_offset",
        Vector3(0.49, 2.145, 0.3), forward, test_bounds)
    var deltoid_lower: Vector3 = outfit.call("_tailored_offset",
        Vector3(0.49, 1.72, 0.3), forward, test_bounds)
    if pectoral_center.z < pectoral_outer.z + 0.04:
        _fail("real skinned jacket must have sculpted pectoral volume")
        return
    if deltoid_top.x < deltoid_lower.x + 0.035:
        _fail("real skinned jacket must have an anatomical shoulder cap")
        return
    if not (garment.material_override as ShaderMaterial).shader.code.contains("pectoral_panel"):
        _fail("chest color panels must follow the sculpted torso")
        return
    if garment.mesh.get_aabb().size.x < imported_bounds.size.x * 0.28:
        _fail("tailored jacket silhouette collapsed")
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
    # A source vertex exactly on a cut plane used to be duplicated by
    # Sutherland-Hodgman clipping, producing zero-area skinned triangles.
    var boundary_triangle: Array[Dictionary] = [
        {"position": Vector3(0.0, 0.5, 0.0), "normal": Vector3.FORWARD,
            "bones": PackedInt32Array([0, 0, 0, 0]),
            "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])},
        {"position": Vector3(1.0, 0.25, 0.0), "normal": Vector3.FORWARD,
            "bones": PackedInt32Array([1, 1, 1, 1]),
            "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])},
        {"position": Vector3(0.0, 0.75, 1.0), "normal": Vector3.FORWARD,
            "bones": PackedInt32Array([2, 2, 2, 2]),
            "weights": PackedFloat32Array([1.0, 0.0, 0.0, 0.0])}
    ]
    var boundary_result: Array[Dictionary] = outfit.call(
        "_clip_to_height", boundary_triangle, 0.5, true)
    if boundary_result.size() != 3:
        _fail("jacket seam clipping must remove coincident boundary vertices")
        return
    for boundary_index in range(boundary_result.size()):
        var current_point: Vector3 = boundary_result[boundary_index]["position"]
        var next_point: Vector3 = boundary_result[(boundary_index + 1) % boundary_result.size()]["position"]
        if current_point.distance_squared_to(next_point) <= 0.0000000001:
            _fail("jacket seam clipping retained a zero-length edge")
            return
    var edge_a: Vector3 = boundary_result[1]["position"] - boundary_result[0]["position"]
    var edge_b: Vector3 = boundary_result[2]["position"] - boundary_result[0]["position"]
    if edge_a.cross(edge_b).length_squared() <= 0.000000000001:
        _fail("jacket seam clipping created a zero-area polygon")
        return
    print("EXTERNAL SKINNED OUTFIT TEST PASSED: %d jacket vertices reuse original 65-bone Skin" % vertex_count)
    quit(0)
