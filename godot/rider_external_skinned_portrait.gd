extends Node
## V124: replace the rigid Head-attached sculpted face with a continuous,
## genuinely GPU-skinned 360-degree face using the ORIGINAL 65-bone CC0 Skin.
## Preserve the existing authored face surface, vertex colors, eye animation,
## and imported bind matrices. The old face stays as a hidden safe fallback.
var face: MeshInstance3D
var original: MeshInstance3D
var vertex_count: int = 0
var upper_head_weight: float = 0.0
var lower_head_weight: float = 0.0

func install(source_meshes: Array[MeshInstance3D], rig: Skeleton3D,
        headwear: BoneAttachment3D) -> bool:
    if rig == null or headwear == null:
        return false
    var rigid_face := headwear.get_node_or_null("SculptedContinuousFace") as MeshInstance3D
    if rigid_face == null or rigid_face.mesh == null:
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
    var head_id := rig.find_bone("Head")
    if head_id < 0:
        return false
    var rest := rig.get_bone_global_rest(head_id)
    var bounds := rigid_face.mesh.get_aabb()
    if bounds.size.y < 0.05 or bounds.size.x < 0.05 or bounds.size.z < 0.05:
        return false
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var written := 0
    for surface_index in range(rigid_face.mesh.get_surface_count()):
        if rigid_face.mesh.surface_get_primitive_type(surface_index) != Mesh.PRIMITIVE_TRIANGLES:
            continue
        var arrays: Array = rigid_face.mesh.surface_get_arrays(surface_index)
        var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR] if arrays[Mesh.ARRAY_COLOR] != null else PackedColorArray()
        var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
        if points.is_empty() or normals.size() != points.size():
            return false
        var count := indices.size() if not indices.is_empty() else points.size()
        for i in range(count):
            var index := indices[i] if not indices.is_empty() else i
            var head_point := rigid_face.transform * points[index]
            var rest_point := rest * head_point
            var body_point := source.to_local(rig.to_global(rest_point))
            var local_normal := rigid_face.transform.basis * normals[index]
            var world_normal := rig.global_transform.basis * rest.basis * local_normal
            var body_normal := (source.global_transform.basis.inverse() * world_normal).normalized()
            if not body_point.is_finite() or not body_normal.is_finite():
                return false
            # The chin blends into neck and chest instead of following the
            # Head as a rigid mask. The crown stays 97% Head-driven.
            var down := clampf((bounds.end.y - points[index].y) /
                bounds.size.y, 0.0, 1.0)
            tool.set_bones(bindings)
            tool.set_weights(_weights(down))
            tool.set_uv(Vector2(0.5 + points[index].x / maxf(bounds.size.x, 0.001), down))
            tool.set_normal(body_normal)
            tool.set_color(colors[index] if colors.size() == points.size() else Color.WHITE)
            tool.add_vertex(body_point)
            written += 1
    if written < 1000:
        return false
    var new_mesh := tool.commit()
    if new_mesh == null:
        return false
    var weighted_face := MeshInstance3D.new()
    weighted_face.name = "TrueSkinnedContinuousPortrait"
    weighted_face.mesh = new_mesh
    weighted_face.skin = source.skin
    weighted_face.skeleton = source.skeleton
    weighted_face.transform = source.transform
    weighted_face.material_override = rigid_face.material_override
    source.get_parent().add_child(weighted_face)
    rigid_face.visible = false
    face = weighted_face
    original = rigid_face
    vertex_count = written
    upper_head_weight = _weights(0.0)[0]
    lower_head_weight = _weights(1.0)[0]
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
    return PackedFloat32Array([
        0.97 - 0.25 * t,
        0.02 + 0.18 * t,
        0.007 + 0.05 * t,
        0.003 + 0.02 * t
    ])
