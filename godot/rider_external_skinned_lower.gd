extends Node
## V124 draft: two true GPU-skinned lower-body garments from the imported
## CC0 humanoid's own indexed triangles. No new rig, rigid leg capsules,
## collisions, paid assets, or gameplay/landscape-touch changes.
var trousers: MeshInstance3D
var boots: MeshInstance3D
var trouser_vertices: int = 0
var boot_vertices: int = 0

func install(source_meshes: Array[MeshInstance3D]) -> bool:
    for body in source_meshes:
        if body == null or body.mesh == null or body.skin == null:
            continue
        if not String(body.name).contains("SuperHero"):
            continue
        var leg_mesh := _extract(body, 0.155, 0.425, 0.023)
        var boot_mesh := _extract(body, 0.025, 0.175, 0.027)
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
    garment.material_override = mat
    source.get_parent().add_child(garment)
    return garment

func _extract(source: MeshInstance3D, from_height: float, to_height: float, thickness: float) -> ArrayMesh:
    var bounds := source.mesh.get_aabb()
    var height := bounds.size.y
    if height < 0.5:
        return null
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
            var a := indices[triangle * 3] if not indices.is_empty() else triangle * 3
            var b := indices[triangle * 3 + 1] if not indices.is_empty() else triangle * 3 + 1
            var c := indices[triangle * 3 + 2] if not indices.is_empty() else triangle * 3 + 2
            if not _in_region(vertices[a], bounds.position.y, height, from_height, to_height):
                continue
            if not _in_region(vertices[b], bounds.position.y, height, from_height, to_height):
                continue
            if not _in_region(vertices[c], bounds.position.y, height, from_height, to_height):
                continue
            for vertex_id in [a, b, c]:
                var normal := normals[vertex_id].normalized()
                var y := (vertices[vertex_id].y - bounds.position.y) / height
                # Slight tailored knee and shin shaping, offset from the actual
                # animated skin instead of floating independent boot primitives.
                var knee := exp(-pow((y - 0.31) / 0.07, 2.0))
                var flare := exp(-pow((y - 0.09) / 0.065, 2.0))
                var offset := thickness + 0.010 * knee + 0.007 * flare
                output.set_normal(normal)
                output.set_bones(PackedInt32Array([
                    bones[vertex_id * 4], bones[vertex_id * 4 + 1],
                    bones[vertex_id * 4 + 2], bones[vertex_id * 4 + 3]]))
                output.set_weights(PackedFloat32Array([
                    weights[vertex_id * 4], weights[vertex_id * 4 + 1],
                    weights[vertex_id * 4 + 2], weights[vertex_id * 4 + 3]]))
                output.add_vertex(vertices[vertex_id] + normal * offset)
                accepted += 1
    if accepted < 120:
        return null
    return output.commit()

func _in_region(point: Vector3, bottom: float, height: float, minimum: float, maximum: float) -> bool:
    var normalized := (point.y - bottom) / height
    return normalized >= minimum and normalized <= maximum
