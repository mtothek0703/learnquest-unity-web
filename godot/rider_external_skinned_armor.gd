extends Node
## V124 DRAFT: three large, anatomical armor panels are rebuilt from the
## imported hero's GPU-skinned jacket triangles. They are NOT rigid plates:
## every new vertex inherits interpolated weights from the original CC0 Skin.
## Panels follow chest/spine/shoulder poses without adding collision shapes.
var panels: Array[MeshInstance3D] = []
var vertex_counts: Array[int] = []

func install(jacket: MeshInstance3D, face_sign: float) -> bool:
    if jacket == null or jacket.mesh == null or jacket.skin == null:
        return false
    if absf(face_sign) < 0.5:
        return false
    var specs := [
        {"name": "SkinnedLeftPectoral", "left": -0.37, "right": -0.025,
            "low": 0.22, "high": 0.88, "front": true,
            "color": Color(0.055, 0.19, 0.49)},
        {"name": "SkinnedRightPectoral", "left": 0.025, "right": 0.37,
            "low": 0.22, "high": 0.88, "front": true,
            "color": Color(0.055, 0.19, 0.49)},
        {"name": "SkinnedSpineShield", "left": -0.23, "right": 0.23,
            "low": 0.13, "high": 0.93, "front": false,
            "color": Color(0.095, 0.08, 0.27)}
    ]
    for spec in specs:
        var mesh := _extract_panel(jacket.mesh, spec, face_sign)
        if mesh == null:
            return false
        var part := MeshInstance3D.new()
        part.name = spec["name"]
        part.mesh = mesh
        part.skin = jacket.skin
        part.skeleton = jacket.skeleton
        part.transform = jacket.transform
        var material := StandardMaterial3D.new()
        material.albedo_color = Color.WHITE
        material.vertex_color_use_as_albedo = true
        material.metallic = 0.29
        material.roughness = 0.47
        material.cull_mode = BaseMaterial3D.CULL_DISABLED
        part.material_override = material
        jacket.get_parent().add_child(part)
        panels.append(part)
        vertex_counts.append(mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size())
    return panels.size() == 3

func _extract_panel(source: Mesh, spec: Dictionary, face_sign: float) -> ArrayMesh:
    var bounds := source.get_aabb()
    if bounds.size.x < 0.05 or bounds.size.y < 0.05:
        return null
    var x0 := bounds.get_center().x + bounds.size.x * float(spec["left"])
    var x1 := bounds.get_center().x + bounds.size.x * float(spec["right"])
    var y0 := bounds.position.y + bounds.size.y * float(spec["low"])
    var y1 := bounds.position.y + bounds.size.y * float(spec["high"])
    var output := SurfaceTool.new()
    output.begin(Mesh.PRIMITIVE_TRIANGLES)
    var accepted := 0
    for surface in range(source.get_surface_count()):
        if source.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
            continue
        var arrays := source.surface_get_arrays(surface)
        var positions: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        # SurfaceTool's unindexed jacket has a null INDEX slot in Godot 4.
        var indices := PackedInt32Array()
        if arrays[Mesh.ARRAY_INDEX] != null:
            indices = arrays[Mesh.ARRAY_INDEX]
        if normals.size() != positions.size() or bones.size() != positions.size() * 4 or weights.size() != positions.size() * 4:
            continue
        var triangles := int(indices.size() / 3) if not indices.is_empty() else int(positions.size() / 3)
        for triangle in range(triangles):
            var polygon: Array[Dictionary] = []
            var facing := 0.0
            for corner in range(3):
                var i := indices[triangle * 3 + corner] if not indices.is_empty() else triangle * 3 + corner
                polygon.append(_source_corner(positions, normals, bones, weights, i))
                facing += normals[i].z * face_sign
            # The chest and rear shield are selected from actual outward-facing
            # torso surfaces, not flat rectangular overlays across the body.
            if (facing > 0.38) != bool(spec["front"]):
                continue
            polygon = _clip(polygon, 0, x0, true)
            polygon = _clip(polygon, 0, x1, false)
            polygon = _clip(polygon, 1, y0, true)
            polygon = _clip(polygon, 1, y1, false)
            for corner in range(1, polygon.size() - 1):
                for vertex in [polygon[0], polygon[corner], polygon[corner + 1]]:
                    var p: Vector3 = vertex["position"]
                    var normal: Vector3 = vertex["normal"]
                    var u := (p.x - x0) / maxf(x1 - x0, 0.0001)
                    var v := (p.y - y0) / maxf(y1 - y0, 0.0001)
                    # Broad, shallow anatomical facets conform to the
                    # weighted jacket instead of creating a barrel chest.
                    var depth := _panel_relief(u, v, bool(spec["front"]))
                    var base_color: Color = spec["color"]
                    var vein := exp(-pow((u - 0.50 - 0.22 * (v - 0.50)) / 0.085, 2.0)) * \
                        smoothstep(0.15, 0.40, v)
                    var border := exp(-pow((u - 0.075) / 0.065, 2.0)) + \
                        exp(-pow((u - 0.925) / 0.065, 2.0))
                    var color := base_color.lerp(Color(0.09, 0.62, 0.86), clampf(vein * 0.42 + border * 0.16, 0.0, 0.58))
                    output.set_color(color)
                    output.set_normal(normal)
                    output.set_bones(vertex["bones"])
                    output.set_weights(vertex["weights"])
                    output.add_vertex(p + normal * depth)
                    accepted += 1
    if accepted < 90:
        return null
    return output.commit()

