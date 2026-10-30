extends Node
## V124 WIP: sculpt a true GPU-skinned jacket shell FROM the source body's
## indexed triangles. The shell retains original bone indices, weights and
## imported Skin/bind poses, rather than attaching rigid primitive armor.
var garment: MeshInstance3D
var generated_vertices: int = 0

func install(source_meshes: Array[MeshInstance3D]) -> bool:
    for body in source_meshes:
        if body == null or body.mesh == null or body.skin == null:
            continue
        if not String(body.name).contains("SuperHero"):
            continue
        var mesh := _extract_jacket(body)
        if mesh == null:
            continue
        garment = MeshInstance3D.new()
        garment.name = "TrueSkinnedTailoredJacket"
        garment.mesh = mesh
        garment.skin = body.skin
        garment.skeleton = body.skeleton
        garment.transform = body.transform
        garment.material_override = _jacket_material(body.mesh.get_aabb())
        body.get_parent().add_child(garment)
        return true
    return false

func _extract_jacket(body: MeshInstance3D) -> ArrayMesh:
    var bounds := body.mesh.get_aabb()
    var bottom := bounds.position.y
    var height := bounds.size.y
    if height < 0.5:
        return null
    # The original height-only cut included the entire upper/forearms in
    # the torso jacket. Those duplicated weighted arm triangles formed the
    # oversized pink/cyan hand bulbs in the real chase-camera A/B images.
    # Clip on the imported ARM BONE WEIGHT field instead of world X/Y:
    # this follows each 65-bone arm through steering and jumping.
    var arm_binds: Dictionary = {}
    var rig := body.get_node_or_null(body.skeleton) as Skeleton3D
    for bind_index in range(body.skin.get_bind_count()):
        var bone_name := String(body.skin.get_bind_name(bind_index))
        var bone_id := body.skin.get_bind_bone(bind_index)
        if bone_name.is_empty() and rig != null and bone_id >= 0 and bone_id < rig.get_bone_count():
            bone_name = String(rig.get_bone_name(bone_id))
        if bone_name in ["upperarm_l", "upperarm_r", "lowerarm_l", "lowerarm_r",
                "hand_l", "hand_r"]:
            arm_binds[bind_index] = true
    if arm_binds.size() < 4:
        push_warning("Cannot safely trim jacket arm duplicates without original arm Skin binds")
        return null
    var output := SurfaceTool.new()
    output.begin(Mesh.PRIMITIVE_TRIANGLES)
    var accepted := 0
    var normal_offset := Callable(self, "_tailored_offset")
    # Clip every weighted source triangle at the ACTUAL jacket waist and collar.
    # The old all-three-vertices filter discarded intersecting triangles,
    # leaving holes and jagged openings around the torso and shoulder.
    var waist_y := bottom + height * 0.43
    var collar_y := bottom + height * 0.78
    for surface in range(body.mesh.get_surface_count()):
        if body.mesh.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
            continue
        var arrays: Array = body.mesh.surface_get_arrays(surface)
        var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
        if verts.is_empty() or normals.size() != verts.size():
            continue
        if bones.size() < verts.size() * 4 or weights.size() < verts.size() * 4:
            continue
        var triangle_count := indices.size() / 3 if not indices.is_empty() else verts.size() / 3
        for triangle in range(int(triangle_count)):
            var ids := PackedInt32Array()
            for corner_index in range(3):
                ids.append(indices[triangle * 3 + corner_index] if not indices.is_empty()
                    else triangle * 3 + corner_index)
            var polygon: Array[Dictionary] = []
            for vertex_id in ids:
                polygon.append(_source_corner(verts, normals, bones, weights, vertex_id, arm_binds))
            polygon = _clip_to_height(polygon, waist_y, true)
            polygon = _clip_to_height(polygon, collar_y, false)
            polygon = _clip_to_arm_influence(polygon, 0.48)
            if polygon.size() < 3:
                continue
            for corner_index in range(1, polygon.size() - 1):
                var a: Vector3 = polygon[0]["position"]
                var b: Vector3 = polygon[corner_index]["position"]
                var c: Vector3 = polygon[corner_index + 1]["position"]
                if (b - a).cross(c - a).length_squared() <= 0.000000000001:
                    continue
                for corner in [polygon[0], polygon[corner_index], polygon[corner_index + 1]]:
                    var point: Vector3 = corner["position"]
                    var normal: Vector3 = corner["normal"]
                    output.set_normal(preload("res://rider_sculpted_surface_normals.gd").corrected(
                        point, normal, bounds, normal_offset))
                    output.set_bones(corner["bones"])
                    output.set_weights(corner["weights"])
                    output.add_vertex(point + _tailored_offset(point, normal, bounds))
                    accepted += 1
    if accepted < 300:
        return null
    generated_vertices = accepted
    return output.commit()

