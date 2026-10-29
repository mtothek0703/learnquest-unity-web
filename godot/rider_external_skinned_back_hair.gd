extends Node
## V124: convert the continuous sculpted rear hair shell from a rigid Head
## attachment into genuine four-influence GPU-skinned geometry. The source
## glTF Skin and its inverse bind matrices are never modified.
## All coordinates are reconstructed in the source body's REST space.
var curtain: MeshInstance3D
var original: MeshInstance3D
var vertex_count: int = 0
var root_head_weight: float = 0.0
var tip_head_weight: float = 0.0

func install(source_meshes: Array[MeshInstance3D], rig: Skeleton3D,
        headwear: BoneAttachment3D) -> bool:
    if rig == null or headwear == null:
        return false
    var original_curtain := headwear.get_node_or_null("SculptedBackHairCurtain") as MeshInstance3D
    if original_curtain == null or original_curtain.mesh == null:
        return false
    var head_id := rig.find_bone("Head")
    if head_id < 0:
        return false
    var source: MeshInstance3D
    for item in source_meshes:
        if item != null and item.skin != null and item.mesh != null and String(item.name).contains("SuperHero"):
            source = item
            break
    if source == null:
        return false
    var bindings := PackedInt32Array()
    for name in ["Head", "neck_01", "spine_02", "spine_01"]:
        var index := _bind(source.skin, rig, name)
        if index < 0:
            return false
        bindings.append(index)
    var rest := rig.get_bone_global_rest(head_id)
    var original_bounds := original_curtain.mesh.get_aabb()
    if original_bounds.size.y < 0.05:
        return false
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var vertices_written := 0
    for surface_index in range(original_curtain.mesh.get_surface_count()):
        if original_curtain.mesh.surface_get_primitive_type(surface_index) != Mesh.PRIMITIVE_TRIANGLES:
            continue
        var arrays: Array = original_curtain.mesh.surface_get_arrays(surface_index)
        var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR] if arrays[Mesh.ARRAY_COLOR] != null else PackedColorArray()
        var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
        if points.is_empty() or normals.size() != points.size():
            return false
        var count := indices.size() if not indices.is_empty() else points.size()
        for i in range(count):
            var index := indices[i] if not indices.is_empty() else i
            var local_point := original_curtain.transform * points[index]
            # The generated shell is in Head-local rest coordinates; applying
            # the ORIGINAL bone rest (not its animated pose) prevents double
            # deformation when the GPU subsequently applies the imported Skin.
            var skeleton_rest_point := rest * local_point
            var body_point := source.to_local(rig.to_global(skeleton_rest_point))
            var local_normal := original_curtain.transform.basis * normals[index]
            var world_normal := rig.global_transform.basis * rest.basis * local_normal
            var body_normal := (source.global_transform.basis.inverse() * world_normal).normalized()
            if not body_point.is_finite() or not body_normal.is_finite():
                return false
            var down := clampf((original_bounds.end.y - points[index].y) /
                original_bounds.size.y, 0.0, 1.0)
            tool.set_bones(bindings)
            tool.set_weights(_weights(down))
            tool.set_normal(body_normal)
            tool.set_color(colors[index] if colors.size() == points.size() else Color.WHITE)
            tool.add_vertex(body_point)
            vertices_written += 1
    if vertices_written < 2000:
        return false
    var mesh := tool.commit()
    if mesh == null:
        return false
    var new_curtain := MeshInstance3D.new()
    new_curtain.name = "TrueSkinnedBackHairCurtain"
    new_curtain.mesh = mesh
    new_curtain.skin = source.skin
    new_curtain.skeleton = source.skeleton
    new_curtain.transform = source.transform
    new_curtain.material_override = original_curtain.material_override
    source.get_parent().add_child(new_curtain)
    # Only retire the rigid duplicate AFTER the real weighted replacement is
    # installed. All expressive locks, fringe, face and original bones stay.
    original_curtain.visible = false
    curtain = new_curtain
    original = original_curtain
    vertex_count = vertices_written
    root_head_weight = _weights(0.0)[0]
    tip_head_weight = _weights(1.0)[0]
    return true

func _bind(skin: Skin, rig: Skeleton3D, target: String) -> int:
    for index in range(skin.get_bind_count()):
        var name := String(skin.get_bind_name(index))
        var bone := skin.get_bind_bone(index)
        if name == target or (name.is_empty() and bone >= 0 and
                bone < rig.get_bone_count() and rig.get_bone_name(bone) == target):
            return index
    return -1

func _weights(down: float) -> PackedFloat32Array:
    var t := smoothstep(0.0, 1.0, clampf(down, 0.0, 1.0))
    # Root follows Head nearly rigidly; the shoulder-length lower shell
    # progressively inherits neck/spine motion, reducing head-turn clipping.
    # All four original joints retain strictly positive, normalized weights.
    return PackedFloat32Array([
        0.97 - 0.39 * t,
        0.02 + 0.22 * t,
        0.007 + 0.13 * t,
        0.003 + 0.04 * t
    ])
