extends BoneAttachment3D
## V124 WIP: lightweight authored-in-code curved headgear for the actual CC0
## skinned 65-bone avatar. This attachment follows the imported Head bone;
## it does not replace the weighted face, skeleton, or bind matrices.
## All geometry is generated locally, with no paid or third-party textures.

var head_bounds: AABB
var face_sign: float = -1.0
var generated_meshes: Array[MeshInstance3D] = []

func install(rig: Skeleton3D, body_meshes: Array[MeshInstance3D]) -> bool:
    if rig == null:
        return false
    var head_id := rig.find_bone("Head")
    if head_id < 0:
        return false
    var head_rest := rig.get_bone_global_rest(head_id)
    var inverse_rest := head_rest.affine_inverse()
    var lower := Vector3(INF, INF, INF)
    var upper := Vector3(-INF, -INF, -INF)
    var count := 0
    var eye_position := Vector3.ZERO
    var has_eyes := false
    for body in body_meshes:
        if body == null or body.mesh == null or body.skin == null:
            continue
        if String(body.name).to_lower().contains("eyes"):
            eye_position = inverse_rest * rig.to_local(body.to_global(body.get_aabb().get_center()))
            has_eyes = true
        for surface in range(body.mesh.get_surface_count()):
            var arrays: Array = body.mesh.surface_get_arrays(surface)
            var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
            var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
            if weights.size() < vertices.size() * 4 or bones.size() < vertices.size() * 4:
                continue
            for vertex_id in range(vertices.size()):
                var head_weight := 0.0
                for influence in range(4):
                    var skin_index := bones[vertex_id * 4 + influence]
                    if skin_index >= 0 and skin_index < body.skin.get_bind_count():
                        if body.skin.get_bind_bone(skin_index) == head_id:
                            head_weight += weights[vertex_id * 4 + influence]
                if head_weight < 0.45:
                    continue
                var point := inverse_rest * rig.to_local(body.to_global(vertices[vertex_id]))
                lower = lower.min(point)
                upper = upper.max(point)
                count += 1
    var span := upper - lower
    if count < 35 or span.x < 0.08 or span.y < 0.08 or span.z < 0.08 or span.length() > 4.0:
        # Some glTF exporters bind head vertices through a neck/face joint,
        # not directly through Head. Recover from the uppermost 18% of the
        # actual weighted body geometry; never invent a fixed-size head.
        var fallback := _bounds_from_upper_body(rig, body_meshes, inverse_rest)
        if fallback.size.x < 0.08 or fallback.size.y < 0.08 or fallback.size.z < 0.08:
            push_warning("CC0 head bounds invalid: direct=%d span=%s fallback=%s" % [count, span, fallback.size])
            return false
        lower = fallback.position
        upper = fallback.end
        span = fallback.size
    head_bounds = AABB(lower, span)
    face_sign = 1.0 if has_eyes and eye_position.z > head_bounds.get_center().z else -1.0
    bone_name = "Head"
    rig.add_child(self)
    name = "ExternalHeroHeadgear"
    _build_headwear()
    return generated_meshes.size() >= 9

func _bounds_from_upper_body(rig: Skeleton3D, meshes: Array[MeshInstance3D], inverse_rest: Transform3D) -> AABB:
    var bottom := INF
    var top := -INF
    var body_center_x := 0.0
    var count := 0
    for body in meshes:
        for surface in range(body.mesh.get_surface_count()):
            var vertices: PackedVector3Array = body.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
            for vertex in vertices:
                var point := rig.to_local(body.to_global(vertex))
                bottom = minf(bottom, point.y)
                top = maxf(top, point.y)
                body_center_x += point.x
                count += 1
    if count < 100 or top - bottom < 0.5:
        return AABB()
    body_center_x /= float(count)
    var cutoff := bottom + (top - bottom) * 0.80
    var max_offset := (top - bottom) * 0.20
    var lower := Vector3(INF, INF, INF)
    var upper := Vector3(-INF, -INF, -INF)
    var selected := 0
    for body in meshes:
        for surface in range(body.mesh.get_surface_count()):
            var vertices: PackedVector3Array = body.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
            for vertex in vertices:
                var point := rig.to_local(body.to_global(vertex))
                if point.y < cutoff or absf(point.x - body_center_x) > max_offset:
                    continue
                var local := inverse_rest * point
                lower = lower.min(local)
                upper = upper.max(local)
                selected += 1
    if selected < 30:
        return AABB()
    return AABB(lower, upper - lower)

func _material(color: Color, metallic: float = 0.0, roughness: float = 0.5, transparent: bool = false) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = metallic
    mat.roughness = roughness
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    if transparent:
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    return mat

func _mesh(name_text: String, surface: ArrayMesh, mat: Material) -> void:
    if surface == null:
        return
    var instance := MeshInstance3D.new()
    instance.name = name_text
    instance.mesh = surface
    instance.material_override = mat
    add_child(instance)
    generated_meshes.append(instance)