func _source_corner(vertices: PackedVector3Array, normals: PackedVector3Array,
        bones: PackedInt32Array, weights: PackedFloat32Array, index: int,
        arm_binds: Dictionary) -> Dictionary:
    var start := index * 4
    var arm_weight := 0.0
    for slot in range(4):
        if arm_binds.has(bones[start + slot]):
            arm_weight += weights[start + slot]
    return {
        "position": vertices[index],
        "normal": normals[index].normalized(),
        "bones": PackedInt32Array([bones[start], bones[start + 1],
            bones[start + 2], bones[start + 3]]),
        "weights": PackedFloat32Array([weights[start], weights[start + 1],
            weights[start + 2], weights[start + 3]]),
        "arm_influence": arm_weight
    }

func _clip_to_height(polygon: Array[Dictionary], plane_y: float,
        keep_above: bool) -> Array[Dictionary]:
    var clipped: Array[Dictionary] = []
    if polygon.is_empty():
        return clipped
    var previous: Dictionary = polygon[polygon.size() - 1]
    for current in polygon:
        var previous_point: Vector3 = previous["position"]
        var current_point: Vector3 = current["position"]
        var previous_inside := previous_point.y >= plane_y if keep_above else previous_point.y <= plane_y
        var current_inside := current_point.y >= plane_y if keep_above else current_point.y <= plane_y
        if previous_inside != current_inside:
            var dy := current_point.y - previous_point.y
            if absf(dy) > 0.0000001:
                clipped.append(_interpolate_corner(previous, current,
                    clampf((plane_y - previous_point.y) / dy, 0.0, 1.0)))
        if current_inside:
            clipped.append(current)
        previous = current
    return _deduplicate_polygon(clipped)

# Keep the body-weighted side of the shoulder seam. Intersections retain
# the strongest four ORIGINAL skin binds through _interpolate_corner.
func _clip_to_arm_influence(polygon: Array[Dictionary],
        maximum: float) -> Array[Dictionary]:
    var clipped: Array[Dictionary] = []
    if polygon.is_empty():
        return clipped
    var previous: Dictionary = polygon[polygon.size() - 1]
    for current in polygon:
        var previous_weight := float(previous.get("arm_influence", 0.0))
        var current_weight := float(current.get("arm_influence", 0.0))
        var previous_inside := previous_weight <= maximum
        var current_inside := current_weight <= maximum
        if previous_inside != current_inside:
            var delta := current_weight - previous_weight
            if absf(delta) > 0.000001:
                clipped.append(_interpolate_corner(previous, current,
                    clampf((maximum - previous_weight) / delta, 0.0, 1.0)))
        if current_inside:
            clipped.append(current)
        previous = current
    return _deduplicate_polygon(clipped)

func _deduplicate_polygon(polygon: Array[Dictionary]) -> Array[Dictionary]:
    # Plane-aligned imported vertices can be emitted twice by clipping.
    # Removing consecutive duplicates prevents zero-area triangles and
    # unstable normals at the animated waist, cuff and collar boundaries.
    var unique: Array[Dictionary] = []
    for corner in polygon:
        var point: Vector3 = corner["position"]
        if not unique.is_empty():
            var previous: Vector3 = unique[unique.size() - 1]["position"]
            if point.distance_squared_to(previous) <= 0.0000000001:
                continue
        unique.append(corner)
    if unique.size() > 1:
        var first: Vector3 = unique[0]["position"]
        var last: Vector3 = unique[unique.size() - 1]["position"]
        if first.distance_squared_to(last) <= 0.0000000001:
            unique.pop_back()
    return unique

func _interpolate_corner(a: Dictionary, b: Dictionary, t: float) -> Dictionary:
    # An intersection can mix up to eight distinct imported bone influences.
    # Retain the strongest four and renormalize; never assign an invented joint.
    var combined: Dictionary = {}
    for endpoint in [a, b]:
        var influence := (1.0 - t) if endpoint == a else t
        var ids: PackedInt32Array = endpoint["bones"]
        var weights: PackedFloat32Array = endpoint["weights"]
        for slot in range(4):
            var bone_id := ids[slot]
            combined[bone_id] = float(combined.get(bone_id, 0.0)) + weights[slot] * influence
    var out_bones := PackedInt32Array()
    var out_weights := PackedFloat32Array()
    var total := 0.0
    for slot in range(4):
        var best_id := -1
        var best_weight := 0.0
        for candidate in combined.keys():
            var value := float(combined[candidate])
            if value > best_weight:
                best_weight = value
                best_id = int(candidate)
        if best_id >= 0:
            out_bones.append(best_id)
            out_weights.append(best_weight)
            total += best_weight
            combined.erase(best_id)
        else:
            out_bones.append(out_bones[0] if not out_bones.is_empty() else 0)
            out_weights.append(0.0)
    if total > 0.00001:
        for slot in range(4):
            out_weights[slot] /= total
    var normal: Vector3 = (a["normal"] as Vector3).lerp(b["normal"], t).normalized()
    return {
        "position": (a["position"] as Vector3).lerp(b["position"], t),
        "normal": normal,
        "bones": out_bones,
        "weights": out_weights,
        "arm_influence": lerpf(float(a.get("arm_influence", 0.0)),
            float(b.get("arm_influence", 0.0)), t)
    }

