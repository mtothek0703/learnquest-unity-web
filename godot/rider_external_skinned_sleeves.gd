extends Node
## V124: sculpt BOTH articulated sleeves directly from the CC0 humanoid's
## weighted source triangles. No rigid arm cylinders or replacement skeleton.
## The original four bone influences and inverse bind matrices remain intact.
var sleeves: Array[MeshInstance3D] = []
var generated_vertices: int = 0
var arm_vertex_counts: Array[int] = []

func install(source_meshes: Array[MeshInstance3D], rig: Skeleton3D) -> bool:
    if rig == null:
        return false
    for body in source_meshes:
        if body == null or body.mesh == null or body.skin == null:
            continue
        if not String(body.name).contains("SuperHero"):
            continue
        var created: Array[MeshInstance3D] = []
        for side in [-1, 1]:
            var suffix := "_l" if side < 0 else "_r"
            var upper := _bind(body.skin, rig, "upperarm" + suffix)
            var lower := _bind(body.skin, rig, "lowerarm" + suffix)
            var hand := _bind(body.skin, rig, "hand" + suffix)
            if upper < 0 or lower < 0:
                return false
            var mesh := _sculpt_arm(body, upper, lower, hand)
            if mesh == null:
                for part in created:
                    part.queue_free()
                return false
            var sleeve := MeshInstance3D.new()
            sleeve.name = "LeftWeightedFlightSleeve" if side < 0 else "RightWeightedFlightSleeve"
            sleeve.mesh = mesh
            sleeve.skin = body.skin
            sleeve.skeleton = body.skeleton
            sleeve.transform = body.transform
            var mat := ShaderMaterial.new()
            mat.shader = preload("res://rider_external_sleeves.gdshader")
            mat.set_shader_parameter("side", float(side))
            sleeve.material_override = mat
            body.get_parent().add_child(sleeve)
            created.append(sleeve)
            var count: int = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()
            arm_vertex_counts.append(count)
            generated_vertices += count
        sleeves = created
        return sleeves.size() == 2 and generated_vertices >= 300
    return false

func _bind(skin: Skin, rig: Skeleton3D, name_text: String) -> int:
    for i in range(skin.get_bind_count()):
        var bind_name := String(skin.get_bind_name(i))
        var bone_id := skin.get_bind_bone(i)
        if bind_name == name_text or (bind_name.is_empty() and bone_id >= 0 and
                bone_id < rig.get_bone_count() and String(rig.get_bone_name(bone_id)) == name_text):
            return i
    return -1

func _influence(weights: PackedFloat32Array, bones: PackedInt32Array, index: int,
        upper: int, lower: int, hand: int) -> Vector2:
    var total := 0.0
    var shoulder := 0.0
    for slot in range(4):
        var bind := bones[index * 4 + slot]
        var weight := weights[index * 4 + slot]
        if bind == upper:
            shoulder += weight
            total += weight
        elif bind == lower or (hand >= 0 and bind == hand):
            total += weight
    return Vector2(total, shoulder)

func _sculpt_arm(body: MeshInstance3D, upper: int, lower: int, hand: int) -> ArrayMesh:
    var output := SurfaceTool.new()
    output.begin(Mesh.PRIMITIVE_TRIANGLES)
    var accepted := 0
    var bounds := body.mesh.get_aabb()
    for surface in range(body.mesh.get_surface_count()):
        if body.mesh.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
            continue
        var arrays: Array = body.mesh.surface_get_arrays(surface)
        var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
        if points.is_empty() or normals.size() != points.size() or \
                bones.size() < points.size() * 4 or weights.size() < points.size() * 4:
            continue
        var triangle_count := int(indices.size() / 3) if not indices.is_empty() else int(points.size() / 3)
        for tri in range(triangle_count):
            var a := indices[tri * 3] if not indices.is_empty() else tri * 3
            var b := indices[tri * 3 + 1] if not indices.is_empty() else tri * 3 + 1
            var c := indices[tri * 3 + 2] if not indices.is_empty() else tri * 3 + 2
            var ia := _influence(weights, bones, a, upper, lower, hand)
            var ib := _influence(weights, bones, b, upper, lower, hand)
            var ic := _influence(weights, bones, c, upper, lower, hand)
            # Only original arm triangles, never torso/face or a disconnected prop.
            if minf(ia.x, minf(ib.x, ic.x)) < 0.40:
                continue
            for vertex_id in [a, b, c]:
                var inf := _influence(weights, bones, vertex_id, upper, lower, hand)
                var normal := normals[vertex_id].normalized()
                # Coherent shoulder-to-wrist sculpt, not thin floating tubes:
                # weight-aware shoulder armor, elbow bellows and forearm bracer
                # stay part of the same four-weight skinned source surface.
                var shaped := points[vertex_id] + _sculpt_offset(
                    points[vertex_id], normal, bounds, inf)
                var panel := _armor_panel(inf)
                output.set_normal(normal)
                output.set_color(Color(inf.y, inf.x, panel, 1.0))
                output.set_bones(PackedInt32Array([
                    bones[vertex_id * 4], bones[vertex_id * 4 + 1],
                    bones[vertex_id * 4 + 2], bones[vertex_id * 4 + 3]]))
                output.set_weights(PackedFloat32Array([
                    weights[vertex_id * 4], weights[vertex_id * 4 + 1],
                    weights[vertex_id * 4 + 2], weights[vertex_id * 4 + 3]]))
                output.add_vertex(shaped)
                accepted += 1
    if accepted < 150:
        return null
    return output.commit()

# Sculpting is driven by original upper/lower-arm weights, so the armor
# follows actual shoulder/elbow bends rather than sliding rigid attachments.
# Return displacement in the imported mesh's REST space only.
func _sculpt_offset(point: Vector3, normal: Vector3, bounds: AABB,
        inf: Vector2) -> Vector3:
    var shoulder := smoothstep(0.32, 0.90, inf.y)
    var elbow := exp(-pow((inf.y - 0.48) / 0.20, 2.0))
    var forearm := smoothstep(0.22, 0.72, inf.x - inf.y)
    var wrist := 1.0 - smoothstep(0.22, 0.46, inf.x)
    var shell := 0.018 + 0.052 * shoulder + 0.028 * elbow + 0.035 * forearm * (1.0 - wrist)
    var lateral := signf(point.x - bounds.get_center().x)
    # Sculpt the outer shoulder into a broad V-shaped silhouette, while the
    # elbow keeps clearance and the wrist returns close to the original hand.
    return normal * shell + Vector3(lateral * (0.019 * shoulder + 0.009 * elbow),
        0.009 * shoulder, 0.0)

func _armor_panel(inf: Vector2) -> float:
    # Stored as COLOR.b, interpolated by GPU; visible broad armor zones rather
    # than subpixel seams at smartphone chase-camera distance.
    var shoulder_plate := smoothstep(0.43, 0.78, inf.y)
    var elbow_ring := exp(-pow((inf.y - 0.48) / 0.13, 2.0))
    var forearm_plate := smoothstep(0.30, 0.69, inf.x - inf.y)
    return maxf(shoulder_plate, maxf(elbow_ring * 0.75, forearm_plate * 0.86))
