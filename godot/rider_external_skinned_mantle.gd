extends Node
## V124 draft: two long, tailored, four-weight GPU-skinned coat tails.
## Their shape is sampled from the imported CC0 body bounds, and the original
## Skin/inverse binds are reused. No physics, collisions, paid assets or touch edits.
var panels: Array[MeshInstance3D] = []
var generated_vertices: int = 0
var mantle_span: float = 0.0
var wing_reach: float = 0.0
var shoulder_yoke: MeshInstance3D
var yoke_vertices: int = 0

# Visual-only wind response; real bone skinning still owns the base pose.
func set_motion(steer: float, boost: float, jump: float) -> void:
    for panel in panels:
        var material := panel.material_override as ShaderMaterial
        if material == null:
            continue
        material.set_shader_parameter("steer_amount", clampf(steer, -1.0, 1.0))
        material.set_shader_parameter("boost_amount", clampf(boost, 0.0, 1.0))
        material.set_shader_parameter("jump_amount", clampf(jump, 0.0, 1.0))

func install(source_meshes: Array[MeshInstance3D], rig: Skeleton3D, face_sign: float) -> bool:
    if rig == null:
        return false
    for body in source_meshes:
        if body == null or body.mesh == null or body.skin == null:
            continue
        if not String(body.name).contains("SuperHero"):
            continue
        var pelvis := _bind(body.skin, rig, "pelvis")
        var spine := _bind(body.skin, rig, "spine_01")
        var left_leg := _bind(body.skin, rig, "thigh_l")
        var right_leg := _bind(body.skin, rig, "thigh_r")
        if pelvis < 0 or spine < 0 or left_leg < 0 or right_leg < 0:
            continue
        var bounds := body.mesh.get_aabb()
        if bounds.size.y < 0.5 or bounds.size.x < 0.2:
            continue
        var back_sign := -1.0 if face_sign > 0.0 else 1.0
        var back := _torso_back(body.mesh, bounds, back_sign)
        var skin_indices := PackedInt32Array([spine, pelvis, left_leg, right_leg])
        var created: Array[MeshInstance3D] = []
        for side in [-1, 1]:
            var mesh := _panel(bounds, back, back_sign, float(side), skin_indices)
            if mesh == null:
                for item in created:
                    item.queue_free()
                return false
            var instance := MeshInstance3D.new()
            instance.name = "LeftWeightedFlightMantle" if side < 0 else "RightWeightedFlightMantle"
            instance.mesh = mesh
            instance.skin = body.skin
            instance.skeleton = body.skeleton
            instance.transform = body.transform
            var material := ShaderMaterial.new()
            material.shader = preload("res://rider_external_mantle.gdshader")
            material.set_shader_parameter("side", float(side))
            material.set_shader_parameter("wind_back_sign", back_sign)
            instance.material_override = material
            body.get_parent().add_child(instance)
            created.append(instance)
            generated_vertices += mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()
        # The same four-weight body triangles form a curved shoulder yoke,
        # visibly bridging the narrow imported torso and the flowing mantle.
        var yoke_mesh := _sculpt_yoke(body)
        if yoke_mesh == null:
            for item in created:
                item.queue_free()
            return false
        shoulder_yoke = MeshInstance3D.new()
        shoulder_yoke.name = "WeightedSculptedShoulderYoke"
        shoulder_yoke.mesh = yoke_mesh
        shoulder_yoke.skin = body.skin
        shoulder_yoke.skeleton = body.skeleton
        shoulder_yoke.transform = body.transform
        var yoke_mat := ShaderMaterial.new()
        yoke_mat.shader = preload("res://rider_external_yoke.gdshader")
        yoke_mat.set_shader_parameter("rest_bottom", bounds.position.y)
        yoke_mat.set_shader_parameter("rest_height", bounds.size.y)
        yoke_mat.set_shader_parameter("rest_center_x", bounds.get_center().x)
        yoke_mat.set_shader_parameter("rest_width", bounds.size.x)
        shoulder_yoke.material_override = yoke_mat
        body.get_parent().add_child(shoulder_yoke)
        yoke_vertices = yoke_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()
        panels = created
        mantle_span = bounds.size.y * 0.39
        # Measured on the actual weighted geometry, not a guessed sprite size.
        wing_reach = maxf(absf(created[0].mesh.get_aabb().position.x - bounds.get_center().x),
            absf(created[1].mesh.get_aabb().end.x - bounds.get_center().x))
        return true
    return false