func _is_jacket_vertex(point: Vector3, bottom: float, height: float) -> bool:
    var y := (point.y - bottom) / height
    return y >= 0.43 and y <= 0.78

func _tailored_offset(point: Vector3, normal: Vector3, bounds: AABB) -> Vector3:
    # V124 silhouette reset: the imported 65-bone torso remains the actual
    # deforming mesh. Carve a narrow waist, a readable V-yoke and a defined
    # deltoid-to-pectoral transition instead of stacking a barrel-shaped shell.
    # All coordinates are proportions of the source glTF AABB.
    var y := (point.y - bounds.position.y) / maxf(bounds.size.y, 0.001)
    var lateral := (point.x - bounds.get_center().x) / maxf(bounds.size.x, 0.001)
    var x := absf(lateral)
    var chest := exp(-pow((y - 0.635) / 0.105, 2.0)) * (1.0 - smoothstep(0.23, 0.43, x))
    var shoulder := exp(-pow((y - 0.735) / 0.075, 2.0)) * smoothstep(0.065, 0.30, x)
    var waist := exp(-pow((y - 0.465) / 0.065, 2.0))
    var diagonal := x - (0.11 + 0.28 * (y - 0.55))
    var chest_ridge := exp(-pow(diagonal / 0.055, 2.0)) * exp(-pow((y - 0.635) / 0.115, 2.0))
    var collar := exp(-pow((y - 0.765) / 0.026, 2.0)) * (1.0 - smoothstep(0.17, 0.38, x))
    var pectoral := exp(-pow((y - 0.655) / 0.075, 2.0)) * exp(-pow((x - 0.17) / 0.11, 2.0))
    var deltoid := exp(-pow((y - 0.715) / 0.055, 2.0)) * smoothstep(0.18, 0.32, x)
    var spine_keel := exp(-pow(lateral / 0.065, 2.0)) * exp(-pow((y - 0.61) / 0.13, 2.0))
    # The chase camera sees the BACK of the actual CC0 jacket. Sculpt two
    # continuous scapular ridges and a tapered rear shoulder sweep into the
    # imported four-weight triangles, not rigid floating shoulder armor.
    # Source model faces -Z; outward +Z normals identify its dorsal surface.
    var dorsal := smoothstep(0.18, 0.70, normal.z)
    var scapula := dorsal * exp(-pow((y - 0.685) / 0.09, 2.0)) * \
        exp(-pow((x - 0.24) / 0.14, 2.0))
    var dorsal_shoulder := dorsal * exp(-pow((y - 0.735) / 0.060, 2.0)) * \
        smoothstep(0.17, 0.30, x)
    var spine_channel := dorsal * exp(-pow(lateral / 0.09, 2.0)) * \
        exp(-pow((y - 0.62) / 0.13, 2.0))
    # A real athletic V-silhouette is sculpted into the SAME four-weight
    # imported triangles: full upper pectorals and deltoids, a tapered waist,
    # and a controlled central sternum ridge. The prior 0.03-unit shoulder
    # relief disappeared at mobile chase distance, leaving a thin stick body.
    # Keep the offset below the 0.18-unit barrel-chest safety limit.
    var depth := 0.012 + 0.065 * chest + 0.068 * shoulder + \
        0.043 * chest_ridge + 0.027 * collar + 0.049 * pectoral + \
        0.032 * deltoid + 0.015 * spine_keel + \
        0.052 * scapula + 0.032 * dorsal_shoulder + 0.016 * spine_channel
    # Shoulder breadth and pectoral depth follow the actual imported Skin;
    # no rigid shoulder boxes or unweighted cosmetic torso are introduced.
    var waist_inset := 0.052 * waist * smoothstep(0.12, 0.35, x)
    var spread := 0.082 * shoulder + 0.048 * deltoid - waist_inset + \
        0.045 * dorsal_shoulder
    return normal * depth + Vector3(signf(lateral) * spread, 0.006 * shoulder, 0.0)

func _jacket_material(bounds: AABB) -> ShaderMaterial:
    var material := ShaderMaterial.new()
    material.shader = preload("res://rider_external_jacket.gdshader")
    material.set_shader_parameter("rest_bottom", bounds.position.y)
    material.set_shader_parameter("rest_height", bounds.size.y)
    material.set_shader_parameter("rest_center_x", bounds.get_center().x)
    material.set_shader_parameter("rest_width", bounds.size.x)
    material.set_shader_parameter("rest_center_z", bounds.get_center().z)
    material.set_shader_parameter("rest_depth", bounds.size.z)
    return material
