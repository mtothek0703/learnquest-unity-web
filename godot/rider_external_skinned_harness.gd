extends Node
## V124 draft: one coherent four-band racing harness sculpted directly from the
## imported CC0 jacket triangles. Unlike rigid decals, EVERY triangle retains
## four original Skin influences, including interpolated diagonal seam cuts.
## Two front shoulder-to-waist bands and two rear waist-to-shoulder bands make
## a continuous 360-degree costume language. Pure visual geometry, no collision.
var harness: MeshInstance3D
var front_vertices: int = 0
var rear_vertices: int = 0

func install(jacket: MeshInstance3D, face_sign: float) -> bool:
    if jacket == null or jacket.mesh == null or jacket.skin == null or absf(face_sign) < 0.5:
        return false
    var sculpt := _sculpt(jacket.mesh, face_sign)
    if sculpt == null or front_vertices < 120 or rear_vertices < 120:
        return false
    harness = MeshInstance3D.new()
    harness.name = "FourWeightSculptedFlightHarness"
    harness.mesh = sculpt
    harness.skin = jacket.skin
    harness.skeleton = jacket.skeleton
    harness.transform = jacket.transform
    var material := StandardMaterial3D.new()
    material.vertex_color_use_as_albedo = true
    material.albedo_color = Color.WHITE
    material.metallic = 0.34
    material.roughness = 0.35
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    harness.material_override = material
    jacket.get_parent().add_child(harness)
    return true

