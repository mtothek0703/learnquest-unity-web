extends Node
## V124 draft: two true GPU-skinned lower-body garments from the imported
## CC0 humanoid's own indexed triangles. No new rig, rigid leg capsules,
## collisions, paid assets, or gameplay/landscape-touch changes.
var trousers: MeshInstance3D
var boots: MeshInstance3D
var trouser_vertices: int = 0
var boot_vertices: int = 0
var face_sign: float = -1.0

func install(source_meshes: Array[MeshInstance3D], forward_sign: float = -1.0) -> bool:
    # Forward is inferred from the real imported eyes/Head, not an assumed GLB axis.
    face_sign = 1.0 if forward_sign > 0.0 else -1.0
    for body in source_meshes:
        if body == null or body.mesh == null or body.skin == null:
            continue
        if not String(body.name).contains("SuperHero"):
            continue
        var leg_mesh := _extract(body, 0.155, 0.425, false)
        var boot_mesh := _extract(body, 0.025, 0.175, true)
        if leg_mesh == null or boot_mesh == null:
            continue
        trousers = _make_garment(body, leg_mesh, "TrueSkinnedFlightTrousers", false)
        boots = _make_garment(body, boot_mesh, "TrueSkinnedHoverBoots", true)
        trouser_vertices = _count_vertices(leg_mesh)
        boot_vertices = _count_vertices(boot_mesh)
        return true
    return false

func _count_vertices(mesh: ArrayMesh) -> int:
    var count := 0
    for surface in range(mesh.get_surface_count()):
        count += mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX].size()
    return count

func _make_garment(source: MeshInstance3D, mesh: ArrayMesh, label: String, is_boot: bool) -> MeshInstance3D:
    var garment := MeshInstance3D.new()
    garment.name = label
    garment.mesh = mesh
    garment.skin = source.skin
    garment.skeleton = source.skeleton
    garment.transform = source.transform
    var mat := ShaderMaterial.new()
    mat.shader = preload("res://rider_external_lower.gdshader")
    mat.set_shader_parameter("boot_mode", 1.0 if is_boot else 0.0)
    mat.set_shader_parameter("face_sign", face_sign)
    var bounds := source.mesh.get_aabb()
    mat.set_shader_parameter("rest_bottom", bounds.position.y)
    mat.set_shader_parameter("rest_height", bounds.size.y)
    mat.set_shader_parameter("rest_center_x", bounds.get_center().x)
    mat.set_shader_parameter("rest_width", bounds.size.x)
    garment.material_override = mat
    source.get_parent().add_child(garment)
    return garment

func _extract(source: MeshInstance3D, from_height: float, to_height: float, is_boot: bool) -> ArrayMesh:
    var bounds := source.mesh.get_aabb()
    var height := bounds.size.y
    if height < 0.5:
        return null
    var bottom_y := bounds.position.y + height * from_height
    var top_y := bounds.position.y + height * to_height
    var output := SurfaceTool.new()
    output.begin(Mesh.PRIMITIVE_TRIANGLES)
    var accepted := 0
    for surface in range(source.mesh.get_surface_count()):
        if source.mesh.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
            continue
        var arrays: Array = source.mesh.surface_get_arrays(surface)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
        if vertices.is_empty() or normals.size() != vertices.size():
            continue
        if bones.size() != vertices.size() * 4 or weights.size() != vertices.size() * 4:
            continue
        var triangle_count := int(indices.size() / 3) if not indices.is_empty() else int(vertices.size() / 3)
        for triangle in range(triangle_count):
            var polygon: Array[Dictionary] = []
            for corner in range(3):
                var vertex_id := indices[triangle * 3 + corner] if not indices.is_empty() else triangle * 3 + corner
                polygon.append(_source_corner(vertices, normals, bones, weights, vertex_id))
            # Keep intersecting source triangles instead of dropping them
            # wholesale at the waist, ankle or upper boot opening.
            polygon = _clip_to_height(polygon, bottom_y, true)
            polygon = _clip_to_height(polygon, top_y, false)
            if polygon.size() < 3:
                continue
            for corner in range(1, polygon.size() - 1):
                for vertex in [polygon[0], polygon[corner], polygon[corner + 1]]:
                    var point: Vector3 = vertex["position"]
                    var normal: Vector3 = vertex["normal"]
                    output.set_normal(normal)
                    output.set_bones(vertex["bones"])
                    output.set_weights(vertex["weights"])
                    output.add_vertex(point + _sculpt_offset(point, normal, bounds, is_boot))
                    accepted += 1
    if accepted < 120:
        return null
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


func _in_region(point: Vector3, bottom: float, height: float, minimum: float, maximum: float) -> bool:
    var normalized := (point.y - bottom) / height
    return normalized >= minimum and normalized <= maximum

## One cohesive rest-space profile for both lower garments. All distances
## scale with the imported model; original Skin indices and weights are copied.
## This is a visible silhouette change, not a shader-only recolor.
func _sculpt_offset(point: Vector3, normal: Vector3, bounds: AABB, is_boot: bool) -> Vector3:
    # Continuous original four-weight triangles, not a rigid shoe replacement.
    # Model the whole foot silhouette (toe/instep/heel/sole), shin guards and
    # ankle collar in the imported rest pose; all deformation stays on the
    # original 65-joint Skin and follows ankle/calf articulation.
    var y := (point.y - bounds.position.y) / maxf(bounds.size.y, 0.001)
    var lateral := (point.x - bounds.get_center().x) / maxf(bounds.size.x, 0.001)
    var thigh := exp(-pow((y - 0.385) / 0.075, 2.0))
    var knee := exp(-pow((y - 0.305) / 0.048, 2.0))
    var shin := exp(-pow((y - 0.205) / 0.070, 2.0))
    var toe := exp(-pow((y - 0.085) / 0.055, 2.0))
    var forefoot := exp(-pow((y - 0.088) / 0.040, 2.0))
    var instep := exp(-pow((y - 0.132) / 0.032, 2.0))
    var heel := exp(-pow((y - 0.070) / 0.032, 2.0))
    var sole := exp(-pow((y - 0.045) / 0.014, 2.0))
    var shin_guard := exp(-pow((y - 0.225) / 0.054, 2.0))
    var boot := 1.0 if is_boot else 0.0
    var ankle_cuff := exp(-pow((y - 0.155) / 0.017, 2.0))
    var front := maxf(0.0, normal.z * face_sign)
    var back := maxf(0.0, -normal.z * face_sign)
    # Bilateral centerlines are measured against the imported total width.
    var leg_center := absf(absf(lateral) - 0.24)
    var central_ridge := 1.0 - smoothstep(0.025, 0.15, leg_center)
    var depth := 0.029 + 0.039 * thigh + 0.055 * knee + 0.044 * shin + \
        boot * (0.049 * toe + 0.047 * ankle_cuff + 0.048 * shin_guard * front * central_ridge + \
        0.058 * instep * front + 0.035 * heel * back + 0.040 * sole)
    var outside := smoothstep(0.075, 0.24, absf(lateral))
    var side_spread := outside * (0.022 * thigh + 0.033 * knee + \
        0.022 * shin + boot * (0.035 * toe + 0.032 * ankle_cuff + \
        0.035 * forefoot + 0.023 * sole))
    # A real forward-swept toe and a separate rear heel counter. The sign is
    # determined by the imported eyes; both feet share one mirrored profile.
    var fore_aft := boot * (0.105 * forefoot * front + 0.042 * instep * front - \
        0.045 * heel * back)
    return normal * depth + Vector3(signf(lateral) * side_spread, \
        -boot * sole * 0.017, face_sign * fore_aft)
