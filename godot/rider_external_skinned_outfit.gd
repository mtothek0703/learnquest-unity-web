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
            var a := indices[triangle * 3] if not indices.is_empty() else triangle * 3
            var b := indices[triangle * 3 + 1] if not indices.is_empty() else triangle * 3 + 1
            var c := indices[triangle * 3 + 2] if not indices.is_empty() else triangle * 3 + 2
            if not _is_jacket_vertex(verts[a], bottom, height):
                continue
            if not _is_jacket_vertex(verts[b], bottom, height):
                continue
            if not _is_jacket_vertex(verts[c], bottom, height):
                continue
            for vertex_id in [a, b, c]:
                var normal := normals[vertex_id].normalized()
                # Whole-torso silhouette pass: shaped chest, tapered waist and
                # anatomically broad shoulders follow the ORIGINAL skin weights.
                # No separate rigid chest boxes, collisions or bone edits.
                var displacement := _tailored_offset(verts[vertex_id], normal, bounds)
                output.set_normal(normal)
                output.set_bones(PackedInt32Array([
                    bones[vertex_id * 4], bones[vertex_id * 4 + 1],
                    bones[vertex_id * 4 + 2], bones[vertex_id * 4 + 3]]))
                output.set_weights(PackedFloat32Array([
                    weights[vertex_id * 4], weights[vertex_id * 4 + 1],
                    weights[vertex_id * 4 + 2], weights[vertex_id * 4 + 3]]))
                output.add_vertex(verts[vertex_id] + displacement)
                accepted += 1
    if accepted < 300:
        return null
    generated_vertices = accepted
    return output.commit()

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
    var depth: float = 0.022 + 0.064 * chest + 0.054 * shoulder + \
        0.009 * waist + 0.031 * chest_ridge + 0.022 * collar - 0.009 * side_taper
    var spread: float = 0.042 * shoulder + 0.015 * chest_ridge
    return normal * depth + Vector3(signf(lateral) * spread, 0.012 * shoulder, 0.0)

func _jacket_material(bounds: AABB) -> ShaderMaterial:
    var material := ShaderMaterial.new()
    material.shader = preload("res://rider_external_jacket.gdshader")
    material.set_shader_parameter("rest_bottom", bounds.position.y)
    material.set_shader_parameter("rest_height", bounds.size.y)
    material.set_shader_parameter("rest_center_x", bounds.get_center().x)
    material.set_shader_parameter("rest_width", bounds.size.x)
    return material
