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
    var output := SurfaceTool.new()
    output.begin(Mesh.PRIMITIVE_TRIANGLES)
    var accepted := 0
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
                polygon.append(_source_corner(verts, normals, bones, weights, vertex_id))
            polygon = _clip_to_height(polygon, waist_y, true)
            polygon = _clip_to_height(polygon, collar_y, false)
            if polygon.size() < 3:
                continue
            for corner_index in range(1, polygon.size() - 1):
                for corner in [polygon[0], polygon[corner_index], polygon[corner_index + 1]]:
                    var point: Vector3 = corner["position"]
                    var normal: Vector3 = corner["normal"]
                    output.set_normal(normal)
                    output.set_bones(corner["bones"])
                    output.set_weights(corner["weights"])
                    output.add_vertex(point + _tailored_offset(point, normal, bounds))
                    accepted += 1
    if accepted < 300:
        return null
    generated_vertices = accepted
    return output.commit()

func _source_corner(vertices: PackedVector3Array, normals: PackedVector3Array,
        bones: PackedInt32Array, weights: PackedFloat32Array, index: int) -> Dictionary:
    var start := index * 4
    return {
        "position": vertices[index],
        "normal": normals[index].normalized(),
        "bones": PackedInt32Array([bones[start], bones[start + 1],
            bones[start + 2], bones[start + 3]]),
        "weights": PackedFloat32Array([weights[start], weights[start + 1],
            weights[start + 2], weights[start + 3]])
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
    return clipped

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
        "weights": out_weights
    }

func _is_jacket_vertex(point: Vector3, bottom: float, height: float) -> bool:
    var y := (point.y - bottom) / height
    return y >= 0.43 and y <= 0.78

func _tailored_offset(point: Vector3, normal: Vector3, bounds: AABB) -> Vector3:
    # Normalized proportions use the actual imported CC0 mesh, not guessed
    # world-space units. The silhouette is fuller at chest/shoulder and
    # deliberately narrower at the waist, without breaking 4-weight skinning.
    var y: float = (point.y - bounds.position.y) / bounds.size.y
    var lateral: float = (point.x - bounds.get_center().x) / bounds.size.x
    var chest: float = exp(-pow((y - 0.635) / 0.105, 2.0)) * (1.0 - smoothstep(0.23, 0.43, absf(lateral)))
    var shoulder: float = exp(-pow((y - 0.735) / 0.075, 2.0)) * smoothstep(0.065, 0.30, absf(lateral))
    var waist: float = exp(-pow((y - 0.465) / 0.055, 2.0))
    # A continuous raised V-shaped flight-jacket chest and shoulder yoke,
    # carved into the SAME four-weight source triangles. The ridge follows
    # the original torso through lean, jump and boost, unlike rigid plates.
    var diagonal := absf(lateral) - (0.11 + 0.28 * (y - 0.55))
    var chest_ridge := exp(-pow(diagonal / 0.055, 2.0)) * \
        exp(-pow((y - 0.635) / 0.115, 2.0))
    var collar := exp(-pow((y - 0.765) / 0.026, 2.0)) * \
        (1.0 - smoothstep(0.17, 0.38, absf(lateral)))
    var side_taper := smoothstep(0.23, 0.43, absf(lateral)) * \
        exp(-pow((y - 0.51) / 0.09, 2.0))
    # One coherent skinned anatomical profile: broad deltoid caps, paired
    # pectoral volumes and a raised central sternum/spine ridge. These are
    # deformations of the imported weighted triangles, not rigid add-ons.
    var pectoral := exp(-pow((y - 0.655) / 0.075, 2.0)) * \
        exp(-pow((absf(lateral) - 0.17) / 0.11, 2.0))
    var deltoid := exp(-pow((y - 0.715) / 0.055, 2.0)) * \
        smoothstep(0.18, 0.32, absf(lateral))
    var spine_keel := exp(-pow(lateral / 0.065, 2.0)) * \
        exp(-pow((y - 0.61) / 0.13, 2.0))
    var depth: float = 0.022 + 0.064 * chest + 0.054 * shoulder + \
        0.009 * waist + 0.031 * chest_ridge + 0.022 * collar - \
        0.009 * side_taper + 0.037 * pectoral + 0.027 * deltoid + \
        0.016 * spine_keel
    var spread: float = 0.042 * shoulder + 0.015 * chest_ridge + \
        0.032 * deltoid - 0.020 * waist * smoothstep(0.12, 0.35, absf(lateral))
    return normal * depth + Vector3(signf(lateral) * spread, 0.012 * shoulder, 0.0)

func _jacket_material(bounds: AABB) -> ShaderMaterial:
    var material := ShaderMaterial.new()
    material.shader = preload("res://rider_external_jacket.gdshader")
    material.set_shader_parameter("rest_bottom", bounds.position.y)
    material.set_shader_parameter("rest_height", bounds.size.y)
    material.set_shader_parameter("rest_center_x", bounds.get_center().x)
    material.set_shader_parameter("rest_width", bounds.size.x)
    return material