func _build_headwear() -> void:
    var c := head_bounds.get_center()
    var s := head_bounds.size
    var radius_x := s.x * 0.56
    var radius_z := s.z * 0.57
    var crown_y := head_bounds.position.y + s.y * 0.65
    var cap_height := s.y * 0.40
    var cap := SurfaceTool.new()
    cap.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(10):
        var a0 := float(row) / 10.0 * PI * 0.5
        var a1 := float(row + 1) / 10.0 * PI * 0.5
        for column in range(32):
            var t0 := float(column) / 32.0 * TAU
            var t1 := float(column + 1) / 32.0 * TAU
            _quad(cap, _cap_point(c, radius_x, radius_z, crown_y, cap_height, a0, t0),
                _cap_point(c, radius_x, radius_z, crown_y, cap_height, a1, t0),
                _cap_point(c, radius_x, radius_z, crown_y, cap_height, a1, t1),
                _cap_point(c, radius_x, radius_z, crown_y, cap_height, a0, t1))
    cap.generate_normals()
    _mesh("CurvedFlightHelmetShell", cap.commit(), _material(Color(0.18, 0.095, 0.42), 0.35, 0.34))

    var visor := SurfaceTool.new()
    visor.begin(Mesh.PRIMITIVE_TRIANGLES)
    for row in range(5):
        var v0 := float(row) / 5.0
        var v1 := float(row + 1) / 5.0
        for column in range(24):
            var u0 := -0.93 + float(column) / 24.0 * 1.86
            var u1 := -0.93 + float(column + 1) / 24.0 * 1.86
            _quad(visor, _visor_point(c, s, u0, v0),
                _visor_point(c, s, u0, v1),
                _visor_point(c, s, u1, v1),
                _visor_point(c, s, u1, v0))
    visor.generate_normals()
    _mesh("TranslucentFaceShield", visor.commit(), _material(Color(0.10, 0.67, 0.92, 0.24), 0.35, 0.16, true))

    var edge_mat := _material(Color(0.07, 0.80, 0.96), 0.30, 0.25)
    edge_mat.emission_enabled = true
    edge_mat.emission = Color(0.02, 0.32, 0.55)
    edge_mat.emission_energy_multiplier = 1.2
    for edge in [0.0, 1.0]:
        var points: Array[Vector3] = []
        for segment in range(25):
            points.append(_visor_point(c, s, -0.93 + float(segment) / 24.0 * 1.86, edge))
        _mesh("VisorLightEdge%d" % int(edge), _tube(points, s.x * 0.018, 6), edge_mat)

    var hair_mat := _material(Color(0.34, 0.16, 0.62), 0.08, 0.54)
    var highlight := _material(Color(0.61, 0.34, 0.88), 0.12, 0.40)
    for strand in range(7):
        var across := (float(strand) - 3.0) / 3.0
        var start := Vector3(c.x + across * radius_x * 0.46, crown_y + cap_height * 0.94,
            c.z - face_sign * radius_z * 0.18)
        var end := Vector3(c.x + across * radius_x * 0.85,
            crown_y - s.y * (0.07 + 0.05 * absf(across)),
            c.z + face_sign * radius_z * 1.05)
        var mid := Vector3(c.x + across * radius_x * 0.72,
            crown_y + cap_height * 0.52, c.z + face_sign * radius_z * 0.66)
        var points: Array[Vector3] = []
        for segment in range(13):
            var t := float(segment) / 12.0
            points.append(start * (1.0 - t) * (1.0 - t) + mid * (2.0 * t * (1.0 - t)) + end * (t * t))
        _mesh("SweptHairLock%d" % strand, _tube(points, s.x * (0.047 if strand % 2 == 0 else 0.038), 7),
            highlight if strand % 3 == 0 else hair_mat)
    for side in [-1.0, 1.0]:
        var arc: Array[Vector3] = []
        for segment in range(11):
            var t := float(segment) / 10.0
            arc.append(Vector3(c.x + side * radius_x * (0.88 + 0.08 * sin(t * PI)),
                crown_y + cap_height * (0.20 - t * 0.9),
                c.z + face_sign * radius_z * (0.05 + 0.25 * t)))
        _mesh("SideHairSweep%s" % ("L" if side < 0.0 else "R"),
            _tube(arc, s.x * 0.065, 7), hair_mat)

func _cap_point(c: Vector3, rx: float, rz: float, base: float, height: float, elevation: float, azimuth: float) -> Vector3:
    return Vector3(c.x + rx * sin(elevation) * cos(azimuth),
        base + height * cos(elevation),
        c.z + rz * sin(elevation) * sin(azimuth))

func _visor_point(c: Vector3, s: Vector3, angle: float, v: float) -> Vector3:
    return Vector3(c.x + sin(angle) * s.x * 0.51,
        head_bounds.position.y + s.y * (0.48 + (1.0 - v) * 0.20),
        c.z + face_sign * (cos(angle) * s.z * 0.57 + s.z * 0.04))

func _quad(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
    surface.add_vertex(a)
    surface.add_vertex(b)
    surface.add_vertex(c)
    surface.add_vertex(a)
    surface.add_vertex(c)
    surface.add_vertex(d)

func _tube(points: Array[Vector3], radius: float, sides: int) -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for segment in range(points.size() - 1):
        var tangent := (points[segment + 1] - points[segment]).normalized()
        var reference := Vector3.UP if absf(tangent.dot(Vector3.UP)) < 0.9 else Vector3.FORWARD
        var normal := tangent.cross(reference).normalized()
        var binormal := tangent.cross(normal).normalized()
        for side in range(sides):
            var angle0 := TAU * float(side) / float(sides)
            var angle1 := TAU * float(side + 1) / float(sides)
            var taper0 := 1.0 - 0.45 * float(segment) / float(points.size() - 1)
            var taper1 := 1.0 - 0.45 * float(segment + 1) / float(points.size() - 1)
            var offset0 := (normal * cos(angle0) + binormal * sin(angle0)) * radius
            var offset1 := (normal * cos(angle1) + binormal * sin(angle1)) * radius
            _quad(surface, points[segment] + offset0 * taper0,
                points[segment + 1] + offset0 * taper1,
                points[segment + 1] + offset1 * taper1,
                points[segment] + offset1 * taper0)
    surface.generate_normals()
    return surface.commit()
