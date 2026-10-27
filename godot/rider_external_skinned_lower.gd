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
                # Athletic thigh/knee/shin volume and a broad hoverboot toe are
                # sculpted in the actual four-weight rest mesh, not rigid props.
                var offset := _sculpt_offset(vertices[vertex_id], normal, bounds, is_boot)
                output.set_normal(normal)
                output.set_bones(PackedInt32Array([
                    bones[vertex_id * 4], bones[vertex_id * 4 + 1],
                    bones[vertex_id * 4 + 2], bones[vertex_id * 4 + 3]]))
                output.set_weights(PackedFloat32Array([
                    weights[vertex_id * 4], weights[vertex_id * 4 + 1],
                    weights[vertex_id * 4 + 2], weights[vertex_id * 4 + 3]]))
                output.add_vertex(vertices[vertex_id] + offset)
                accepted += 1
    if accepted < 120:
        return null
    return output.commit()

func _in_region(point: Vector3, bottom: float, height: float, minimum: float, maximum: float) -> bool:
    var normalized := (point.y - bottom) / height
    return normalized >= minimum and normalized <= maximum

## One cohesive rest-space profile for both lower garments. All distances
## scale with the imported model; original Skin indices and weights are copied.
## This is a visible silhouette change, not a shader-only recolor.
func _sculpt_offset(point: Vector3, normal: Vector3, bounds: AABB, is_boot: bool) -> Vector3:
    var y := (point.y - bounds.position.y) / maxf(bounds.size.y, 0.001)
    var lateral := (point.x - bounds.get_center().x) / maxf(bounds.size.x, 0.001)
    var thigh := exp(-pow((y - 0.385) / 0.075, 2.0))
    var knee := exp(-pow((y - 0.305) / 0.048, 2.0))
    var shin := exp(-pow((y - 0.205) / 0.070, 2.0))
    var toe := exp(-pow((y - 0.085) / 0.055, 2.0))
    var boot := 1.0 if is_boot else 0.0
    var depth := 0.029 + 0.039 * thigh + 0.055 * knee + 0.044 * shin + boot * 0.049 * toe
    var outside := smoothstep(0.075, 0.24, absf(lateral))
    var side_spread := outside * (0.022 * thigh + 0.033 * knee + 0.022 * shin + boot * 0.035 * toe)
    return normal * depth + Vector3(signf(lateral) * side_spread, 0.0, 0.0)