func _bind(skin: Skin, rig: Skeleton3D, name_text: String) -> int:
    for index in range(skin.get_bind_count()):
        var name := String(skin.get_bind_name(index))
        var bone_id := skin.get_bind_bone(index)
        if name == name_text or (name.is_empty() and bone_id >= 0
                and bone_id < rig.get_bone_count() and rig.get_bone_name(bone_id) == name_text):
            return index
    return -1

func _torso_back(mesh: Mesh, bounds: AABB, back_sign: float) -> float:
    var result := -INF if back_sign > 0.0 else INF
    var found := false
    for surface in range(mesh.get_surface_count()):
        var vertices: PackedVector3Array = mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
        for point in vertices:
            var y := (point.y - bounds.position.y) / bounds.size.y
            if y < 0.48 or y > 0.69:
                continue
            if absf(point.x - bounds.get_center().x) > bounds.size.x * 0.13:
                continue
            result = maxf(result, point.z) if back_sign > 0.0 else minf(result, point.z)
            found = true
    if found:
        return result
    return bounds.end.z if back_sign > 0.0 else bounds.position.z

func _panel(bounds: AABB, back: float, back_sign: float, side: float, binds: PackedInt32Array) -> ArrayMesh:
    # One connected aero-silhouette instead of new floating decorative props:
    # compact, down-swept coat fins with curved 3D camber, a sculpted trailing
    # notch and sealed airfoil thickness. Avoid the previous airplane-wing
    # silhouette that hid the original rigged torso and hair in chase view. Four real imported bone influences
    # bend each wing while the central channel leaves the boots/board visible.
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    const ROWS = 20
    const COLUMNS = 12
    for row in range(ROWS):
        for column in range(COLUMNS):
            var u0 := float(column) / float(COLUMNS)
            var u1 := float(column + 1) / float(COLUMNS)
            var t0 := float(row) / float(ROWS)
            var t1 := float(row + 1) / float(ROWS)
            # Opposite winding on the two faces; both use the ORIGINAL Skin.
            _quad(tool, bounds, back, back_sign, side, binds,
                Vector2(u0, t0), Vector2(u0, t1), Vector2(u1, t1), Vector2(u1, t0), 1.0)
            _quad(tool, bounds, back, back_sign, side, binds,
                Vector2(u0, t0), Vector2(u1, t0), Vector2(u1, t1), Vector2(u0, t1), -1.0)
    # Seal the entire perimeter. These are actual weighted sidewalls, not a
    # two-sided material pretending to be a solid sculpted wing.
    for row in range(ROWS):
        var t0 := float(row) / float(ROWS)
        var t1 := float(row + 1) / float(ROWS)
        _edge(tool, bounds, back, back_sign, side, binds, Vector2(0.0, t0), Vector2(0.0, t1))
        _edge(tool, bounds, back, back_sign, side, binds, Vector2(1.0, t1), Vector2(1.0, t0))
    for column in range(COLUMNS):
        var u0 := float(column) / float(COLUMNS)
        var u1 := float(column + 1) / float(COLUMNS)
        _edge(tool, bounds, back, back_sign, side, binds, Vector2(u1, 0.0), Vector2(u0, 0.0))
        _edge(tool, bounds, back, back_sign, side, binds, Vector2(u0, 1.0), Vector2(u1, 1.0))
    # Face normals are analytic and shared at identical (u, t); sealed
    # sidewalls retain flat normals instead of smoothing across the lip.
    return tool.commit()