func _panel_relief(u: float, v: float, is_front: bool) -> float:
    # Continuous rounded facets with a beveled border and shallow center.
    # Back shield receives a narrow spine keel, not a second bulky backpack.
    var bevel := smoothstep(0.0, 0.14, minf(u, 1.0 - u)) * \
        smoothstep(0.0, 0.15, minf(v, 1.0 - v))
    var curved := sin(PI * u) * sin(PI * v)
    var keel := 0.0 if is_front else 0.006 * exp(-pow((u - 0.5) / 0.18, 2.0))
    return 0.006 + 0.021 * bevel + 0.009 * curved + keel

func _source_corner(positions: PackedVector3Array, normals: PackedVector3Array,
        bones: PackedInt32Array, weights: PackedFloat32Array, index: int) -> Dictionary:
    var k := index * 4
    return {"position": positions[index], "normal": normals[index].normalized(),
        "bones": PackedInt32Array([bones[k], bones[k + 1], bones[k + 2], bones[k + 3]]),
        "weights": PackedFloat32Array([weights[k], weights[k + 1], weights[k + 2], weights[k + 3]])}

func _clip(polygon: Array[Dictionary], axis: int, plane: float, keep_above: bool) -> Array[Dictionary]:
    var out: Array[Dictionary] = []
    if polygon.is_empty():
        return out
    var previous: Dictionary = polygon[polygon.size() - 1]
    for current in polygon:
        var before := float((previous["position"] as Vector3)[axis])
        var now := float((current["position"] as Vector3)[axis])
        var inside_before := before >= plane if keep_above else before <= plane
        var inside_now := now >= plane if keep_above else now <= plane
        if inside_before != inside_now and absf(now - before) > 0.0000001:
            out.append(_interpolate(previous, current, clampf((plane - before) / (now - before), 0.0, 1.0)))
        if inside_now:
            out.append(current)
        previous = current
    return out

func _interpolate(a: Dictionary, b: Dictionary, t: float) -> Dictionary:
    var combined: Dictionary = {}
    for slot in range(4):
        var a_bones: PackedInt32Array = a["bones"]
        var b_bones: PackedInt32Array = b["bones"]
        var a_weights: PackedFloat32Array = a["weights"]
        var b_weights: PackedFloat32Array = b["weights"]
        combined[a_bones[slot]] = float(combined.get(a_bones[slot], 0.0)) + a_weights[slot] * (1.0 - t)
        combined[b_bones[slot]] = float(combined.get(b_bones[slot], 0.0)) + b_weights[slot] * t
    var ids := PackedInt32Array()
    var weights := PackedFloat32Array()
    var total := 0.0
    for slot in range(4):
        var best := -1
        var strength := -1.0
        for candidate in combined.keys():
            if float(combined[candidate]) > strength:
                best = int(candidate)
                strength = float(combined[candidate])
        ids.append(best if best >= 0 else 0)
        weights.append(maxf(0.0, strength))
        total += maxf(0.0, strength)
        combined.erase(best)
    if total > 0.000001:
        for slot in range(4):
            weights[slot] /= total
    return {"position": (a["position"] as Vector3).lerp(b["position"], t),
        "normal": (a["normal"] as Vector3).lerp(b["normal"], t).normalized(),
        "bones": ids, "weights": weights}