func _sculpt(source: Mesh, face_sign: float) -> ArrayMesh:
    var bounds := source.get_aabb()
    if bounds.size.x < 0.1 or bounds.size.y < 0.4:
        return null
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    front_vertices = 0
    rear_vertices = 0
    for surface in range(source.get_surface_count()):
        if source.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
            continue
        var data: Array = source.surface_get_arrays(surface)
        var positions: PackedVector3Array = data[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = data[Mesh.ARRAY_NORMAL]
        var bones: PackedInt32Array = data[Mesh.ARRAY_BONES]
        var weights: PackedFloat32Array = data[Mesh.ARRAY_WEIGHTS]
        if normals.size() != positions.size() or bones.size() != positions.size() * 4 or weights.size() != positions.size() * 4:
            continue
        var indices := PackedInt32Array()
        if data[Mesh.ARRAY_INDEX] != null:
            indices = data[Mesh.ARRAY_INDEX]
        var triangles := int(indices.size() / 3) if not indices.is_empty() else int(positions.size() / 3)
        for triangle in range(triangles):
            var source_corners: Array[Dictionary] = []
            var facing := 0.0
            for k in range(3):
                var i := indices[triangle * 3 + k] if not indices.is_empty() else triangle * 3 + k
                var start := i * 4
                source_corners.append({
                    "position": positions[i], "normal": normals[i].normalized(),
                    "bones": PackedInt32Array([bones[start], bones[start + 1], bones[start + 2], bones[start + 3]]),
                    "weights": PackedFloat32Array([weights[start], weights[start + 1], weights[start + 2], weights[start + 3]])
                })
                facing += normals[i].z * face_sign
            if absf(facing) < 0.38:
                continue
            var front := facing > 0.0
            for side in [-1.0, 1.0]:
                var clipped := _clip_band(source_corners, bounds, side, 0.052)
                if clipped.size() < 3:
                    continue
                for j in range(1, clipped.size() - 1):
                    for corner in [clipped[0], clipped[j], clipped[j + 1]]:
                        var point: Vector3 = corner["position"]
                        var normal: Vector3 = corner["normal"]
                        var v := (point.y - bounds.position.y) / bounds.size.y
                        var u := (point.x - bounds.get_center().x) / bounds.size.x
                        var stripe := absf(_signed_band(point, bounds, side)) / 0.052
                        var relief := 0.008 + 0.015 * (1.0 - smoothstep(0.20, 1.0, stripe))
                        var highlight := 0.15 * sin(PI * clampf((v - 0.23) / 0.60, 0.0, 1.0))
                        var base := Color(0.38, 0.11, 0.56) if front else Color(0.06, 0.32, 0.51)
                        var tint := Color(0.84, 0.26, 0.66) if front else Color(0.16, 0.79, 0.94)
                        tool.set_color(base.lerp(tint, clampf(0.40 + highlight + (1.0 - stripe) * 0.24, 0.0, 0.85)))
                        tool.set_normal(normal)
                        tool.set_bones(corner["bones"])
                        tool.set_weights(corner["weights"])
                        tool.add_vertex(point + normal * relief)
                        if front:
                            front_vertices += 1
                        else:
                            rear_vertices += 1
    if front_vertices < 120 or rear_vertices < 120:
        return null
    return tool.commit()

func _signed_band(point: Vector3, bounds: AABB, side: float) -> float:
    var u := (point.x - bounds.get_center().x) / bounds.size.x
    var v := (point.y - bounds.position.y) / bounds.size.y
    # Broad V from a narrow waist buckle to both shoulders; mirrored on rear.
    return side * u - (0.018 + 0.165 * (v - 0.23) / 0.60)

func _clip_band(source: Array[Dictionary], bounds: AABB, side: float, half_width: float) -> Array[Dictionary]:
    var polygon := _clip_plane(source, bounds, side, -half_width, true, false)
    polygon = _clip_plane(polygon, bounds, side, half_width, false, false)
    polygon = _clip_plane(polygon, bounds, side, 0.23, true, true)
    return _clip_plane(polygon, bounds, side, 0.83, false, true)

func _clip_plane(polygon: Array[Dictionary], bounds: AABB, side: float,
        threshold: float, keep_above: bool, height_plane: bool) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if polygon.is_empty():
        return result
    var previous: Dictionary = polygon[polygon.size() - 1]
    for current in polygon:
        var prev_pos: Vector3 = previous["position"]
        var curr_pos: Vector3 = current["position"]
        var a := (prev_pos.y - bounds.position.y) / bounds.size.y if height_plane else _signed_band(prev_pos, bounds, side)
        var b := (curr_pos.y - bounds.position.y) / bounds.size.y if height_plane else _signed_band(curr_pos, bounds, side)
        var inside_a := a >= threshold if keep_above else a <= threshold
        var inside_b := b >= threshold if keep_above else b <= threshold
        if inside_a != inside_b and absf(b - a) > 0.0000001:
            result.append(_blend(previous, current, clampf((threshold - a) / (b - a), 0.0, 1.0)))
        if inside_b:
            result.append(current)
        previous = current
    return result

func _blend(a: Dictionary, b: Dictionary, t: float) -> Dictionary:
    var influences: Dictionary = {}
    for slot in range(4):
        var ids_a: PackedInt32Array = a["bones"]
        var ids_b: PackedInt32Array = b["bones"]
        var weights_a: PackedFloat32Array = a["weights"]
        var weights_b: PackedFloat32Array = b["weights"]
        influences[ids_a[slot]] = float(influences.get(ids_a[slot], 0.0)) + weights_a[slot] * (1.0 - t)
        influences[ids_b[slot]] = float(influences.get(ids_b[slot], 0.0)) + weights_b[slot] * t
    var ids := PackedInt32Array()
    var weights := PackedFloat32Array()
    var total := 0.0
    for slot in range(4):
        var best := 0
        var strength := -1.0
        for key in influences.keys():
            if float(influences[key]) > strength:
                best = int(key)
                strength = float(influences[key])
        ids.append(best)
        weights.append(maxf(0.0, strength))
        total += maxf(0.0, strength)
        influences.erase(best)
    if total > 0.000001:
        for slot in range(4):
            weights[slot] /= total
    return {
        "position": (a["position"] as Vector3).lerp(b["position"], t),
        "normal": (a["normal"] as Vector3).lerp(b["normal"], t).normalized(),
        "bones": ids, "weights": weights
    }