func _quad(tool: SurfaceTool, bounds: AABB, back: float, back_sign: float,
        side: float, binds: PackedInt32Array, a: Vector2, b: Vector2,
        c: Vector2, d: Vector2, surface_sign: float) -> void:
    for point in [a, b, c, a, c, d]:
        _vertex(tool, bounds, back, back_sign, side, point.x, point.y, binds, surface_sign)

func _edge(tool: SurfaceTool, bounds: AABB, back: float, back_sign: float,
        side: float, binds: PackedInt32Array, a: Vector2, b: Vector2) -> void:
    # Seal the perimeter with a deliberate flat wall normal, independent of
    # the smoothly shaded cloth faces. Keep the original four Skin weights.
    var start := _mantle_point(bounds, back, back_sign, side, a.x, a.y, 1.0)
    var along := _mantle_point(bounds, back, back_sign, side, b.x, b.y, 1.0) - start
    var through := _mantle_point(bounds, back, back_sign, side, a.x, a.y, -1.0) - start
    var wall_normal := along.cross(through).normalized()
    _vertex(tool, bounds, back, back_sign, side, a.x, a.y, binds, 1.0, wall_normal)
    _vertex(tool, bounds, back, back_sign, side, b.x, b.y, binds, 1.0, wall_normal)
    _vertex(tool, bounds, back, back_sign, side, b.x, b.y, binds, -1.0, wall_normal)
    _vertex(tool, bounds, back, back_sign, side, a.x, a.y, binds, 1.0, wall_normal)
    _vertex(tool, bounds, back, back_sign, side, b.x, b.y, binds, -1.0, wall_normal)
    _vertex(tool, bounds, back, back_sign, side, a.x, a.y, binds, -1.0, wall_normal)

# Evaluate the same curved, closed drape for both surfaces and every
# shared vertex. This avoids independent per-triangle normals (the old
# generate_normals() created faceted highlights in the chase camera).
func _mantle_point(bounds: AABB, back: float, back_sign: float,
        side: float, u: float, t: float, surface_sign: float) -> Vector3:
    var width := bounds.size.x
    var center_x := bounds.get_center().x
    var flare := pow(maxf(0.0, sin(PI * t)), 1.20)
    # Broader shoulder-to-thigh midspan and deeper longitudinal fabric folds
    # restore a readable chase silhouette without widening the tapered hem.
    # The same original four-weight Skin continues to drive every vertex.
    var scallop := 0.014 * sin(3.0 * PI * t) * sin(PI * t)
    var inner := width * (0.070 + 0.045 * t)
    var outer := width * (0.135 + 0.092 * flare + 0.018 * t + scallop * 0.35)
    var x := center_x + side * lerpf(inner, outer, u)
    var camber := sin(u * PI) * sin(t * PI)
    var y := bounds.position.y + bounds.size.y * (0.76 - 0.39 * t +
        0.025 * camber + 0.012 * u * t)
    var sweep := 0.040 + 0.10 * t + 0.12 * pow(t, 1.4) + 0.025 * camber
    var rib := sin(u * PI * 2.0 + t * 1.7) * width * 0.026 * sin(PI * t)
    var thickness := width * (0.009 + 0.017 * sin(PI * u) * sin(PI * t) +
        0.005 * sin(PI * t) * u * u)
    var z := back + back_sign * (sweep + rib + surface_sign * thickness)
    return Vector3(x, y, z)

