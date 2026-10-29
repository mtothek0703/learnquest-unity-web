extends Node
## V124: replace all five formerly rigid rear hair volumes with real
## four-influence GPU-skinned meshes on the original 65-bone CC0 rig.
## The source locks are kept as hidden fallback/QA geometry. The original
## Skin, bind matrices, face, touch and gameplay remain untouched.
var locks: Array[MeshInstance3D] = []
var originals: Array[MeshInstance3D] = []
var materials: Array[ShaderMaterial] = []
var vertex_count: int = 0

func install(source: MeshInstance3D, rig: Skeleton3D,
        headwear: BoneAttachment3D, hair: Node) -> bool:
    if source == null or source.mesh == null or source.skin == null or \
            rig == null or headwear == null or hair == null:
        return false
    var head_id := rig.find_bone("Head")
    if head_id < 0:
        return false
    var binds := PackedInt32Array()
    for name in ["Head", "neck_01", "spine_02", "spine_01"]:
        var index := int(hair.call("_bind", source.skin, rig, name))
        if index < 0:
            return false
        binds.append(index)
    var rest := rig.get_bone_global_rest(head_id)
    var shader := load("res://rider_external_back_hair_wind.gdshader") as Shader
    if shader == null:
        return false
    var pending: Array[MeshInstance3D] = []
    var old_locks: Array[MeshInstance3D] = []
    var pending_materials: Array[ShaderMaterial] = []
    var total := 0
    # Build and validate the whole set BEFORE hiding any visible source.
    for i in range(5):
        var old := headwear.get_node_or_null("WindSweptBackLock%d" % i) as MeshInstance3D
        if old == null or old.mesh == null:
            return false
        var bounds := old.mesh.get_aabb()
        if bounds.size.y <= 0.02 or bounds.size.x <= 0.01:
            return false
        var tool := SurfaceTool.new()
        tool.begin(Mesh.PRIMITIVE_TRIANGLES)
        var written := 0
        for surface in range(old.mesh.get_surface_count()):
            if old.mesh.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
                continue
            var arrays: Array = old.mesh.surface_get_arrays(surface)
            var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
            var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
            if vertices.is_empty() or normals.size() != vertices.size():
                return false
            var count := indices.size() if not indices.is_empty() else vertices.size()
            for corner in range(count):
                var id := indices[corner] if not indices.is_empty() else corner
                var local := old.transform * vertices[id]
                var point := source.to_local(rig.to_global(rest * local))
                var local_normal := old.transform.basis * normals[id]
                var world_normal := rig.global_transform.basis * rest.basis * local_normal
                var normal := (source.global_transform.basis.inverse() * world_normal).normalized()
                if not point.is_finite() or not normal.is_finite() or normal.length_squared() < 0.9:
                    return false
                var down := clampf((bounds.end.y - vertices[id].y) / bounds.size.y, 0.0, 1.0)
                var across := clampf((vertices[id].x - bounds.position.x) / bounds.size.x, 0.0, 1.0)
                tool.set_uv(Vector2(across, down))
                tool.set_color(Color.WHITE)
                tool.set_normal(normal)
                tool.set_bones(binds)
                tool.set_weights(hair.call("_weights", down) as PackedFloat32Array)
                tool.add_vertex(point)
                written += 1
        if written < 150:
            return false
        var surface_mesh := tool.commit()
        if surface_mesh == null:
            return false
        var material := ShaderMaterial.new()
        material.shader = shader
        var original_material := old.material_override as StandardMaterial3D
        if original_material == null:
            return false
        material.set_shader_parameter("hair_base_tint", original_material.albedo_color)
        material.set_shader_parameter("wind_back_sign", -float(headwear.get("face_sign")))
        var weighted := MeshInstance3D.new()
        weighted.name = "TrueSkinnedBackLock%d" % i
        weighted.mesh = surface_mesh
        weighted.skin = source.skin
        weighted.skeleton = source.skeleton
        weighted.transform = source.transform
        weighted.material_override = material
        pending.append(weighted)
        old_locks.append(old)
        pending_materials.append(material)
        total += written
    for i in range(pending.size()):
        source.get_parent().add_child(pending[i])
        old_locks[i].visible = false
    locks = pending
    originals = old_locks
    materials = pending_materials
    vertex_count = total
    return true

func set_motion(steer: float, boost: float, jump: float, phase: float) -> void:
    for material in materials:
        material.set_shader_parameter("steer_amount", clampf(steer, -1.0, 1.0))
        material.set_shader_parameter("boost_amount", clampf(boost, 0.0, 1.0))
        material.set_shader_parameter("jump_amount", clampf(jump, 0.0, 1.0))
        material.set_shader_parameter("motion_phase", maxf(phase, 0.0))
