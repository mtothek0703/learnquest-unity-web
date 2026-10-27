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
        garment.material_override = _jacket_material()
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
                var normalized_y := (verts[vertex_id].y - bottom) / height
                # Shaped chest panels and shoulder bulge, no giant rigid boxes.
                var thickness := 0.020 + 0.014 * sin(clampf((normalized_y - 0.42) / 0.36, 0.0, 1.0) * PI)
                output.set_normal(normal)
                output.set_bones(PackedInt32Array([
                    bones[vertex_id * 4], bones[vertex_id * 4 + 1],
                    bones[vertex_id * 4 + 2], bones[vertex_id * 4 + 3]]))
                output.set_weights(PackedFloat32Array([
                    weights[vertex_id * 4], weights[vertex_id * 4 + 1],
                    weights[vertex_id * 4 + 2], weights[vertex_id * 4 + 3]]))
                output.add_vertex(verts[vertex_id] + normal * thickness)
                accepted += 1
    if accepted < 300:
        return null
    generated_vertices = accepted
    return output.commit()

func _is_jacket_vertex(point: Vector3, bottom: float, height: float) -> bool:
    var y := (point.y - bottom) / height
    return y >= 0.43 and y <= 0.78

func _jacket_material() -> ShaderMaterial:
    var material := ShaderMaterial.new()
    material.shader = preload("res://rider_external_jacket.gdshader")
    return material