func _mantle_normal(bounds: AABB, back: float, back_sign: float,
        side: float, u: float, t: float, surface_sign: float) -> Vector3:
    var h := 0.001
    var tangent_u := _mantle_point(bounds, back, back_sign, side,
        clampf(u + h, 0.0, 1.0), t, surface_sign) - \
        _mantle_point(bounds, back, back_sign, side,
        clampf(u - h, 0.0, 1.0), t, surface_sign)
    var tangent_t := _mantle_point(bounds, back, back_sign, side,
        u, clampf(t + h, 0.0, 1.0), surface_sign) - \
        _mantle_point(bounds, back, back_sign, side,
        u, clampf(t - h, 0.0, 1.0), surface_sign)
    # Front/back are emitted with opposite triangle winding.
    return (tangent_t.cross(tangent_u) if surface_sign > 0.0 else
        tangent_u.cross(tangent_t)).normalized()

func _vertex(tool: SurfaceTool, bounds: AABB, back: float, back_sign: float,
        side: float, u: float, t: float, binds: PackedInt32Array,
        surface_sign: float, wall_normal: Vector3 = Vector3.ZERO) -> void:
    var spine_weight := 0.72 * (1.0 - t) * (1.0 - t)
    var leg_weight := 0.34 * t * t
    var pelvis_weight := 1.0 - spine_weight - leg_weight
    var left_weight := leg_weight if side < 0.0 else 0.0
    var right_weight := leg_weight if side > 0.0 else 0.0
    tool.set_bones(binds)
    tool.set_weights(PackedFloat32Array([spine_weight, pelvis_weight, left_weight, right_weight]))
    tool.set_uv(Vector2(u, t))
    tool.set_normal(wall_normal if wall_normal.length_squared() > 0.5 else
        _mantle_normal(bounds, back, back_sign, side, u, t, surface_sign))
    tool.add_vertex(_mantle_point(bounds, back, back_sign, side, u, t, surface_sign))

func _sculpt_yoke(body: MeshInstance3D) -> ArrayMesh:
    var bounds := body.mesh.get_aabb()
    var output := SurfaceTool.new()
    output.begin(Mesh.PRIMITIVE_TRIANGLES)
    var accepted := 0
    for surface in range(body.mesh.get_surface_count()):
        if body.mesh.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
            continue
        var arrays: Array = body.mesh.surface_get_arrays(surface)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
        if normals.size() != vertices.size() or bones.size() != vertices.size() * 4 or weights.size() != vertices.size() * 4:
            continue
        var count := int(indices.size() / 3) if not indices.is_empty() else int(vertices.size() / 3)
        for triangle in range(count):
            var a := indices[triangle * 3] if not indices.is_empty() else triangle * 3
            var b := indices[triangle * 3 + 1] if not indices.is_empty() else triangle * 3 + 1
            var c := indices[triangle * 3 + 2] if not indices.is_empty() else triangle * 3 + 2
            if not _is_yoke(vertices[a], bounds) or not _is_yoke(vertices[b], bounds) or not _is_yoke(vertices[c], bounds):
                continue
            for index in [a, b, c]:
                var point := vertices[index]
                var normal := normals[index].normalized()
                var x := (point.x - bounds.get_center().x) / bounds.size.x
                var shoulder := smoothstep(0.075, 0.28, absf(x))
                var offset := normal * (0.050 + shoulder * 0.025)
                offset.x += (1.0 if x >= 0.0 else -1.0) * shoulder * 0.022
                output.set_normal(normal)
                output.set_bones(PackedInt32Array([
                    bones[index * 4], bones[index * 4 + 1],
                    bones[index * 4 + 2], bones[index * 4 + 3]]))
                output.set_weights(PackedFloat32Array([
                    weights[index * 4], weights[index * 4 + 1],
                    weights[index * 4 + 2], weights[index * 4 + 3]]))
                output.add_vertex(point + offset)
                accepted += 1
    if accepted < 120:
        return null
    return output.commit()

func _is_yoke(point: Vector3, bounds: AABB) -> bool:
    var height := (point.y - bounds.position.y) / bounds.size.y
    var width := absf(point.x - bounds.get_center().x) / bounds.size.x
    return height >= 0.615 and height <= 0.785 and width <= 0.36
