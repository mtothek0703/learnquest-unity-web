extends Node
## V124 draft: two flowing, four-weight GPU-skinned flight-mantle panels.
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
        mantle_span = bounds.size.y * 0.26
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
    # broad, tapered swept wings with curved 3D camber, a sculpted trailing
    # scallop and sealed airfoil thickness. Four real imported bone influences
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
    tool.generate_normals()
    return tool.commit()

func _quad(tool: SurfaceTool, bounds: AABB, back: float, back_sign: float,
        side: float, binds: PackedInt32Array, a: Vector2, b: Vector2,
        c: Vector2, d: Vector2, surface_sign: float) -> void:
    for point in [a, b, c, a, c, d]:
        _vertex(tool, bounds, back, back_sign, side, point.x, point.y, binds, surface_sign)

func _edge(tool: SurfaceTool, bounds: AABB, back: float, back_sign: float,
        side: float, binds: PackedInt32Array, a: Vector2, b: Vector2) -> void:
    # The original edge fan used the same endpoint twice per triangle,
    # producing zero-area faces and leaving both skinned airfoils open.
    # Bridge the actual +thickness and -thickness contours with two
    # nondegenerate triangles. The four source Skin influences are unchanged.
    _vertex(tool, bounds, back, back_sign, side, a.x, a.y, binds, 1.0)
    _vertex(tool, bounds, back, back_sign, side, b.x, b.y, binds, 1.0)
    _vertex(tool, bounds, back, back_sign, side, b.x, b.y, binds, -1.0)
    _vertex(tool, bounds, back, back_sign, side, a.x, a.y, binds, 1.0)
    _vertex(tool, bounds, back, back_sign, side, b.x, b.y, binds, -1.0)
    _vertex(tool, bounds, back, back_sign, side, a.x, a.y, binds, -1.0)

func _vertex(tool: SurfaceTool, bounds: AABB, back: float, back_sign: float,
        side: float, u: float, t: float, binds: PackedInt32Array,
        surface_sign: float) -> void:
    var width := bounds.size.x
    var center_x := bounds.get_center().x
    # The root stays close to the weighted shoulder yoke. The outer edge
    # expands into a broad midspan sail, then tapers to a narrow raised tip;
    # alternating scallops keep the chase silhouette from reading as a skirt.
    var flare := sin(PI * t * 0.87)
    var scallop := 0.042 * sin(5.0 * PI * t) * sin(PI * t)
    var inner := width * (0.07 + 0.15 * t)
    var outer := width * (0.12 + 0.44 * flare + 0.04 * t + scallop)
    var x := center_x + side * lerpf(inner, outer, u)
    var camber := sin(u * PI) * sin(t * PI)
    var y := bounds.position.y + bounds.size.y * (0.72 - 0.26 * t +
        0.042 * camber + 0.018 * u * t)
    # Real curved spar and swept depth, not a flat two-sided ribbon.
    var sweep := 0.045 + 0.16 * t + 0.26 * pow(t, 1.4) + 0.12 * camber
    var rib := sin(u * PI * 3.0 + t * 3.0) * width * 0.010 * t
    var thickness := width * (0.008 + 0.050 * sin(PI * u) * sin(PI * t))
    var z := back + back_sign * (sweep + rib + surface_sign * thickness)
    var spine_weight := 0.72 * (1.0 - t) * (1.0 - t)
    var leg_weight := 0.34 * t * t
    var pelvis_weight := 1.0 - spine_weight - leg_weight
    var left_weight := leg_weight if side < 0.0 else 0.0
    var right_weight := leg_weight if side > 0.0 else 0.0
    tool.set_bones(binds)
    tool.set_weights(PackedFloat32Array([spine_weight, pelvis_weight, left_weight, right_weight]))
    tool.set_uv(Vector2(u, t))
    tool.add_vertex(Vector3(x, y, z))

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
